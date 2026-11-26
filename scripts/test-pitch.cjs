// Replay de cancha: 22 jugadores, balón, eventos y determinismo.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const js = fs.readFileSync(path.join(root, "web/js/arena-pitch.js"), "utf8");
assert.doesNotThrow(() => new vm.Script(js));
const window = {};
function node() {
  return {
    children: [], dataset: {}, style: {}, textContent: "", title: "",
    classList: { add() {} },
    appendChild(n) { this.children.push(n); },
    setAttribute(k, v) { this[k] = v; }
  };
}
const document = { createElement: node };
vm.runInNewContext(js, { window, document });
const API = window.ArenaPitch;
assert.ok(API);
const goals = [{ type: "GOL", side: "A", minute: 34, player: "Atacante" }];
for (const minute of [0, 1, 34, 45, 46, 77, 90]) {
  const f = API.frame(minute, 12, goals);
  assert.equal(f.players.length, 22);
  assert.equal(f.players.filter((x) => x.goalkeeper).length, 2);
  assert.equal(f.players.filter((x) => x.team === "A").length, 11);
  assert.equal(f.players.filter((x) => x.team === "B").length, 11);
  assert.ok(f.players.every((p) => p.x >= 5 && p.x <= 95 &&
    p.y >= 8 && p.y <= 92));
  assert.ok(f.ball.x >= 3 && f.ball.x <= 97);
  assert.equal(JSON.stringify(f), JSON.stringify(API.frame(minute, 12, goals)));
}
assert.equal(API.frame(34, 12, goals).action, "¡GOL!");
assert.equal(API.frame(34, 12, goals).ball.x, 97);
assert.equal(API.frame(34, 12, [{...goals[0], side: "B"}]).ball.x, 3);
assert.equal(API.frame(500, 12, []).minute, 90);
const ball = node(), trail = node(), title = node(), sub = node(),
  home = node(), away = node();
const selectors = {
  "#ball-actor": ball, "#ball-vector-trail": trail,
  "#tactical-state": title, "#tactical-substate": sub,
  "[data-pitch-home]": home, "[data-pitch-away]": away
};
const field = node();
field.querySelector = (q) => selectors[q] || null;
const visual = API.create(field, {
  id: 12, home: "Águilas", away: "Ñandú", events: goals
});
assert.equal(field.children[0].children.length, 22, "22 jugadores visibles");
assert.equal(field.children[1].children.length, 2, "leyenda de dos equipos");
assert.equal(home.textContent, "Águilas (LOCAL)");
assert.equal(away.textContent, "Ñandú (VISITA)");
visual.update(33, 1);
visual.update(34, 2);
assert.equal(field.dataset.tacticalMinute, "34");
assert.equal(title.textContent, "ESTADO: ¡GOL!");
assert.ok(ball.style.left.endsWith("%"));
assert.ok(String(trail.points).includes(","));
console.log("OK: cancha táctica, 22 jugadores, balón y goles sincronizados.");
