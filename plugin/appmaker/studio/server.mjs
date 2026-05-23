#!/usr/bin/env node
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { extname, join, normalize, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { execFile } from "node:child_process";

const __dirname = fileURLToPath(new URL(".", import.meta.url));
const pluginRoot = resolve(__dirname, "..");
const publicDir = resolve(__dirname, "public");
const statusScript = resolve(pluginRoot, "scripts/status-json.sh");
const phaseScript = resolve(pluginRoot, "scripts/phase-plan.sh");

const options = parseArgs(process.argv.slice(2));

if (options.help) {
  printHelp();
  process.exit(0);
}

const projectDir = resolve(options.projectDir || process.cwd());
const host = options.host || "127.0.0.1";
const port = Number(options.port || 19773);

if (options.api) {
  await runApiMode(options);
  process.exit(process.exitCode || 0);
}

const server = createServer(async (req, res) => {
  try {
    await route(req, res);
  } catch (error) {
    sendJson(res, 500, { error: "internal_error", detail: error.message });
  }
});

server.listen(port, host, () => {
  const address = server.address();
  const actualPort = typeof address === "object" && address ? address.port : port;
  console.log(`AppMaker Studio listening at http://${host}:${actualPort}`);
  console.log(`Project: ${projectDir}`);
});

function parseArgs(args) {
  const parsed = {};
  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    if (arg === "--help" || arg === "-h") {
      parsed.help = true;
    } else if (arg === "--project-dir") {
      parsed.projectDir = requireValue(args, ++i, arg);
    } else if (arg === "--host") {
      parsed.host = requireValue(args, ++i, arg);
    } else if (arg === "--port") {
      parsed.port = requireValue(args, ++i, arg);
    } else if (arg === "--api") {
      parsed.api = requireValue(args, ++i, arg);
    } else if (arg === "--phase-id") {
      parsed.phaseId = requireValue(args, ++i, arg);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return parsed;
}

function requireValue(args, index, flag) {
  if (!args[index]) {
    throw new Error(`${flag} requires a value`);
  }
  return args[index];
}

function printHelp() {
  console.log(`Usage: node studio/server.mjs [--project-dir DIR] [--host HOST] [--port PORT]
       node studio/server.mjs --api status [--project-dir DIR]
       node studio/server.mjs --api phase-plan --phase-id ID [--project-dir DIR]

Serves the local AppMaker Studio UI and read-only JSON APIs.

Options:
  --project-dir DIR   Project root to inspect. Defaults to current directory.
  --host HOST         Host to bind. Defaults to 127.0.0.1.
  --port PORT         Port to bind. Use 0 for an available port.
  --api NAME          Non-listening API mode for tests/adapters: status | phase-plan.
  --phase-id ID       Phase id for --api phase-plan.
  --help              Show this help.`);
}

async function runApiMode(apiOptions) {
  if (apiOptions.api === "status") {
    const result = await runJson(statusScript, ["--project-dir", projectDir]);
    process.stdout.write(`${result.stdout}\n`);
    process.exitCode = result.statusCode >= 400 ? 1 : 0;
    return;
  }

  if (apiOptions.api === "phase-plan") {
    if (!apiOptions.phaseId) {
      process.stderr.write("--phase-id is required for --api phase-plan\n");
      process.exitCode = 2;
      return;
    }
    const result = await runJson(phaseScript, ["--json", apiOptions.phaseId, "--project-dir", projectDir]);
    process.stdout.write(`${result.stdout}\n`);
    process.exitCode = result.statusCode >= 400 ? 1 : 0;
    return;
  }

  process.stderr.write(`unknown --api value: ${apiOptions.api}\n`);
  process.exitCode = 2;
}

async function route(req, res) {
  const requestUrl = new URL(req.url || "/", `http://${host}:${port}`);

  if (req.method !== "GET") {
    sendJson(res, 405, { error: "method_not_allowed" });
    return;
  }

  if (requestUrl.pathname === "/api/status") {
    const result = await runJson(statusScript, ["--project-dir", projectDir]);
    sendRawJson(res, result.statusCode, result.stdout);
    return;
  }

  if (requestUrl.pathname === "/api/phase-plan") {
    const phaseId = requestUrl.searchParams.get("phase_id") || "";
    if (!phaseId.trim()) {
      sendJson(res, 400, { error: "missing_phase_id" });
      return;
    }
    const result = await runJson(phaseScript, ["--json", phaseId, "--project-dir", projectDir]);
    sendRawJson(res, result.statusCode, result.stdout);
    return;
  }

  if (requestUrl.pathname === "/health") {
    sendJson(res, 200, { ok: true });
    return;
  }

  await serveStatic(requestUrl.pathname, res);
}

function runJson(command, args) {
  return new Promise((resolveRun) => {
    execFile("bash", [command, ...args], { cwd: projectDir }, (error, stdout, stderr) => {
      const trimmed = stdout.trim();
      if (trimmed.startsWith("{")) {
        resolveRun({
          statusCode: error ? 409 : 200,
          stdout: trimmed,
        });
        return;
      }
      resolveRun({
        statusCode: error ? 500 : 200,
        stdout: JSON.stringify({
          error: error ? "command_failed" : "invalid_json",
          detail: (stderr || stdout || error?.message || "").trim(),
        }),
      });
    });
  });
}

async function serveStatic(pathname, res) {
  const safePath = pathname === "/" ? "/index.html" : pathname;
  const targetPath = normalize(join(publicDir, decodeURIComponent(safePath)));
  const rel = relative(publicDir, targetPath);

  if (rel.startsWith("..") || rel === "" || !existsSync(targetPath)) {
    sendJson(res, 404, { error: "not_found" });
    return;
  }

  const content = await readFile(targetPath);
  res.writeHead(200, {
    "content-type": contentType(targetPath),
    "cache-control": "no-store",
  });
  res.end(content);
}

function sendJson(res, statusCode, payload) {
  sendRawJson(res, statusCode, JSON.stringify(payload));
}

function sendRawJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",
  });
  res.end(`${payload}\n`);
}

function contentType(filePath) {
  switch (extname(filePath)) {
    case ".html":
      return "text/html; charset=utf-8";
    case ".css":
      return "text/css; charset=utf-8";
    case ".js":
      return "text/javascript; charset=utf-8";
    default:
      return "application/octet-stream";
  }
}
