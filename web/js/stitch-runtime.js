/* Integración de las páginas HTML originales exportadas de Stitch.
 * Las plantillas y sus clases se conservan; las cifras proceden de /arena-data.
 * Nunca se muestran equipos, resultados ni tarjetas ficticios como datos oficiales. */
(() => {
  "use strict";
  const base = window.ARENA_BASE || "";
  const page = document.body.dataset.arenaPage;
  const $ = (q, root = document) => root?.querySelector(q) || null;
  const $$ = (q, root = document) =>
    Array.from(root?.querySelectorAll(q) || []);
  const go = (view, more = "") => `${base}/app?view=${view}${more}`;
  const esc = (s) =>
    String(s == null ? "" : s).replace(
      /[&<>"']/g,
      (c) =>
        ({
          "&": "&amp;",
          "<": "&lt;",
          ">": "&gt;",
          '"': "&quot;",
          "'": "&#39;",
        })[c],
    );
  const number = (x) => Number(x || 0).toLocaleString("es-CR");
  const short = (name) =>
    String(name || "?")
      .split(/\s+/)
      .slice(0, 2)
      .map((w) => w[0] || "")
      .join("")
      .toUpperCase()
      .slice(0, 3);
  const selected = (s) => s || "Por definir";
  const ink = (s) =>
    `<span class="font-title-sm text-title-sm font-bold text-on-surface">${esc(s)}</span>`;
  const state = { data: null, filter: 3 };
  const section = (i) => $(`[data-original-section="${i}"]`);
  const note = (
    text,
    title = "LAS ESTADÍSTICAS ESTARÁN DISPONIBLES AL INICIAR EL TORNEO",
  ) =>
    `<div class="arena-empty-state"><div class="arena-empty-icon"><span class="material-symbols-outlined">analytics</span></div><strong>${esc(title)}</strong><p>${esc(text)}</p></div>`;
  /** Formatea fechas del servidor para la región de Costa Rica. */
  function requestDate(s) {
    if (!s) return "Fecha por definir";
    let [y, m, d] = s.split("-");
    return `${d}/${m}/${y}`;
  }
  /** Muestra un estado de error recuperable sin dejar una página vacía. */
  function bannerError(text) {
    const main = $("main");
    if (main)
      main.innerHTML = `<div class="mx-auto max-w-3xl p-10">${note(text, "NO SE PUDIERON CARGAR LOS DATOS DEL TORNEO")}<a href="${go("inicio")}" class="arena-action">Reintentar</a></div>`;
  }
  /** Retira los skeletons y muestra las secciones en cascada. */
  function reveal() {
    document.body.classList.remove("arena-loading");
    document.body.classList.add("arena-ready");
    const all = $$("main > div > section, main section, main > div > div");
    const seen = new Set();
    let i = 0;
    for (const el of all) {
      if (seen.has(el) || (!el.matches("section") && i > 12)) continue;
      seen.add(el);
      el.classList.add("arena-stagger");
      el.style.animationDelay = `${Math.min(i, 11) * 65}ms`;
      i++;
    }
    $("#arena-skeleton")?.setAttribute("aria-busy", "false");
    window.setTimeout(() => $("#arena-skeleton")?.remove(), 650);
  }
  /** Actualiza enlaces y permisos visibles de la barra de navegación. */
  function decorateNav(d) {
    const header = $("body > header");
    if (!header) return;
    $$("a", header).forEach((a) => {
      const text = a.textContent.toLowerCase().replace(/\s+/g, " ").trim();
      if (text.includes("inicio")) a.href = go("inicio");
      else if (text.includes("cuadro")) a.href = go("cuadro");
      else if (text.includes("equipos")) a.href = go("equipos");
      else if (text.includes("panel admin")) {
        a.href = go("admin");
        if (!d.user?.admin) a.classList.add("hidden");
      }
    });
    // El prototipo incorporaba un nombre fijo; lo sustituimos por la sesión real.
    const walker = document.createTreeWalker(header, NodeFilter.SHOW_TEXT);
    const texts = [];
    while (walker.nextNode()) texts.push(walker.currentNode);
    texts.forEach((node) => {
      if (node.textContent.includes("Alex Mercer"))
        node.textContent = node.textContent.replace(
          "Alex Mercer",
          d.user?.name || "Visitante",
        );
      if (node.textContent.includes("Sesión Activa"))
        node.textContent = node.textContent.replace(
          "Sesión Activa",
          d.user ? d.user.role : "Sin iniciar sesión",
        );
      if (node.textContent.includes("Copa Premier 2026"))
        node.textContent = node.textContent.replace(
          "Copa Premier 2026",
          d.tournament?.name || "Sin torneo activo",
        );
    });
    // El rótulo del torneo de Stitch tiene datos de demostración: reemplazar toda la línea, no solo su nombre.
    const ticker = $$(".font-label-md", header).find(
      (el) =>
        el.classList.contains("truncate") &&
        el.textContent.includes("En Premios"),
    );
    if (ticker) {
      const t = d.tournament;
      ticker.innerHTML = t
        ? `<span class="text-secondary-fixed">${esc(t.name)}</span> · 16 EQUIPOS · PREMIO ₡ ${number(t.prize)} · ${d.finalized}/15 PARTIDOS · FINALIZACIÓN ${requestDate(t.end)}`
        : '<span class="text-secondary-fixed">BRACKET ARENA 2026</span> · SIN TORNEO ACTIVO · LAS ESTADÍSTICAS APARECERÁN AL INICIAR EL TORNEO';
    }
    const roleSelect = $("select", header);
    if (roleSelect) {
      roleSelect.innerHTML = `<option value="${d.user?.role || "VISITANTE"}">${d.user?.role || "VISITANTE"}</option>`;
      roleSelect.disabled = true;
      roleSelect.setAttribute("aria-label", "Rol de la sesión actual");
    }
    const badge = $$("span", header).find(
      (el) => el.children.length === 0 && el.textContent.trim() === "En Vivo",
    );
    if (badge)
      badge.textContent =
        d.tournament?.status === "ACTIVO"
          ? "EN CURSO"
          : d.tournament?.status === "FINALIZADO"
            ? "FINALIZADO"
            : "SIN TORNEO";
    const server = $$("span", header).find(
      (el) =>
        el.children.length === 0 &&
        el.textContent.trim() === "SERVIDORES ONLINE",
    );
    if (server) server.textContent = "DATOS ACTUALIZADOS";
    // El selector "Usuario" del prototipo funciona como acceso a la sesión real.
    $$("button", header).forEach((b) => {
      if (
        b.textContent.includes("Usuario") ||
        b.textContent.includes("Visitante")
      ) {
        b.addEventListener("click", () => {
          location.href = d.user ? go("equipos") : go("login");
        });
      }
    });
    // Modo visual original: Monolith y Obsidian. La selección persiste en el navegador.
    $$("button", header).forEach((b) => {
      const text = b.textContent.toLowerCase();
      if (text.includes("monolith"))
        b.addEventListener("click", () => setTheme("light"));
      if (text.includes("obsidian"))
        b.addEventListener("click", () => setTheme("dark"));
    });
    setTheme(
      localStorage.getItem("arena-theme") === "dark" ? "dark" : "light",
      false,
    );
    const alert = d.user ? null : null;
    if (d.user) {
      const group = header.querySelector("nav");
      if (group && !$("[data-arena-logout]", header)) {
        const f = document.createElement("form");
        f.method = "POST";
        f.action = base + "/app";
        f.className = "arena-logout";
        f.dataset.arenaLogout = "";
        f.innerHTML = `<input type="hidden" name="csrf" value="${esc(d.csrf)}"><input type="hidden" name="action" value="logout"><button type="submit" aria-label="Cerrar sesión">Salir</button>`;
        group.appendChild(f);
      }
    }
  }
  /** Aplica el tema visual definido por la interfaz original. */
  function setTheme(mode, save = true) {
    document.documentElement.classList.toggle("dark", mode === "dark");
    document.documentElement.classList.toggle("light", mode !== "dark");
    if (save) localStorage.setItem("arena-theme", mode);
  }
  function locateText(root, needle) {
    return $$("span,p,small,strong,div", root).filter(
      (e) =>
        e.children.length === 0 &&
        e.textContent.toLowerCase().includes(needle.toLowerCase()),
    );
  }
  /** Rellena el encabezado con la edición activa, año y premio reales. */
  function headline(label, numberText, description = "") {
    return `<div class="arena-headline" aria-live="polite"><strong>${esc(label)}</strong><span>${esc(numberText)}</span><small>${esc(description)}</small></div>`;
  }
  /** Resume los goles y faltas de los reportes disponibles. */
  function totalStats(matches) {
    return matches.filter((m) => m.done && m.report);
  }
  /** Construye campos de inscripción con el token CSRF del servidor. */
  function teamForm(a, logo) {
    return `<div class="arena-team-symbol">${esc(short(a))}</div>${ink(a)}`;
  }
  function finalTeamStats(teamId, d) {
    if (!teamId) return null;
    const games = d.matches.filter(
      (m) => m.done && m.report && (m.aId === teamId || m.bId === teamId),
    );
    if (!games.length) return null;
    let possession = 0,
      on = 0,
      shots = 0;
    for (const m of games) {
      const a = m.aId === teamId;
      const h = m.report.total;
      possession += a ? h.possessionA : h.possessionB;
      on += a ? h.onA : h.onB;
      shots += a ? h.shotsA : h.shotsB;
    }
    return {
      possession: Math.round(possession / games.length),
      accuracy: shots ? Math.round((100 * on) / shots) : 0,
      games: games.length,
    };
  }
  /** Pinta inicio y las estadísticas globales del torneo. */
  function drawHome(d) {
    const t = d.tournament;
    const meta = section(0),
      hero = section(1),
      kpis = section(2),
      final = section(3),
      feat = section(4),
      leaders = section(5),
      cta = section(6);
    if (hero) {
      const h = $("h1", hero);
      if (h)
        h.textContent = t
          ? t.name.toUpperCase()
          : "EL TORNEO ESTÁ POR COMENZAR";
      const ps = $$("p", hero);
      if (ps[0])
        ps[0].textContent = t
          ? "TORNEO " + t.status + " · TEMPORADA 2026"
          : "TEMPORADA 2026 · PRÓXIMA EDICIÓN";
      if (ps[1])
        ps[1].textContent = t
          ? `Torneo de eliminación directa entre 16 equipos. ${d.finalized} de 15 encuentros disputados. Consultá los resultados y el avance de las llaves.`
          : "Cuando se cree el primer torneo, aquí aparecerán los equipos participantes, la ruta hacia la final y todas las estadísticas.";
      const links = $$("a", hero);
      if (links[0]) links[0].href = go("cuadro");
      if (links[1]) links[1].href = "#resultados-recientes";
      // La imagen de la copa y el diseño negro de Stitch permanecen exactamente igual.
      const content = hero.textContent || "";
      const whiteNodes = locateText(hero, "COPA PREMIER 2026");
      whiteNodes.forEach((n) => {
        if (n.tagName !== "H1") n.textContent = t ? t.name : "Esperando torneo";
      });
      for (const n of locateText(hero, "12 / 15"))
        n.textContent = `${d.finalized} / 15 PARTIDOS`;
      for (const n of locateText(hero, "15 OCT - 30 NOV"))
        n.textContent = t
          ? `${requestDate(t.start)} - ${requestDate(t.end)}`
          : "PENDIENTE";
      for (const n of locateText(hero, "5,000,000 CRC"))
        n.textContent = t ? "₡ " + number(t.prize) + " CRC" : "PENDIENTE";
      for (const n of locateText(hero, "3.5M al Campeón"))
        n.textContent = t
          ? "Premio: ₡ " + number(t.prize)
          : "Premio por definir";
      for (const n of locateText(hero, "Copa Premier 2026"))
        n.textContent = t ? t.name : "Bracket Arena 2026";
      for (const n of locateText(hero, "SEMIFINALES CONCLUIDAS"))
        n.textContent = t
          ? `TORNEO ${t.status} · ${d.finalized}/15 JUGADOS`
          : "AÚN NO HAY TORNEO";
      for (const n of locateText(hero, "OFICIAL FCRF"))
        n.textContent = "EDICIÓN 2026 · ELIMINACIÓN DIRECTA";
      for (const n of locateText(hero, "GRAN FINAL"))
        if (n.textContent.trim() === "GRAN FINAL")
          n.textContent = t
            ? ["OCTAVOS", "CUARTOS", "SEMIFINALES", "GRAN FINAL"][
                [1, 2, 3, 4].findIndex((r) =>
                  d.matches.some((m) => m.round === r && !m.done),
                )
              ] || "TORNEO FINALIZADO"
            : "POR COMENZAR";
      const roundNames = ["Octavos", "Cuartos", "Semis"];
      for (let r = 1; r <= 3; r++)
        for (const n of locateText(hero, roundNames[r - 1] + ":")) {
          if (n.textContent.includes("/"))
            n.textContent = `${roundNames[r - 1]}: ${d.matches.filter((m) => m.round === r && m.done).length}/${d.matches.filter((m) => m.round === r).length || [8, 4, 2][r - 1]}`;
        }
      const progress = $('div[style*="width: 80%"]', hero);
      if (progress)
        progress.style.width =
          (t ? Math.round((d.finalized / 15) * 100) : 0) + "%";
    }
    if (meta) {
      const txt = meta.querySelector("div");
      if (txt) {
        const children = locateText(txt, "EDICIÓN NACIONAL");
        children.forEach(
          (e) =>
            (e.textContent = t
              ? "EDICIÓN 2026"
              : "EDICIÓN 2026 · INSCRIPCIONES"),
        );
      }
    }
    if (kpis) {
      const cards = $$("div.grid > div", kpis);
      const part = t ? 16 : d.approved;
      const values = [
        [part, "Equipos clasificados"],
        [t ? 15 : 0, "Partidos programados"],
        [
          d.finalized,
          `${t ? Math.round((d.finalized / 15) * 100) : 0}% de avance · ${t ? 15 - d.finalized : 0} encuentros restantes`,
        ],
        [
          d.totalGoals,
          `${d.finalized ? (d.totalGoals / d.finalized).toFixed(2) : "0"} goles por encuentro`,
        ],
      ];
      cards.slice(0, 4).forEach((card, i) => {
        const p = $$("p", card);
        if (p.length > 1) p[1].textContent = number(values[i][0]);
        if (p.length > 2) p[2].textContent = values[i][1];
      });
    }
    if (final) {
      if (!t) {
        final.firstElementChild.innerHTML = `<div class="arena-section-heading"><span>EL COMBATE POR EL TÍTULO</span><h2>LA GRAN FINAL NACIONAL</h2></div>${note("Al iniciar el torneo y avanzar las eliminatorias, aquí verás a los finalistas y el resultado de la gran final.")}`;
      } else {
        const m = d.matches.find((m) => m.round === 4);
        const names = [m?.aName, m?.bName];
        const teamIds = [m?.aId, m?.bId];
        const heads = $$("h3", final);
        heads.slice(0, 2).forEach((h, i) => {
          h.textContent = selected(names[i]).toUpperCase();
          const side =
            h.closest(".lg\\:col-span-5") || h.closest('[class*="col-span-5"]');
          if (side) {
            const paragraphs = $$("p", side);
            const score = d.scorers.filter((s) => s.teamId === teamIds[i])[0];
            if (paragraphs[0])
              paragraphs[0].textContent = score
                ? `Goleador: ${score.player} (${score.goals} goles simulados)`
                : "Sin goles individuales registrados";
            const nums = $$("div", side).filter(
              (e) =>
                e.children.length === 0 && e.textContent.includes("VICTORIAS"),
            );
            nums.forEach(
              (e) =>
                (e.textContent = `${d.matches.filter((x) => x.done && x.winnerId === teamIds[i]).length} victorias en el torneo`),
            );
            const stat = finalTeamStats(teamIds[i], d);
            const labels = locateText(side, "58.4%").concat(
              locateText(side, "61.2%"),
              locateText(side, "42.1%"),
              locateText(side, "46.8%"),
            );
            labels.forEach((e) => {
              e.textContent = e.textContent.includes("EFECTIVIDAD")
                ? `${stat?.accuracy ?? "—"}%`
                : `${stat?.possession ?? "—"}%`;
            });
            const bars = $$('div[style*="width"]', side);
            if (stat && bars[0]) bars[0].style.width = stat.possession + "%";
            if (stat && bars[1]) bars[1].style.width = stat.accuracy + "%";
          }
        });
        const date = locateText(final, "DOMINGO 20:00 CST");
        date.forEach((e) => (e.textContent = requestDate(t.end)));
        const stadium = locateText(final, "Estadio Nacional de Costa Rica");
        stadium.forEach((e) => (e.textContent = "Fecha final del torneo"));
        const broadcast = locateText(final, "TRANSMISIÓN NACIONAL FHD");
        broadcast.forEach(
          (e) =>
            (e.textContent = m?.done
              ? "PARTIDO FINALIZADO"
              : "PARTIDO POR DISPUTARSE"),
        );
        const btn = $("button", final);
        if (btn) {
          btn.disabled = !m?.done;
          btn.addEventListener(
            "click",
            () => m?.done && (location.href = go("partido", `&id=${m.id}`)),
          );
        }
        const counter = locateText(final, "CUENTA REGRESIVA");
        counter.forEach((e) => (e.textContent = "FECHA DE FINALIZACIÓN"));
        const score = locateText(final, "02 D");
        score.forEach((e) => (e.textContent = requestDate(t.end)));
        if (m?.done) {
          const target = $("h2", final)?.parentElement;
          if (target) {
            const chip = document.createElement("p");
            chip.className = "arena-champion";
            chip.textContent = `🏆 CAMPEÓN: ${t.championName}`;
            target.appendChild(chip);
          }
        }
      }
    }
    drawFeatured(d, feat);
    drawLeaders(d, leaders);
    if (cta) {
      const p = $("h2", cta)?.parentElement.querySelector("p");
      if (p)
        p.textContent =
          t?.status === "ACTIVO"
            ? "Las inscripciones de esta edición están cerradas. Seguile la pista a los 16 equipos participantes y consultá los resultados."
            : "Registrá tu equipo para participar en la siguiente edición. El administrador deberá aprobar tu inscripción.";
      const button = $("button", cta);
      if (button)
        button.addEventListener("click", () => (location.href = go("equipos")));
      const a = $("a", cta);
      if (a) a.href = d.user?.admin ? go("admin") : go("login");
    }
    // Detalles de campeonato ficticios que el proyecto no registra no deben afirmarse.
    const footerSection = section(7);
    if (footerSection) {
      const headers = $$("h4", footerSection);
      const replacements = [
        [
          "Eliminación directa",
          "16 equipos, 4 rondas y un solo campeón. Cada partido clasificará a un ganador.",
        ],
        [
          "Equipos aprobados",
          "El administrador revisa las solicitudes y habilita la participación antes de iniciar la copa.",
        ],
        [
          "Reportes de partido",
          "Las simulaciones guardan estadísticas ficticias por tiempo y cronologías; no son métricas deportivas reales.",
        ],
      ];
      headers.slice(0, 3).forEach((h, i) => {
        h.textContent = replacements[i][0];
        const p = h.parentElement.parentElement.querySelector("p");
        if (p) p.textContent = replacements[i][1];
      });
    }
  }
  /** Lista enfrentamientos destacados según el avance real de las llaves. */
  function drawFeatured(d, sec) {
    if (!sec) return;
    const grid = $("div.grid", sec);
    if (!grid) return;
    const rounds = [3, 2, 1, 4];
    let selectedRound = rounds.find((r) =>
      d.matches.some((m) => m.round === r && m.done),
    );
    if (!selectedRound) selectedRound = 3;
    function fill(round) {
      const done = d.matches
        .filter((m) => m.round === round && m.done)
        .sort((a, b) => b.position - a.position);
      const shown = done.slice(0, 4);
      if (!d.tournament) {
        grid.innerHTML = note(
          "Al iniciar el torneo se mostrarán los encuentros y sus resultados.",
        );
        return;
      }
      if (!shown.length) {
        grid.innerHTML = note(
          "Todavía no hay resultados registrados para esta ronda.",
          "AÚN NO HAY ENFRENTAMIENTOS FINALIZADOS",
        );
        return;
      }
      grid.innerHTML = shown
        .map(
          (
            m,
          ) => `<article class="bg-surface rounded-xl p-space-md lg:p-space-lg shadow-md arena-feature-card"><div class="flex justify-between items-center mb-space-md font-label-sm text-label-sm uppercase"><span>● ${["", "Octavos", "Cuartos", "Semifinal", "Final"][m.round]} ${m.position} · FINALIZADO</span><span class="text-on-surface-variant">Partido #${m.id}</span></div>
      ${[0, 1].map((i) => `<div class="arena-score-row ${i ? "alt" : ""}"><div class="flex items-center gap-space-md min-w-0"><span class="arena-mini-crest">${esc(short(i ? m.bName : m.aName))}</span><div class="truncate"><strong class="font-title-sm text-title-sm uppercase">${esc(i ? m.bName : m.aName)}</strong><small class="block text-on-surface-variant">${m.winnerId === (i ? m.bId : m.aId) ? "Clasificado" : "Eliminado"}</small></div></div><strong class="font-headline-lg text-headline-lg">${i ? m.scoreB : m.scoreA}</strong></div>`).join("")}
      <div class="arena-event-summary">${esc(
        (m.report?.events || [])
          .filter((e) => e.type === "GOL")
          .slice(0, 4)
          .map((e) => `${e.minute}' ${e.player}`)
          .join(" · ") || "Sin goles individuales disponibles",
      )}</div>
      <div class="arena-feature-actions"><a href="${go("partido", `&id=${m.id}&play=1`)}" class="text-secondary"><span class="material-symbols-outlined text-sm">play_circle</span> VER REPLAY ANIMADO</a><a class="arena-stats-link" href="${go("partido", `&id=${m.id}`)}">ESTADÍSTICAS COMPLETAS</a></div></article>`,
        )
        .join("");
    }
    fill(selectedRound);
    const buttons = $$("button", sec).filter((b) =>
      /semifinales|cuartos|octavos/i.test(b.textContent),
    );
    buttons.forEach((b) => {
      const n = /semi/i.test(b.textContent)
        ? 3
        : /cuartos/i.test(b.textContent)
          ? 2
          : 1;
      b.addEventListener("click", () => {
        fill(n);
        buttons.forEach((el) => {
          el.classList.remove("bg-primary", "text-on-primary");
          el.classList.add("bg-surface-container");
        });
        b.classList.add("bg-primary", "text-on-primary");
        b.classList.remove("bg-surface-container");
      });
    });
    const h = sec.querySelector("h2");
    if (h) h.textContent = "ENFRENTAMIENTOS DESTACADOS";
  }
  /** Genera la clasificación de goleadores desde los eventos almacenados. */
  function drawLeaders(d, sec) {
    if (!sec) return;
    const cards = $$("div.grid > div", sec);
    const scorerBox = cards[0],
      disciplineBox = cards[1];
    if (scorerBox) {
      const tbody = $("tbody", scorerBox);
      if (tbody) {
        tbody.innerHTML = !d.tournament
          ? `<tr><td colspan="6">${note("Las estadísticas de goleadores aparecerán cuando se inicie el torneo.")}</td></tr>`
          : !d.scorers.length
            ? `<tr><td colspan="6">${note("Todavía no se han registrado goles en los partidos jugados.", "SIN GOLES INDIVIDUALES")}</td></tr>`
            : d.scorers
                .slice(0, 8)
                .map(
                  (s, i) =>
                    `<tr class="bg-surface-container-lowest hover:bg-surface-container-low transition-colors"><td class="py-2.5 px-3 font-bold text-secondary">${String(i + 1).padStart(2, "0")}</td><td class="py-2.5 px-3 font-title-sm text-title-sm uppercase">${esc(s.player)}</td><td class="py-2.5 px-3 text-on-surface-variant">${esc(s.team)}</td><td class="py-2.5 px-3 text-center">${s.matches}</td><td class="py-2.5 px-3 text-center font-bold">${s.goals}</td><td class="py-2.5 px-3 text-right font-label-sm text-label-sm">${s.matches ? (s.goals / s.matches).toFixed(2) : "—"} G/P</td></tr>`,
                )
                .join("");
      }
      const p = locateText(scorerBox, "Actualizado al minuto");
      p.forEach(
        (el) =>
          (el.textContent = d.tournament
            ? `${d.finalized} de 15 partidos registrados · Goleadores simulados`
            : "Esperando el inicio de la competencia"),
      );
      const a = $("a", scorerBox);
      if (a) {
        a.href = go("equipos");
        a.textContent = "VER EQUIPOS →";
      }
    }
    if (disciplineBox) {
      const metrics = $$("div.grid > div", disciplineBox);
      metrics.forEach((metric, i) => {
        const numberEl = $("span", metric),
          label = metric.querySelectorAll("span")[1],
          noteEl = metric.querySelectorAll("span")[2];
        if (numberEl) numberEl.textContent = "—";
        if (label)
          label.textContent = i ? "TARJETAS ROJAS" : "TARJETAS AMARILLAS";
        if (noteEl) noteEl.textContent = "Sin registros de tarjetas";
      });
      const last = disciplineBox.querySelector("p");
      if (last)
        last.textContent = d.tournament
          ? `${number(d.totalFouls)} faltas simuladas contabilizadas en ${d.finalized} partidos. Las tarjetas aún no se registran en la base de datos.`
          : "Las estadísticas disciplinarias estarán disponibles cuando inicie el torneo.";
      const header = locateText(disciplineBox, "SAPRISSA (1 GOL RECIBIDO)");
      header.forEach(
        (el) =>
          (el.textContent = d.tournament
            ? "FALTAS REGISTRADAS: " + number(d.totalFouls)
            : "SIN DATOS"),
      );
      const bottom = locateText(disciplineBox, "0 SANCIONES PENDIENTES");
      bottom.forEach((el) => (el.textContent = "SIN SISTEMA DE SANCIONES"));
    }
  }
  /** Dibuja las 15 posiciones y resultados del cuadro eliminatorio. */
  function drawBracket(d) {
    const main = $("main"),
      stage = $("#bracket-stage"),
      viewport = $("#bracket-viewport");
    const title = $$("h1,h2", main).find((e) =>
      /copa|gran|cuadro/i.test(e.textContent),
    );
    if (title)
      title.textContent = d.tournament
        ? `${d.tournament.name} — CUADRO ELIMINATORIO`
        : "CUADRO ELIMINATORIO — 2026";
    const coords = {
      "M-OCT-L1": [1, 1],
      "M-OCT-L2": [1, 2],
      "M-OCT-L3": [1, 3],
      "M-OCT-L4": [1, 4],
      "M-OCT-R1": [1, 5],
      "M-OCT-R2": [1, 6],
      "M-OCT-R3": [1, 7],
      "M-OCT-R4": [1, 8],
      "M-QF-L1": [2, 1],
      "M-QF-L2": [2, 2],
      "M-QF-R1": [2, 3],
      "M-QF-R2": [2, 4],
      "M-SF-A": [3, 1],
      "M-SF-B": [3, 2],
      "M-GRAND-FINAL": [4, 1],
    };
    if (!d.tournament) {
      if (stage) {
        stage.classList.add("hidden");
        const el = document.createElement("div");
        el.className = "arena-bracket-empty";
        el.innerHTML = note(
          "Cuando el administrador inicie un torneo de 16 equipos, el cuadro se completará automáticamente.",
        );
        stage.parentElement.insertBefore(el, stage);
      }
    } else {
      for (const card of $$("[data-match-id]", main)) {
        const spec = coords[card.dataset.matchId];
        if (!spec) continue;
        const m = d.matches.find(
          (x) => x.round === spec[0] && x.position === spec[1],
        );
        if (!m) continue;
        card.dataset.realMatchId = String(m.id);
        card.dataset.t1 = m.aName || "Por definir";
        card.dataset.t2 = m.bName || "Por definir";
        card.dataset.s1 = m.scoreA == null ? "—" : String(m.scoreA);
        card.dataset.s2 = m.scoreB == null ? "—" : String(m.scoreB);
        card.dataset.winner =
          m.winnerId === m.aId
            ? m.aName
            : m.winnerId === m.bId
              ? m.bName
              : "Por definir";
        card.dataset.date = "Fecha no programada";
        card.dataset.stadium = "Ubicación no registrada";
        card.classList.toggle("arena-match-pending", !m.done);
        const first = $$(".team-row", card);
        if (first.length >= 2) {
          [0, 1].forEach((side) => {
            const row = first[side],
              name = side ? m.bName : m.aName,
              teamId = side ? m.bId : m.aId,
              score = side ? m.scoreB : m.scoreA;
            row.dataset.team = name || "Por definir";
            const label = $$("span", row).find((x) =>
              x.classList.contains("truncate"),
            );
            if (label) label.textContent = name || "Por definir";
            const badge = $$("span", row).find((x) =>
              x.classList.contains("shrink-0"),
            );
            if (badge) badge.textContent = teamId ? short(name) : "·";
            const pill = $(".score-pill", row);
            if (pill) pill.textContent = m.done ? String(score) : "—";
            row.classList.toggle(
              "arena-bracket-winner",
              !!m.done && m.winnerId === teamId,
            );
            row.classList.toggle(
              "arena-bracket-loser",
              !!m.done && m.winnerId !== teamId,
            );
          });
        } else if (spec[0] === 4) {
          const nameSpans = $$("span.truncate", card);
          if (nameSpans[0]) nameSpans[0].textContent = m.aName || "Por definir";
          if (nameSpans[1]) nameSpans[1].textContent = m.bName || "Por definir";
          $$(".score-pill", card).forEach(
            (x, i) =>
              (x.textContent = m.done ? String(i ? m.scoreB : m.scoreA) : "—"),
          );
        }
        const header = $("div.flex.items-center.justify-between span", card);
        if (header)
          header.textContent = `${["", "OCTAVOS", "CUARTOS", "SEMIFINAL", "GRAN FINAL"][m.round]} ${m.position} • ${m.done ? "FINALIZADO" : m.ready ? "LISTO" : "PENDIENTE"}`;
        const last = $("div.mt-1,div.mt-2", card);
        if (last && spec[0] === 3)
          last.innerHTML = `<span class="text-secondary">${m.done ? "Clasificado: " + esc(card.dataset.winner) : "Camino a la final"}</span><span>${m.done ? "90\u2032" : "Por jugar"}</span>`;
        card.setAttribute("tabindex", "0");
        card.setAttribute("role", "button");
        card.addEventListener("click", () => openMatchDrawer(m, card));
        card.addEventListener("keydown", (e) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            openMatchDrawer(m, card);
          }
        });
      }
      // Suprimimos fechas y sedes ficticias del ejemplo que no existen en MySQL.
      $$(".stage-col", main).forEach((col) => {
        const elements = locateText(col, "Mar")
          .concat(locateText(col, "Sáb"))
          .concat(locateText(col, "Miércoles"));
        elements.forEach((e) => {
          if (e.textContent.length < 60)
            e.textContent = "Pendiente de programación";
        });
      });
    }
    let zoom = 1;
    const zoomLabel = $("#zoom-level");
    const doZoom = (n) => {
      zoom = Math.max(0.6, Math.min(1.4, n));
      if (stage) stage.style.transform = `scale(${zoom})`;
      if (zoomLabel) zoomLabel.textContent = `${Math.round(zoom * 100)}%`;
    };
    $("#zoom-in")?.addEventListener("click", () => doZoom(zoom + 0.1));
    $("#zoom-out")?.addEventListener("click", () => doZoom(zoom - 0.1));
    $("#zoom-reset")?.addEventListener("click", () => doZoom(1));
    let scores = true;
    $("#toggle-scores")?.addEventListener("click", () => {
      scores = !scores;
      $$(".score-pill", main).forEach((e) => {
        if (!scores) {
          e.dataset.original = e.textContent;
          e.textContent = "—";
        } else e.textContent = e.dataset.original || "—";
      });
      const label = $("#scores-label");
      if (label)
        label.textContent = scores
          ? "Ocultar Marcadores (Modo Spoiler)"
          : "Mostrar Marcadores";
    });
    const input = $("#bracket-search");
    input?.addEventListener("input", () => {
      const q = input.value.toLowerCase().trim();
      $$("[data-match-id]", main).forEach((el) =>
        el.classList.toggle(
          "opacity-30",
          !!q &&
            !(el.dataset.t1 || "").toLowerCase().includes(q) &&
            !(el.dataset.t2 || "").toLowerCase().includes(q),
        ),
      );
      $("#clear-search")?.classList.toggle("hidden", !q);
    });
    $("#clear-search")?.addEventListener("click", () => {
      input.value = "";
      input.dispatchEvent(new Event("input"));
    });
    $$(".filter-btn").forEach((btn) =>
      btn.addEventListener("click", () => {
        const stageFilter = btn.dataset.filter;
        $$(".filter-btn").forEach((b) =>
          b.classList.toggle("arena-filter-active", b === btn),
        );
        $$(".stage-col").forEach((el) => {
          const filtered =
            stageFilter !== "all" && el.dataset.stage !== stageFilter;
          el.style.opacity = filtered ? ".25" : "1";
          el.style.filter = filtered ? "grayscale(100%)" : "none";
        });
      }),
    );
    $("#btn-export-bracket")?.addEventListener("click", () => exportBracket(d));
    $("#close-drawer")?.addEventListener("click", closeDrawer);
    $("#drawer-backdrop")?.addEventListener("click", closeDrawer);
  }
  function closeDrawer() {
    $("#match-drawer")?.classList.add("translate-x-full");
    $("#drawer-backdrop")?.classList.add("hidden");
  }
  /** Muestra el detalle del partido seleccionado desde datos persistidos. */
  function openMatchDrawer(m, card) {
    const drawer = $("#match-drawer"),
      backdrop = $("#drawer-backdrop");
    if (!drawer) return;
    const fields = {
      "#drawer-match-code": `PARTIDO ${m.position}`,
      "#drawer-stage-badge": [
        "",
        "OCTAVOS DE FINAL",
        "CUARTOS DE FINAL",
        "SEMIFINAL",
        "GRAN FINAL",
      ][m.round],
      "#drawer-team-1": m.aName || "Por definir",
      "#drawer-team-2": m.bName || "Por definir",
      "#drawer-score-1": m.done ? m.scoreA : "—",
      "#drawer-score-2": m.done ? m.scoreB : "—",
      "#drawer-winner": m.done ? card.dataset.winner : "Por definir",
      "#drawer-stadium": "Sede no registrada",
    };
    Object.entries(fields).forEach(([q, value]) => {
      const e = $(q);
      if (e) e.textContent = String(value);
    });
    // El contenido de los eventos y comparativas del drawer proviene de los mismos datos persistidos.
    const timeline = $$("span", drawer)
      .find((e) => e.textContent.includes("14' GOL"))
      ?.closest(".space-y-2");
    if (timeline) {
      timeline.innerHTML = m.report?.events?.length
        ? m.report.events
            .map(
              (e) =>
                `<div class="flex justify-between gap-2 border-b border-outline py-2 text-[11px]"><span class="text-secondary font-bold">${e.minute}' ${e.type}</span><span>${esc(e.player)} · ${esc(e.team)}</span></div>`,
            )
            .join("")
        : `<p class="p-3 text-sm">${m.done ? "No hay eventos disponibles" : "Este encuentro todavía no ha iniciado."}</p>`;
    }
    const numbers = $$("div.font-bold", drawer).filter(
      (e) =>
        e.textContent.includes("58%") ||
        e.textContent.includes("9 vs 3") ||
        e.textContent.includes("11 vs 14"),
    );
    const stats = m.report?.total;
    if (stats)
      numbers.forEach((el, i) => {
        const val =
          i === 0
            ? `${stats.possessionA}% vs ${stats.possessionB}%`
            : i === 1
              ? `${stats.onA} vs ${stats.onB}`
              : `${stats.foulsA} vs ${stats.foulsB}`;
        el.textContent = val;
      });
    const replay = $("#btn-replay-sim"),
      details = $("#btn-view-stats");
    if (replay) {
      replay.disabled = !m.done;
      replay.onclick = () =>
        (location.href = go("partido", `&id=${m.id}&play=1`));
    }
    if (details) {
      details.disabled = !m.done;
      details.innerHTML =
        '<span class="material-symbols-outlined text-[16px]">query_stats</span> Ver estadísticas completas';
      details.onclick = () => (location.href = go("partido", `&id=${m.id}`));
    }
    drawer.classList.remove("translate-x-full");
    backdrop?.classList.remove("hidden");
  }
  /** Exporta una representación del cuadro visible. */
  function exportBracket(d) {
    const matches = d.matches;
    if (!matches.length) return;
    const escSvg = (s) =>
      String(s || "").replace(
        /[&<>"']/g,
        (x) =>
          ({
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;",
            '"': "&quot;",
            "'": "&apos;",
          })[x],
      );
    const roundW = 260,
      gap = 15;
    let blocks = "";
    for (let round = 1; round <= 4; round++)
      for (const m of matches.filter((x) => x.round === round)) {
        const x = 25 + (round - 1) * (roundW + gap),
          y =
            70 +
            (m.position - 1) * (88 * 2 ** (round - 1)) +
            44 * (2 ** (round - 1) - 1);
        blocks += `<g><rect x="${x}" y="${y}" width="260" height="73" fill="#fff" stroke="#111827"/><text x="${x + 9}" y="${y + 17}" font-size="11" fill="#d97706">RONDA ${round} · ${m.position}</text><text x="${x + 9}" y="${y + 37}" font-size="12" fill="#111827">${escSvg((m.aName || "Por definir").slice(0, 29))} ${m.scoreA ?? "—"}</text><text x="${x + 9}" y="${y + 55}" font-size="12" fill="#111827">${escSvg((m.bName || "Por definir").slice(0, 29))} ${m.scoreB ?? "—"}</text></g>`;
      }
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="1160" height="900" viewBox="0 0 1160 900"><rect width="1160" height="900" fill="#f9fafb"/><text x="25" y="37" font-size="25" font-family="sans-serif" font-weight="bold">${escSvg(d.tournament?.name || "Bracket Arena")} · 2026</text>${blocks}</svg>`;
    const url = URL.createObjectURL(
      new Blob([svg], { type: "image/svg+xml;charset=utf-8" }),
    );
    const a = document.createElement("a");
    a.href = url;
    a.download = "bracket-arena-2026.svg";
    a.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }
  /** Presenta controles de administración según el rol de usuario. */
  function drawAdmin(d) {
    const sections = $$("main section");
    const panel = sections[0],
      batch = sections[1],
      management = sections[2],
      registry = sections[3];
    const active = d.tournament?.status === "ACTIVO";
    const adminWalker = document.createTreeWalker(
        $("main"),
        NodeFilter.SHOW_TEXT,
      ),
      adminText = [];
    while (adminWalker.nextNode()) adminText.push(adminWalker.currentNode);
    adminText.forEach((n) => {
      n.textContent = n.textContent
        .replace(
          /COPA PREMIER 2026/g,
          d.tournament?.name || "Sin torneo activo",
        )
        .replace(/Hash: 88F4-CP25-LIVE/g, "DATOS PERSISTIDOS EN MYSQL")
        .replace(
          /Cuadro Bloqueado \(16\/16 Seeds\)/g,
          d.tournament ? "Cuadro generado (16 equipos)" : "Sin cuadro generado",
        );
    });
    const badges = panel ? $$(":scope > div", panel) : [];
    const summaries = [
      [
        "Inscripción Oficial",
        `${active ? 16 : d.approved} / 16`,
        `${d.approved} equipos aprobados`,
      ],
      [
        "Partidos Disputados",
        `${d.finalized} / 15`,
        `${Math.round((d.finalized / 15) * 100)}% del cuadro`,
      ],
      [
        "Partidos Pendientes",
        `${d.tournament ? 15 - d.finalized : 0}`,
        d.tournament ? "Encuentros restantes" : "Esperando primer torneo",
      ],
      [
        "Estado del Torneo",
        d.tournament?.status || "SIN TORNEO",
        d.tournament?.name || "Crea tu primer torneo",
      ],
    ];
    badges.slice(0, 4).forEach((card, i) => {
      card.innerHTML = `<div class="flex justify-between items-start"><span class="font-label-md text-label-md uppercase text-on-surface-variant">${summaries[i][0]}</span><span class="material-symbols-outlined text-secondary">${["verified", "scoreboard", "pending_actions", "bolt"][i]}</span></div><strong class="font-headline-lg text-headline-lg text-primary mt-3">${esc(summaries[i][1])}</strong><span class="font-body-sm text-body-sm text-on-surface-variant mt-2">${esc(summaries[i][2])}</span>`;
    });
    // Habilitamos «Nuevo torneo» solamente cuando no existe uno activo.
    const btn = $$("button", document).find((e) =>
      /Nuevo Torneo/i.test(e.textContent),
    );
    if (btn) {
      btn.disabled = active;
      btn.classList.toggle("opacity-50", active);
      btn.classList.toggle("cursor-not-allowed", active);
      if (!active)
        btn.addEventListener("click", () => (location.href = go("crear")));
    }
    if (batch) {
      const b = $("#open-batch-sim-modal");
      if (b) b.disabled = !active;
      b?.addEventListener("click", () =>
        $("#batch-sim-modal")?.classList.remove("hidden"),
      );
      const modal = $("#batch-sim-modal");
      if (modal) {
        $("#close-batch-sim-modal")?.addEventListener("click", () =>
          modal.classList.add("hidden"),
        );
        modal.addEventListener("click", (ev) => {
          if (ev.target === modal) modal.classList.add("hidden");
        });
        const buttonConfirm = $("#confirm-batch-sim");
        if (buttonConfirm) {
          buttonConfirm.addEventListener("click", () => {
            if (
              !window.confirm(
                "¿Confirmás que querés simular definitivamente todos los encuentros pendientes?",
              )
            )
              return;
            submit("tournament.simulateAll", {}, d.csrf);
          });
        }
      }
    }
    if (management) {
      // La estructura y los encabezados exportados de Stitch se preservan;
      // solo reemplazamos el listado de partidas de ejemplo por formularios reales.
      const content = management.children[1];
      if (content) {
        if (!d.tournament) {
          content.innerHTML = note(
            "Crea un torneo con exactamente 16 equipos aprobados para poder gestionar sus encuentros.",
            "AÚN NO HAY TORNEO ACTIVO",
          );
        } else {
          content.innerHTML = [1, 2, 3, 4]
            .map((round) => {
              const matches = d.matches.filter((m) => m.round === round);
              const cards = matches
                .map((m) => {
                  const stage = [
                    "",
                    "OCTAVOS",
                    "CUARTOS",
                    "SEMIFINAL",
                    "GRAN FINAL",
                  ][round];
                  return `<div class="bg-surface rounded p-space-md shadow-sm flex flex-col justify-between gap-space-md arena-admin-match" data-admin-round="${round}">
            <div class="flex justify-between items-center"><span class="font-label-sm text-label-sm uppercase tracking-widest text-on-surface-variant">LLAVE ${stage}-${m.position}</span><span class="font-label-sm text-label-sm bg-surface-container-high px-2 py-1">${m.done ? "FINALIZADO" : m.ready ? "LISTO" : "PENDIENTE"}</span></div>
            <div class="arena-admin-score"><div>${esc(m.aName || "Por definir")}</div><strong>${m.scoreA ?? "—"} : ${m.scoreB ?? "—"}</strong><div>${esc(m.bName || "Por definir")}</div></div>
            ${
              m.done
                ? `<a class="arena-action-secondary" href="${go("partido", `&id=${m.id}`)}"><span class="material-symbols-outlined text-sm">receipt_long</span> Ver ficha técnica</a>`
                : m.ready
                  ? `<form method="post" action="${base}/app" class="arena-admin-result"><input type="hidden" name="csrf" value="${esc(d.csrf)}"><input type="hidden" name="action" value="match.result"><input type="hidden" name="matchId" value="${m.id}"><div><label>Goles local <input type="number" min="0" max="999" name="scoreA" value="0" required></label><label>Goles visitante <input type="number" min="0" max="999" name="scoreB" value="0" required></label></div><button type="submit" class="arena-action-secondary">✓ Confirmar resultado y avanzar</button></form>
              <form method="post" action="${base}/app" class="arena-admin-result" data-sim-form><input type="hidden" name="csrf" value="${esc(d.csrf)}"><input type="hidden" name="action" value="match.simulate"><input type="hidden" name="matchId" value="${m.id}"><button class="arena-action" type="submit">⚡ Simular este partido</button></form>`
                  : `<p class="text-on-surface-variant text-sm">Esperando clasificados de la ronda anterior.</p>`
            }
            </div>`;
                })
                .join("");
              return `<div class="arena-admin-group" data-round-group="${round}"><div class="arena-admin-group-title"><strong>${["", "Ronda 1: Octavos de final", "Ronda 2: Cuartos de final", "Ronda 3: Semifinales", "Ronda 4: Gran final"][round]}</strong><small>${matches.filter((m) => m.done).length}/${matches.length} disputados</small></div><div class="grid grid-cols-1 lg:grid-cols-2 gap-space-md">${cards}</div></div>`;
            })
            .join("");
          $$("[data-sim-form]", content).forEach((f) =>
            f.addEventListener("submit", (e) => {
              if (
                !confirm("Este resultado simulado será definitivo. ¿Continuar?")
              )
                e.preventDefault();
            }),
          );
          $$(".arena-admin-result", content)
            .filter((f) => !f.matches("[data-sim-form]"))
            .forEach((f) =>
              f.addEventListener("submit", (e) => {
                const a = Number(f.elements.scoreA.value),
                  b = Number(f.elements.scoreB.value);
                if (
                  !Number.isInteger(a) ||
                  !Number.isInteger(b) ||
                  a === b ||
                  a < 0 ||
                  b < 0 ||
                  a > 999 ||
                  b > 999
                ) {
                  alert("No se permiten empates ni marcadores inválidos.");
                  e.preventDefault();
                } else if (
                  !confirm(
                    "El marcador será definitivo y el ganador avanzará automáticamente. ¿Confirmás?",
                  )
                )
                  e.preventDefault();
              }),
            );
        }
      }
      $$(".stage-btn", management).forEach((b) =>
        b.addEventListener("click", () => {
          const text = b.textContent.toLowerCase();
          let r = text.includes("octavos")
            ? 1
            : text.includes("cuartos")
              ? 2
              : text.includes("semi")
                ? 3
                : text.includes("final")
                  ? 4
                  : 0;
          $$("[data-round-group]", management).forEach(
            (group) =>
              (group.hidden = !!r && Number(group.dataset.roundGroup) !== r),
          );
          $$(".stage-btn", management).forEach((x) =>
            x.classList.toggle("arena-filter-active", x === b),
          );
        }),
      );
    }
    if (registry) {
      const table = $("#teams-registry-table");
      const tbody = $("tbody", table);
      if (tbody) {
        tbody.innerHTML = d.teams.length
          ? d.teams
              .map(
                (
                  team,
                ) => `<tr class="hover:bg-surface-container-low transition-colors" data-team-row="${esc(team.status)}">
      <td class="p-space-md"><div class="flex items-center gap-space-sm"><div class="arena-mini-crest">${esc(short(team.name))}</div><div class="font-title-sm text-title-sm">${esc(team.name)}</div></div></td>
      <td class="p-space-md text-on-surface-variant">${esc(team.owner)}</td>
      <td class="p-space-md">${esc(team.phone)}</td>
      <td class="p-space-md"><span class="status-badge font-label-sm text-label-sm uppercase bg-surface-container-high px-2 py-1">${esc(team.status)}</span></td>
      <td class="p-space-md text-right">${team.status === "PENDIENTE" ? `<form action="${base}/app" method="post" class="arena-status-actions"><input type="hidden" name="csrf" value="${esc(d.csrf)}"><input type="hidden" name="teamId" value="${team.id}"><button type="submit" name="action" value="team.approve">Aprobar</button><button type="submit" name="action" value="team.reject">Rechazar</button></form>` : '<span class="text-on-surface-variant">Registrado</span>'}</td></tr>`,
              )
              .join("")
          : `<tr><td colspan="5">${note("No hay equipos inscritos en esta edición.", "SIN EQUIPOS REGISTRADOS")}</td></tr>`;
      }
    }
  }
  /** Envía operaciones al servlet usando POST y el token CSRF. */
  function submit(action, values, csrf) {
    const f = document.createElement("form");
    f.method = "POST";
    f.action = base + "/app";
    Object.entries({ action, csrf, ...values }).forEach(([name, value]) => {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = name;
      input.value = String(value);
      f.appendChild(input);
    });
    document.body.appendChild(f);
    f.submit();
  }
  /** Renderiza tiempos, eventos y estadísticas del partido. */
  function drawMatch(d) {
    const qs = new URLSearchParams(location.search),
      id = Number(qs.get("id"));
    const m = d.matches.find((x) => x.id === id);
    if (!m) {
      bannerError(
        "El encuentro solicitado no existe en el torneo más reciente.",
      );
      return;
    }
    const main = $("main");
    if (!m.done || !m.report) {
      main.innerHTML = `<div class="max-w-4xl mx-auto py-20 px-margin">${note("El encuentro todavía no tiene marcador. Cuando se registre el resultado, podrás consultar el replay y sus estadísticas.", "PARTIDO TODAVÍA NO DISPUTADO")}<a href="${go("cuadro")}" class="arena-action">Volver al cuadro</a></div>`;
      return;
    }
    const a = m.aName,
      b = m.bName;
    // Conservar el DOM/posición de Stitch, reemplazando los equipos de muestra.
    const replacers = [
      [/COPA PREMIER 2026/gi, d.tournament?.name || "Torneo 2026"],
      [/DEPORTIVO SAPRISSA/gi, a],
      [/DEP\. SAPRISSA/gi, a],
      [/SAPRISSA/gi, a],
      [/L\.D\. ALAJUELENSE/gi, b],
      [/LD ALAJUELENSE/gi, b],
      [/ALAJUELENSE/gi, b],
      [/SEMIFINAL #2/gi, `RONDA ${m.round} · PARTIDO ${m.position}`],
      [/SEM 01/gi, "LOCAL"],
      [/SEM 02/gi, "VISITA"],
      [/ESTADIO NACIONAL CRC/gi, "SEDE NO REGISTRADA"],
    ];
    const walker = document.createTreeWalker(main, NodeFilter.SHOW_TEXT),
      texts = [];
    while (walker.nextNode()) texts.push(walker.currentNode);
    texts.forEach((node) => {
      let text = node.textContent;
      for (const [pat, replacement] of replacers)
        text = text.replace(pat, () => replacement);
      node.textContent = text;
    });
    const scoreA = $("#score-home"),
      scoreB = $("#score-away");
    if (scoreA) scoreA.textContent = String(m.scoreA);
    if (scoreB) scoreB.textContent = String(m.scoreB);
    // Los autores de Stitch mostraban supuestos nombres de goleadores y un estadio;
    // reemplazamos estos datos por la cronología que está almacenada en MySQL.
    const header = section(0);
    if (header) {
      const badge = locateText(header, "REGISTRO OFICIAL ID");
      badge.forEach((el) => (el.textContent = `PARTIDO ID #${m.id}`));
      const eventSummary = $$("div", header).filter(
        (el) => el.children.length === 0 && el.textContent.includes("Goles"),
      );
      eventSummary.forEach((el) => {
        const goals = m.report.events.filter((e) => e.type === "GOL");
        el.textContent = goals.length
          ? goals.map((e) => `${e.player} ${e.minute}'`).join(" · ")
          : "Sin anotaciones";
      });
    }
    const tick = $("#ticker-feed");
    if (tick) {
      tick.innerHTML = "";
    }
    const eventRows = (m.report.events || []).map((e) => {
      const icon = e.type === "GOL" ? "sports_soccer" : "sync",
        word = e.type === "GOL" ? "GOL" : "Sustitución";
      return `<div class="arena-live-event" data-event-minute="${e.minute}"><span class="arena-event-minute">${e.minute}'</span><span class="material-symbols-outlined text-secondary text-lg">${icon}</span><div><strong>${word} · ${esc(e.team)}</strong><small>${e.type === "GOL" ? esc(e.player) : `Sale ${esc(e.outgoing)} · Entra ${esc(e.player)}`}</small></div></div>`;
    });
    if (tick)
      tick.innerHTML =
        eventRows.join("") ||
        note("Sin eventos para este partido.", "SIN EVENTOS");
    const moments = m.report.events.filter((e) => e.type === "GOL").slice(0, 4);
    const goalsInHeader = $$("div", section(0)).find(
      (el) =>
        el.classList?.contains("flex") && el.textContent.includes("Goles"),
    );
    if (goalsInHeader && goalsInHeader.textContent.length > 30) {
      $$("p", goalsInHeader).forEach(
        (el) =>
          (el.textContent =
            moments.map((e) => `${e.player} ${e.minute}'`).join(" · ") ||
            "Sin goles"),
      );
    }
    const stats = section(2);
    if (stats) {
      const p = $$("p", stats).find((e) =>
        e.textContent.includes("Métricas oficiales"),
      );
      if (p)
        p.textContent =
          "Estadísticas ilustrativas generadas por la simulación y guardadas en MySQL; no son mediciones reales del partido.";
      const labels = locateText(stats, "Deportivo Saprissa").concat(
        locateText(stats, "LD Alajuelense"),
      );
      labels.forEach((x, i) => (x.textContent = i % 2 === 0 ? a : b));
    }
    const tabButtons = $$("button", stats).filter((b) =>
      /primer tiempo|segundo tiempo|partido completo/i.test(b.textContent),
    );
    const statNames = [
      ["pos", "possessionA", "possessionB"],
      ["atk", "dangerousA", "dangerousB"],
      ["pass", "passesA", "passesB"],
      ["shots", "shotsA", "shotsB"],
      ["ontarget", "onA", "onB"],
      ["corners", "cornersA", "cornersB"],
      ["fouls", "foulsA", "foulsB"],
    ];
    function chooseHalf(which) {
      const half =
        which === 1
          ? m.report.first
          : which === 2
            ? m.report.second
            : m.report.total;
      if (!half) return;
      for (const [id, ka, kb] of statNames) {
        const aVal = half[ka] ?? 0,
          bVal = half[kb] ?? 0,
          total = aVal + bVal,
          left = total ? Math.round((aVal / total) * 100) : 50;
        const home = $(`#stat-${id}-home`),
          away = $(`#stat-${id}-away`);
        if (home) home.textContent = `${aVal}${id === "pos" ? "%" : ""}`;
        if (away) away.textContent = `${bVal}${id === "pos" ? "%" : ""}`;
        const barA = $(`#bar-${id}-home`),
          barB = $(`#bar-${id}-away`);
        if (barA) barA.style.width = left + "%";
        if (barB) barB.style.width = 100 - left + "%";
      }
      // No guardamos efectividad de pases en el modelo actual: no inventar porcentajes.
      const passHome = $("#stat-pass-home-sub"),
        passAway = $("#stat-pass-away-sub");
      if (passHome) passHome.textContent = "(pases estimados)";
      if (passAway) passAway.textContent = "(pases estimados)";
      tabButtons.forEach((b, i) => {
        b.classList.toggle("arena-filter-active", i === which - 1);
        b.setAttribute("aria-pressed", String(i === which - 1));
      });
    }
    tabButtons.forEach((b, i) =>
      b.addEventListener("click", () => chooseHalf(i + 1)),
    );
    chooseHalf(3);
    // Progresión estrictamente visual de 0 a 90, nunca altera la BD.
    let minute = 90,
      timer = null,
      speed = 1;
    const clock = $("#clock-display"),
      period = $("#clock-period"),
      progress = $("#sim-progress-bar"),
      ball = $("#ball-actor");
    function updateClock() {
      if (clock) clock.textContent = `${String(minute).padStart(2, "0")}:00`;
      if (period)
        period.textContent =
          minute <= 45 ? "1T" : minute < 90 ? "2T" : "FINALIZADO";
      if (progress) progress.style.width = (minute / 90) * 100 + "%";
      if (ball) {
        ball.style.left = `${13 + (Math.sin(minute / 9) * 0.5 + 0.5) * 72}%`;
        ball.style.top = `${20 + (Math.cos(minute / 5) * 0.5 + 0.5) * 55}%`;
      }
      if (scoreA)
        scoreA.textContent = String(
          m.report.events.filter(
            (e) => e.type === "GOL" && e.side === "A" && e.minute <= minute,
          ).length,
        );
      if (scoreB)
        scoreB.textContent = String(
          m.report.events.filter(
            (e) => e.type === "GOL" && e.side === "B" && e.minute <= minute,
          ).length,
        );
      $$("[data-event-minute]", tick).forEach((el) => {
        const show = Number(el.dataset.eventMinute) <= minute;
        el.classList.toggle("arena-event-future", !show);
      });
    }
    function pause() {
      if (timer) clearInterval(timer);
      timer = null;
      const label = $("#btn-play-label");
      if (label) label.textContent = minute === 90 ? "Reproducir" : "Continuar";
    }
    function play(reset = false) {
      if (timer) return;
      if (reset || minute >= 90) minute = 0;
      const label = $("#btn-play-label");
      if (label) label.textContent = "Reproduciendo";
      updateClock();
      timer = setInterval(() => {
        minute = Math.min(90, minute + 1);
        updateClock();
        if (minute >= 90) {
          pause();
          chooseHalf(3);
        } else if (minute === 46) chooseHalf(2);
      }, 450 / speed);
    }
    $("#btn-play")?.addEventListener("click", () => play());
    $("#btn-pause")?.addEventListener("click", pause);
    $("#btn-reset")?.addEventListener("click", () => {
      pause();
      minute = 0;
      chooseHalf(1);
      updateClock();
    });
    $("#btn-jump")?.addEventListener("click", () => {
      pause();
      minute = 90;
      updateClock();
      chooseHalf(3);
      stats?.scrollIntoView({ behavior: "smooth" });
    });
    $$("button", section(1))
      .filter((b) => /^[12]X$/.test(b.textContent.trim()))
      .forEach((b) =>
        b.addEventListener("click", () => {
          speed = parseInt(b.textContent, 10) || 1;
          const running = !!timer;
          if (running) {
            pause();
            play();
          }
        }),
      );
    const heat = $("#toggle-heatmap");
    if (heat)
      heat.addEventListener("click", () => {
        const layer = $("#heatmap-overlay");
        if (layer) layer.classList.toggle("hidden");
        heat.textContent = layer?.classList.contains("hidden")
          ? "Zonas de Calor: OFF"
          : "Zonas de Calor: ON";
      });
    // Etiquetar datos ficticios permanentemente, incluso si el usuario omite la animación.
    const first = section(0);
    if (first) {
      const disclaimer = document.createElement("p");
      disclaimer.className = "arena-simulation-note";
      disclaimer.textContent =
        "Este partido utiliza estadísticas simuladas. Los números de jugador, minutos y cambios son ilustrativos; el marcador guardado es el resultado del torneo.";
      first.appendChild(disclaimer);
    }
    updateClock();
    if (
      new URLSearchParams(location.search).get("play") === "1" &&
      !window.matchMedia("(prefers-reduced-motion: reduce)").matches
    ) {
      play(true);
    }
    window.addEventListener("pagehide", pause);
  }
  /** Actualiza catálogo y estado de aprobación de los equipos. */
  function drawTeams(d) {
    const list = $("#arena-teams-list");
    if (list) {
      const teams = d.teams;
      list.innerHTML = teams.length
        ? teams
            .map(
              (t) =>
                `<div class="arena-team-card"><div class="arena-team-symbol">${esc(short(t.name))}</div><div><strong>${esc(t.name)}</strong><p>Responsable: ${esc(t.owner)}</p><small>${esc(t.status)} ${t.participant ? "· PARTICIPANTE DEL TORNEO" : ""}</small></div></div>`,
            )
            .join("")
        : note("Aún no se ha inscrito ningún equipo.");
    }
    const form = $("#arena-team-form");
    if (form) {
      if (!d.user) {
        form.outerHTML =
          note(
            "Iniciá sesión para inscribir un equipo.",
            "SE REQUIERE UNA CUENTA",
          ) +
          `<a class="arena-action" href="${go("login")}">Iniciar sesión</a>`;
      } else if (d.tournament?.status === "ACTIVO") {
        form.outerHTML = note(
          "Las inscripciones se mantienen cerradas mientras el torneo está activo.",
          "INSCRIPCIONES CERRADAS",
        );
      } else {
        form.action = base + "/app";
        form.elements.csrf.value = d.csrf;
      }
    }
  }
  /** Activa los formularios de acceso y registro. */
  function drawAuth(d) {
    const form = $("#arena-auth-form");
    if (form) {
      form.action = base + "/app";
      form.elements.csrf.value = d.csrf;
    }
    if (d.user) {
      const main = $("main");
      main.innerHTML =
        note("Ya tenés una sesión activa.", "SESIÓN INICIADA") +
        `<a class="arena-action" href="${go("inicio")}">Regresar al inicio</a>`;
    }
  }
  /** Construye la pantalla de creación de torneo. */
  function drawCreate(d) {
    const form = $("#arena-create-form"),
      selection = $("#arena-create-team-list");
    if (!form) return;
    if (!d.user?.admin) {
      form.outerHTML = note("Necesitás permisos de administrador.");
      return;
    }
    if (d.tournament?.status === "ACTIVO") {
      form.outerHTML = note(
        "Finalizá el torneo actual antes de iniciar otro.",
        "YA HAY UN TORNEO ACTIVO",
      );
      return;
    }
    form.action = base + "/app";
    form.elements.csrf.value = d.csrf;
    const approved = d.teams.filter((x) => x.status === "APROBADO");
    if (selection)
      selection.innerHTML = approved.length
        ? approved
            .map(
              (t) =>
                `<label class="arena-team-option"><input type="checkbox" name="teamIds" value="${t.id}" checked><span class="arena-mini-crest">${esc(short(t.name))}</span><span>${esc(t.name)}</span></label>`,
            )
            .join("")
        : note("Necesitás 16 equipos aprobados.");
    form.addEventListener("submit", (e) => {
      if ($$('input[name="teamIds"]:checked', form).length !== 16) {
        e.preventDefault();
        alert("Seleccioná exactamente 16 equipos aprobados.");
        return;
      }
      if (form.elements.end.value < form.elements.start.value) {
        e.preventDefault();
        alert("La fecha final no puede ser anterior a la inicial.");
        return;
      }
      const msg = form.elements.autoSimulate.checked
        ? "Esto simulará de inmediato los 15 partidos y determinará al campeón. ¿Continuar?"
        : "Se creará el cuadro de eliminación con 16 equipos. ¿Continuar?";
      if (!confirm(msg)) e.preventDefault();
    });
  }
  /** Consulta /arena-data y activa la página y sus animaciones. */
  async function initialize() {
    try {
      const ctrl = new AbortController(),
        timeout = setTimeout(() => ctrl.abort(), 16000);
      let response;
      try {
        response = await fetch(`${base}/arena-data`, {
          credentials: "same-origin",
          signal: ctrl.signal,
          headers: { Accept: "application/json" },
        });
      } finally {
        clearTimeout(timeout);
      }
      const data = await response.json();
      if (!response.ok || !data.ok)
        throw new Error(data.error || "No fue posible consultar el torneo.");
      state.data = data;
      decorateNav(data);
      if (page === "home") drawHome(data);
      else if (page === "bracket") drawBracket(data);
      else if (page === "admin") drawAdmin(data);
      else if (page === "match") drawMatch(data);
      else if (page === "teams") drawTeams(data);
      else if (page === "auth") drawAuth(data);
      else if (page === "create") drawCreate(data);
    } catch (e) {
      console.error("Error cargando las estadísticas de torneo:", e);
      bannerError(
        e.name === "AbortError"
          ? "La base de datos tardó demasiado en responder. Intentá actualizar la página."
          : e.message,
      );
    } finally {
      reveal();
    }
  }
  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", initialize, { once: true });
  else initialize();
})();
