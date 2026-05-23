const statusFields = {
  project: document.querySelector('[data-field="project"]'),
  feature: document.querySelector('[data-field="feature"]'),
  backlog: document.querySelector('[data-field="backlog"]'),
  checklist: document.querySelector('[data-field="checklist"]'),
  git: document.querySelector('[data-field="git"]'),
};

const evidenceFields = {
  phase: document.querySelector('[data-evidence="phase"]'),
  checklist: document.querySelector('[data-evidence="checklist"]'),
  open: document.querySelector('[data-evidence="open"]'),
};

const connectionState = document.querySelector("[data-connection-state]");
const refreshButton = document.querySelector("[data-refresh]");
const phaseForm = document.querySelector("#phase-form");
const phaseSummary = document.querySelector("[data-phase-summary]");
const wavesBody = document.querySelector("[data-waves]");
const errors = document.querySelector("[data-errors]");

refreshButton.addEventListener("click", () => refreshStatus());
phaseForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const form = new FormData(phaseForm);
  const phaseId = String(form.get("phase_id") || "").trim();
  if (phaseId) {
    loadPhasePlan(phaseId);
  }
});

refreshStatus();

async function refreshStatus() {
  try {
    setConnection("loading", "loading");
    const status = await fetchJson("/api/status");
    renderStatus(status);
    setConnection("connected", "connected");
    clearError();
  } catch (error) {
    setConnection("error", "error");
    showError(error);
  }
}

async function loadPhasePlan(phaseId) {
  try {
    const plan = await fetchJson(`/api/phase-plan?phase_id=${encodeURIComponent(phaseId)}`);
    renderPhasePlan(plan);
    await refreshStatus();
    clearError();
  } catch (error) {
    showError(error);
  }
}

async function fetchJson(url) {
  const response = await fetch(url, { headers: { accept: "application/json" } });
  const body = await response.json();
  if (!response.ok) {
    throw new Error(body.detail || body.error || `Request failed: ${response.status}`);
  }
  return body;
}

function renderStatus(status) {
  if (!status.appmaker) {
    statusFields.project.textContent = "not initialized";
    statusFields.feature.textContent = "-";
    statusFields.backlog.textContent = "-";
    statusFields.checklist.textContent = "-";
    statusFields.git.textContent = "-";
    return;
  }

  const backlog = status.backlog || {};
  const checklist = status.checklist || {};
  const phase = status.phase || {};
  const git = status.git || {};

  statusFields.project.textContent = status.version || "unknown";
  statusFields.feature.textContent = status.active_feature || "none";
  statusFields.backlog.textContent = `${backlog.done || 0}/${backlog.total || 0} done`;
  statusFields.checklist.textContent = checklist.status || "-";
  statusFields.git.textContent = git.dirty ? `${git.changed_count} dirty` : "clean";

  evidenceFields.phase.textContent = phase.id ? `${phase.id} ${phase.mode || ""} ${phase.status || ""}` : "-";
  evidenceFields.checklist.textContent = checklist.file || "-";
  evidenceFields.open.textContent = Array.isArray(backlog.open_ids) && backlog.open_ids.length
    ? backlog.open_ids.join(", ")
    : "-";
}

function renderPhasePlan(plan) {
  const state = document.createElement("span");
  state.className = "state-pill";
  state.dataset.state = plan.status || "";
  state.textContent = plan.status || "unknown";

  phaseSummary.replaceChildren(state, document.createTextNode(` ${plan.phase_id || ""} -> ${plan.report_path || ""}`));

  const waves = Array.isArray(plan.waves) ? plan.waves : [];
  if (!waves.length) {
    wavesBody.innerHTML = '<tr><td colspan="3">No executable waves.</td></tr>';
    return;
  }

  wavesBody.replaceChildren(...waves.map((wave) => {
    const row = document.createElement("tr");
    row.append(
      cell(String(wave.wave || "-")),
      cell(Array.isArray(wave.items) ? wave.items.join(", ") : "-"),
      cell(wave.reason || "-"),
    );
    return row;
  }));
}

function cell(value) {
  const td = document.createElement("td");
  td.textContent = value;
  return td;
}

function setConnection(label, state) {
  connectionState.textContent = label;
  connectionState.dataset.state = state;
}

function showError(error) {
  errors.hidden = false;
  errors.textContent = error.message || String(error);
}

function clearError() {
  errors.hidden = true;
  errors.textContent = "";
}
