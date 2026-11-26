// Regresión de la etapa 3: 22 jugadores, pases fluidos, goles reales y controles.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const script = fs.readFileSync(path.join(root, "web/js/arena-pitch.js"), "utf8");
const runtime = fs.readFileSync(path.join(root, "web/js/stitch-runtime.js"), "utf8");
const markup = fs.readFileSync(path.join(root, "web/WEB-INF/views/arena/match.jsp"), "utf8");
assert.doesNotThrow(() => new vm.Script(script), "Sintaxis del motor 2D");
assert.doesNotMatch(runtime, /(?<!\$)\$\("\.arena-replay-marker", markers\)\.forEach/,
  "Los botones de eventos se recorren con querySelectorAll, no querySelector");
assert.match(runtime, /\$\$\("\.arena-replay-marker", markers\)\.forEach/);
assert.match(runtime, /window\.requestAnimationFrame\(animateFrames\)/);
assert.match(runtime, /window\.cancelAnimationFrame\?\.\(frameHandle\)/);
assert.match(markup, /id="progress-track" role="slider"/);
assert.doesNotMatch(markup, /18' Gol SAP|34' Gol LDA|90\+2' Gol SAP/,
  "No deben quedar goles ficticios en la línea de tiempo");

function node() {
  return {
    children: [], dataset: {}, style: {}, textContent: "", title: "",
    classList: { add() {} },
    appendChild(child) { this.children.push(child); },
    setAttribute(key, value) { this[key] = value; }
  };
}
const window = {};
const document = { createElement: node };
vm.runInNewContext(script, { window, document });
const API = window.ArenaPitch;
assert.ok(API?.frame && API?.create && API?.pose);

const goals = [{ type: "GOL", side: "A", minute: 34, player: "Atacante" },
  { type: "GOL", side: "B", minute: 67, player: "Delantero" }];

let transitions = new Set();
for (let t = 0; t <= 90; t += .25) {
  const f = API.frame(t, 12, goals);
  assert.equal(f.players.length, 22);
  assert.equal(f.players.filter((p) => p.goalkeeper).length, 2);
  assert.equal(f.players.filter((p) => p.team === "A").length, 11);
  assert.equal(f.players.filter((p) => p.team === "B").length, 11);
  assert.ok(f.players.every((p) =>
    Number.isFinite(p.x) && Number.isFinite(p.y) &&
    p.x >= 5 && p.x <= 95 && p.y >= 8 && p.y <= 92));
  assert.ok(f.ball.x >= 3 && f.ball.x <= 97);
  assert.ok(f.ball.y >= 5 && f.ball.y <= 95);
  assert.equal(JSON.stringify(f), JSON.stringify(API.frame(t, 12, goals)),
    "El replay debe ser determinista para permitir pausa y seek");
  if (Number.isInteger(t)) transitions.add(f.action);
  if (!Number.isInteger(t)) transitions.add(f.action);
}
assert.ok(transitions.has("PASE EN MOVIMIENTO"), "Debe simular pases");
assert.ok(transitions.has("DISPUTA DEL BALÓN"), "Debe simular disputa");
assert.ok(transitions.has("RECUPERACIÓN"), "Debe simular recuperación");
assert.ok(transitions.has("DISPARO A PORTERÍA"), "Debe simular remates");
assert.ok(transitions.has("¡GOL!"), "Debe reproducir goles registrados");
assert.ok(transitions.has("CELEBRACIÓN"), "Debe animar una celebración");

const beforeGoal = API.frame(33.5, 12, goals);
assert.equal(beforeGoal.action, "DISPARO A PUERTA");
assert.equal(beforeGoal.goal, false, "Antes del minuto oficial no hay gol");
assert.equal(API.frame(34, 12, goals).action, "¡GOL!");
assert.equal(API.frame(34, 12, goals).ball.x, 97);
assert.equal(API.frame(67, 12, goals).ball.x, 3);
assert.equal(API.frame(34.5, 12, goals).action, "CELEBRACIÓN");
assert.equal(API.frame(500, 12, goals).minute, 90);
assert.equal(API.frame(-4, 12, goals).minute, 0);
assert.equal(API.frame(34, 12, []).goal, false);
assert.ok(Array.from({length:91}, (_,i) => API.pose(i,12,[])).every(p => !p.goal),
  "Sin goles reportados, ningún remate puede convertirse en un gol");

const midpoint = API.frame(15.5, 12, goals);
assert.ok(midpoint.progress > 0 && midpoint.progress < 1);
assert.ok(midpoint.ball.x !== midpoint.fromBall.x ||
  midpoint.ball.y !== midpoint.fromBall.y,
  "La pelota debe desplazarse entre dos poses, no teletransportarse");

const ball = node(), trail = node(), title = node(), sub = node(),
  home = node(), away = node();
const elements = {
  "#ball-actor": ball, "#ball-vector-trail": trail,
  "#tactical-state": title, "#tactical-substate": sub,
  "[data-pitch-home]": home, "[data-pitch-away]": away
};
const field = node();
field.querySelector = (selector) => elements[selector] || null;
const replay = API.create(field, {
  id: 12, home: "Águilas", away: "Ñandú", events: goals
});
assert.equal(field.children[0].children.length, 22);
assert.equal(field.children[1].children.length, 2);
assert.equal(field.children[2].dataset.visible, undefined);
assert.equal(home.textContent, "Águilas (LOCAL)");
assert.equal(away.textContent, "Ñandú (VISITA)");

replay.update(33.6, 2);
assert.equal(field.children[2].dataset.visible, "false");
assert.equal(field.dataset.tacticalMinute, "33");
assert.ok(ball.style.left.endsWith("%"));
assert.ok(trail.points.includes(","));
assert.equal(ball.style.transitionDuration, "0ms",
  "Entre fotogramas se usa interpolación continua");

replay.update(34, 1);
assert.equal(field.dataset.tacticalMinute, "34");
assert.equal(title.textContent, "ESTADO: ¡GOL!");
assert.equal(field.children[2].dataset.visible, "true");
assert.match(field.children[2].textContent, /Águilas/);

replay.update(34.6, 1);
assert.equal(field.children[2].dataset.visible, "false");
assert.equal(title.textContent, "ESTADO: CELEBRACIÓN");

replay.update(90, 1);
assert.equal(field.dataset.tacticalMinute, "90");
assert.equal(title.textContent, "ESTADO: FINAL DEL PARTIDO");
console.log("OK: replay realista, pases, presión, disparos, goles reales y control de minutos.");
