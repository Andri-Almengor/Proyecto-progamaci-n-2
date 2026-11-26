// Pruebas de pestañas móviles: octavos, cuartos, equipos, marcadores.
"use strict";
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const assert = require("node:assert/strict");
const root = path.resolve(__dirname, "..");
const sourceText = fs.readFileSync(path.join(root, "web/js/stitch-runtime.js"), "utf8");
const start = sourceText.lastIndexOf('  if (document.readyState === "loading")');
assert.ok(start > 0, "No se encontró el final del runtime");
const source = sourceText.slice(0, start) +
  "  window.mobileTest = { renderMobileBracket, setData: (data) => state.data = data };\n})();";
const viewport = { parentNode: { insertBefore(el) { mobile = el; } } };
let mobile = null;
function elem() {
  return {
    dataset: {}, innerHTML: "",
    setAttribute() {}, addEventListener(name, handler) { this[name] = handler; },
    querySelector() { return null; }
  };
}
const search = { value: "" };
const document = {
  body: { dataset: { arenaPage: "bracket" } },
  querySelector(query) {
    if (query === "#bracket-viewport") return viewport;
    if (query === "#arena-mobile-bracket") return mobile;
    if (query === "#bracket-search") return search;
    return null;
  },
  createElement: elem
};
const window = { ARENA_BASE: "/BracketArena" };
vm.runInNewContext(source, {
  window, document, URLSearchParams, location: { search: "?view=cuadro" }
}, { filename: "stitch-runtime.js" });
const data = {
  tournament: { name: "Prueba" },
  matches: [
    { id: 1, round: 1, position: 1, aId: 1, bId: 2,
      aName: "Águilas", bName: "Ñandú", scoreA: 2, scoreB: 1,
      winnerId: 1, done: true, live: false },
    { id: 2, round: 2, position: 1, aId: 1, bId: 4,
      aName: "Águilas", bName: "Lobos", scoreA: 0, scoreB: 0,
      winnerId: null, done: false, live: true }
  ]
};
window.mobileTest.setData(data);
window.mobileTest.renderMobileBracket(data);
assert.ok(mobile, "Debe crear el cuadro móvil");
assert.match(mobile.innerHTML, /Cuartos/);
assert.match(mobile.innerHTML, /Lobos/);
assert.match(mobile.innerHTML, /EN VIVO/);
mobile.click({ target: { closest(q) {
  return q === "[data-mobile-round]" ? {dataset:{mobileRound:"1"}} : null;
}}});
assert.match(mobile.innerHTML, /Ñandú/);
assert.match(mobile.innerHTML, /Finalizado/);
assert.doesNotMatch(mobile.innerHTML, /Lobos/);
search.value = "inexistente";
window.mobileTest.renderMobileBracket(data);
assert.match(mobile.innerHTML, /No hay partidos/);
console.log("OK: cuadro móvil por ronda, marcadores y búsqueda.");
