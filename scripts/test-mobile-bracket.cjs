// Etapa 2: validación de rondas móviles, búsqueda global, directo y spoiler.
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
  '  window.mobileTest = { renderMobileBracket, setData: (data) => state.data = data, ' +
  'setSpoiler: (enabled) => bracketScoresVisible = enabled };\n})();';

function setup(searchParams = "?view=cuadro") {
  let mobile = null;
  const viewport = { parentNode: { insertBefore(el) { mobile = el; } } };
  const search = { value: "" };
  function elem() {
    return {
      dataset: {}, innerHTML: "",
      setAttribute() {}, addEventListener(name, handler) { this[name] = handler; },
      querySelector() { return null; }
    };
  }
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
    window, document, URLSearchParams, location: { search: searchParams }
  }, { filename: "stitch-runtime.js" });
  return { mobile: () => mobile, search, api: window.mobileTest };
}

const data = {
  tournament: { name: "Prueba" },
  live: { mode: "LIVE", phase: "PLAYING", matchId: 2, minute: 37 },
  matches: [
    { id: 1, round: 1, position: 1, aId: 1, bId: 2,
      aName: "Águilas", bName: "Ñandú", scoreA: 2, scoreB: 1,
      winnerId: 1, done: true, live: false },
    { id: 2, round: 2, position: 1, aId: 1, bId: 4,
      aName: "Águilas", bName: "Lobos", scoreA: 0, scoreB: 0,
      winnerId: null, done: false, live: true },
    { id: 3, round: 3, position: 1, aId: null, bId: null,
      aName: "", bName: "", scoreA: null, scoreB: null,
      winnerId: null, done: false, live: false },
    { id: 4, round: 4, position: 1, aId: null, bId: null,
      aName: "", bName: "", scoreA: null, scoreB: null,
      winnerId: null, done: false, live: false }
  ]
};
function event(query, attr, value) {
  return { target: { closest(q) {
    return q === query ? { dataset: { [attr]: value } } : null;
  } } };
}
const env = setup();
env.api.setData(data);
env.api.renderMobileBracket(data);
const mobile = env.mobile();
assert.ok(mobile, "Debe crear el cuadro móvil");
assert.match(mobile.innerHTML, /Cuartos/);
assert.match(mobile.innerHTML, /data-mobile-match="2"/);
assert.match(mobile.innerHTML, /EN VIVO/);
assert.match(mobile.innerHTML, /37'/);
assert.match(mobile.innerHTML, /Progreso del torneo/);
assert.match(mobile.innerHTML, /1 de 4 partidos/);
assert.match(mobile.innerHTML, /aria-selected="true"/);
assert.match(mobile.innerHTML, /data-mobile-live="true"/);

mobile.click(event("[data-mobile-round]", "mobileRound", "1"));
assert.match(mobile.innerHTML, /Ñandú/);
assert.match(mobile.innerHTML, /Finalizado/i);
assert.doesNotMatch(mobile.innerHTML, /data-mobile-match="2"/,
  "No deben mezclarse tarjetas de otras rondas si no hay búsqueda");

env.search.value = "AGUILAS"; // Búsqueda sin tilde: debe encontrar Águilas en dos rondas
env.api.renderMobileBracket(data);
assert.match(mobile.innerHTML, /Resultados en todas las rondas/);
assert.match(mobile.innerHTML, /data-mobile-match="1"/);
assert.match(mobile.innerHTML, /data-mobile-match="2"/);
env.search.value = "nandu"; // También encuentra Ñandú
env.api.renderMobileBracket(data);
assert.match(mobile.innerHTML, /data-mobile-match="1"/);
assert.doesNotMatch(mobile.innerHTML, /data-mobile-match="2"/);
env.search.value = "inexistente";
env.api.renderMobileBracket(data);
assert.match(mobile.innerHTML, /No hay equipos/);

mobile.click(event("[data-mobile-live]", "unused", "true"));
assert.equal(env.search.value, "", "Seguir el partido elimina filtros de búsqueda");
assert.match(mobile.innerHTML, /data-mobile-match="2"/);

env.api.setSpoiler(false);
env.api.renderMobileBracket(data);
assert.doesNotMatch(mobile.innerHTML, / · 0 a 0/,
  "No deben revelarse resultados en la descripción para lectores de pantalla");
assert.match(mobile.innerHTML, /arena-mobile-result">—<\/span>/);
env.api.setSpoiler(true);
env.api.renderMobileBracket(data);
assert.match(mobile.innerHTML, /arena-mobile-result">0<\/span>/);

let prevented = false;
mobile.keydown({
  key: "ArrowLeft",
  target: { closest(q) {
    return q === "[data-mobile-round]" ? {dataset:{mobileRound:"2"}} : null;
  } },
  preventDefault() { prevented = true; }
});
assert.ok(prevented, "Se debe permitir la navegación mediante teclado");
assert.match(mobile.innerHTML, /data-mobile-match="1"/);

const deep = setup("?view=cuadro&focusMatch=1");
deep.api.setData(data);
deep.api.renderMobileBracket(data);
assert.match(deep.mobile().innerHTML, /data-mobile-match="1"/);
assert.match(deep.mobile().innerHTML, /data-focused="true"/);
assert.doesNotMatch(deep.mobile().innerHTML, /data-mobile-match="2"/);

const empty = setup();
empty.api.setData({ tournament: null, matches: [] });
empty.api.renderMobileBracket({ tournament: null, matches: [] });
assert.match(empty.mobile().innerHTML, /CUADRO POR DEFINIR/,
  "No debe quedar una pantalla vacía antes de iniciar el torneo");

console.log("OK: etapa 2 móvil, búsqueda global, foco, spoiler, accesibilidad y vacío.");
