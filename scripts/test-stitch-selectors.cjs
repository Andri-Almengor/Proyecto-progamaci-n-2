// Pruebas de regresión del panel de administración y el cuadro en vivo.
// No requieren servidor, navegador, MySQL ni librerías externas.
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const root = path.resolve(__dirname, "..");
const js = fs.readFileSync(path.join(root, "web/js/stitch-runtime.js"), "utf8");
const entry = js.lastIndexOf('  if (document.readyState === "loading")');
assert.ok(entry > 0, "La inicialización de Stitch cambió; ajustar la prueba");
const source = js.slice(0, entry) +
  "  window.__arenaTest = { drawAdmin, updateLiveBracket };\n})();\n";

function element() {
  return {
    dataset: {}, children: [], style: {}, innerHTML: "", textContent: "",
    classList: { add() {}, remove() {}, toggle() {}, contains() { return false; } },
    querySelector() { return null; }, querySelectorAll() { return []; },
    addEventListener() {}, appendChild(child) { this.children.push(child); },
    setAttribute() {}
  };
}

const sections = Array.from({ length: 4 }, element);
const summaryCards = Array.from({ length: 4 }, element);
sections[0].querySelectorAll = (selector) =>
  selector === ":scope > div" ? summaryCards : [];
sections[2].children = [element(), element()];
let matchCards = [];
const main = element();
main.querySelectorAll = (selector) =>
  selector === "[data-real-match-id]" ? matchCards : [];
const document = {
  body: { dataset: { arenaPage: "admin" } },
  querySelector: (selector) => selector === "main" ? main : null,
  querySelectorAll: (selector) => selector === "main section" ? sections : [],
  createTreeWalker: () => ({ nextNode: () => false }),
  createElement: element
};
const window = { ARENA_BASE: "/BracketArena" };
vm.runInNewContext(source, {
  window, document, NodeFilter: { SHOW_TEXT: 4 },
  console, URL, Blob, setTimeout, clearTimeout
}, { filename: "stitch-runtime.js" });

const payload = {
  tournament: null, approved: 4, finalized: 0,
  matches: [], teams: [], csrf: "test", live: {}
};
assert.doesNotThrow(() => window.__arenaTest.drawAdmin(payload),
  "Administración debe renderizar sin usar .filter sobre un Element");
assert.match(summaryCards[0].innerHTML, /Inscripción Oficial/);
assert.match(sections[2].children[1].innerHTML, /AÚN NO HAY TORNEO ACTIVO/);

// Una transmisión actualiza ambos equipos y el marcador del cuadro público.
function row() {
  const node = element();
  node.label = element();
  node.pill = element();
  node.querySelector = (selector) =>
    selector === "span.truncate" ? node.label :
    selector === ".score-pill" ? node.pill : null;
  return node;
}
const card = element();
const rows = [row(), row()];
const status = element();
card.dataset.realMatchId = "12";
card.querySelectorAll = (selector) => selector === ".team-row" ? rows : [];
card.querySelector = (selector) =>
  selector === "div.flex.items-center.justify-between span" ? status : null;

const compact = element();
compact.dataset.realMatchId = "13";
const compactNames = [element(), element()];
const compactScores = [element(), element()];
compact.querySelectorAll = (selector) =>
  selector === ".team-row" ? [] :
  selector === "span.truncate" ? compactNames :
  selector === ".score-pill" ? compactScores : [];
compact.querySelector = () => null;

matchCards = [card, compact];
const data = { matches: [
  { id: 12, aId: 1, bId: 2, aName: "Águilas", bName: "Leones",
    scoreA: 1, scoreB: 2, winnerId: 2, done: false, live: true,
    round: 1, position: 1, ready: true },
  { id: 13, aId: 3, bId: 4, aName: "Café", bName: "Ñandú",
    scoreA: 3, scoreB: 0, winnerId: 3, done: true, live: false,
    round: 1, position: 2, ready: true }
] };
assert.doesNotThrow(() => window.__arenaTest.updateLiveBracket(data),
  "Cuadro debe iterar la colección de tarjetas y actualizar las filas");
assert.equal(rows[0].label.textContent, "Águilas");
assert.equal(rows[1].pill.textContent, "2");
assert.match(status.textContent, /EN VIVO/);
assert.equal(compactNames[1].textContent, "Ñandú");
assert.equal(compactScores[0].textContent, "3");

// Validar archivos UTF-8 reales; un archivo fuente corrupto no llega al WAR.
const views = path.join(root, "web/WEB-INF/views/arena");
function verifyUtf8(directory) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const full = path.join(directory, entry.name);
    if (entry.isDirectory()) { verifyUtf8(full); continue; }
    if (!/\.(jsp|jspf)$/.test(entry.name)) continue;
    const decoded = new TextDecoder("utf-8", { fatal: true })
      .decode(fs.readFileSync(full));
    assert.doesNotMatch(decoded, /(?:Ã[¡-¿]|Â[¡-¿]|\uFFFD)/,
      "Posible texto corrupto en " + full);
  }
}
verifyUtf8(views);
assert.doesNotMatch(js, /(?:Ã[¡-¿]|Â[¡-¿]|\uFFFD)/);
console.log("OK: panel administrativo, cuadro en vivo y vistas UTF-8.");
