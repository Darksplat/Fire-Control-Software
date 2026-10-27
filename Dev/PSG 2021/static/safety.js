// Safety panel: arm/kill, safe-to-fire zone drawing, log export. Talks to /arm /kill /zones /log.
(function () {
  const token = () => { try { return localStorage.getItem("psg-token") || ""; } catch (e) { return ""; } };
  const api = (path, method, body) => fetch(path, {
    method: method || "GET",
    headers: { "Content-Type": "application/json", "X-Token": token() },
    body: body === undefined ? undefined : JSON.stringify(body)
  }).then(r => r.status === 204 ? {} : r.json().catch(() => ({})));

  const panel = document.createElement("div");
  panel.id = "psg-safety";
  panel.style.cssText = "display:flex;gap:8px;flex-wrap:wrap;align-items:center;padding:8px;margin:6px 0;border:1px solid #888;border-radius:4px;font:14px system-ui,sans-serif";
  panel.innerHTML =
    '<button id="sf-arm" aria-pressed="false" style="min-height:40px;padding:0 14px">Arm</button>' +
    '<button id="sf-kill" style="min-height:40px;padding:0 14px;color:#c00;border:2px solid #c00;background:transparent">Kill</button>' +
    '<label><input type="checkbox" id="sf-draw"> Draw safe-to-fire zone</label>' +
    '<button id="sf-clear" style="min-height:40px">Clear zones</button>' +
    '<a href="/log?format=csv" id="sf-log">Export log</a>' +
    '<span id="sf-state" aria-live="polite"></span>';
  const container = document.getElementById("psg-container") || document.body;
  container.insertBefore(panel, container.firstChild);

  const $ = id => document.getElementById(id);
  let armed = false;
  function render(s) {
    armed = !!s.armed;
    $("sf-arm").textContent = armed ? "Disarm" : "Arm";
    $("sf-arm").setAttribute("aria-pressed", armed);
    $("sf-arm").style.cssText += armed ? ";background:#c00;color:#fff" : ";background:transparent;color:inherit";
    $("sf-state").textContent = (armed ? "ARMED" : "Safe") + (s.firing ? " - firing" : "") + " - " + (s.zones || []).length + " zone(s)";
  }
  const refresh = () => api("/safety_status").then(render).catch(() => {});
  $("sf-arm").onclick = () => api("/arm", "POST", { armed: !armed }).then(refresh);
  $("sf-kill").onclick = () => api("/kill", "POST", {}).then(refresh);
  $("sf-clear").onclick = () => api("/zones", "DELETE").then(refresh);
  setInterval(refresh, 1000); refresh();

  // Zone drawing: while the checkbox is on, swallow video-port mouse events so the turret is not aimed or fired.
  const img = $("psg-video-port");
  if (!img) return;
  let start = null;
  const pos = e => {
    const r = img.getBoundingClientRect();
    return [(e.clientX - r.left) * (img.naturalWidth || r.width) / r.width, (e.clientY - r.top) * (img.naturalHeight || r.height) / r.height];
  };
  ["mousedown", "mousemove", "mouseup", "mouseout"].forEach(type => {
    container.addEventListener(type, e => {
      if (!$("sf-draw").checked || e.target !== img) return;
      e.stopPropagation(); e.preventDefault();
      if (type === "mousedown") start = pos(e);
      if (type === "mouseup" && start) {
        const [x2, y2] = pos(e), [x1, y1] = start; start = null;
        const w = Math.abs(x2 - x1), h = Math.abs(y2 - y1);
        if (w > 5 && h > 5) api("/zones", "POST", { x: Math.round(Math.min(x1, x2)), y: Math.round(Math.min(y1, y2)), w: Math.round(w), h: Math.round(h) }).then(refresh);
      }
    }, true);
  });
})();
