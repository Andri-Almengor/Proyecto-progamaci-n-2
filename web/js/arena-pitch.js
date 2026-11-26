/* BracketArena — replay táctico 2D (solo visual).
 * Los resultados y eventos reales del torneo vienen de /arena-data;
 * las posiciones ilustrativas NO se guardan en MySQL ni representan tracking real.
 */
(() => {
  "use strict";

  const FORMATION = [
    [8, 50],   // portero
    [24, 16], [21, 38], [21, 62], [24, 84], // defensas
    [41, 25], [38, 50], [41, 75],           // mediocampo
    [61, 20], [64, 50], [61, 80]            // delanteros
  ];
  const NUMBERS = [1, 2, 4, 5, 3, 6, 8, 10, 7, 9, 11];
  const clamp = (v, low, high) => Math.max(low, Math.min(high, v));
  const wave = (n) => Math.sin(n * 1.33) * Math.cos(n * .71);

  /** Fotograma determinista para permitir pausa, reinicio y salto sin aleatoriedad visual. */
  function frame(minute, seed, events) {
    const time = clamp(Math.floor(Number(minute) || 0), 0, 90);
    const id = Number(seed) || 1;
    const goals = (Array.isArray(events) ? events : []).filter(
      (e) => e.type === "GOL" && Number(e.minute) === time);
    const goal = goals[0];
    const side = goal?.side === "A" || goal?.side === "B"
      ? goal.side : (Math.floor((time + id % 5) / 6) % 2 === 0 ? "A" : "B");
    const attack = (time % 12) / 12;
    const players = [];
    for (let team = 0; team < 2; team++) {
      const home = team === 0;
      const hasBall = (home ? "A" : "B") === side;
      for (let i = 0; i < FORMATION.length; i++) {
        const [originX, originY] = FORMATION[i];
        const direction = home ? 1 : -1;
        const centerShift = i === 0 ? 0 : (hasBall ? 5 + attack * 10 : -5 + attack * 3);
        const jitterX = i === 0 ? 0 : wave(time * .49 + i * 2.1 + id) * 3.4;
        const jitterY = i === 0 ? 0 : wave(time * .57 + i * 1.31 + id) * 5.2;
        players.push({
          team: home ? "A" : "B", number: NUMBERS[i],
          goalkeeper: i === 0,
          x: clamp((home ? originX : 100 - originX) + direction * centerShift + jitterX, 5, 95),
          y: clamp(originY + jitterY, 8, 92)
        });
      }
    }
    // Posesión que pasa entre mediocampistas y delanteros, sin teletransportes.
    const slot = [5, 6, 7, 8, 9, 10][(time + id) % 6];
    let carrier = (side === "A" ? 0 : 11) + slot;
    let action = "CIRCULACIÓN DE BALÓN";
    let detail = "Pases y movimientos de apoyo";
    if (time === 0 || time === 46) {
      carrier = side === "A" ? 6 : 17;
      action = "SAQUE DE CENTRO";
      detail = "Comienza la posesión";
    } else if (time === 45) {
      action = "DESCANSO"; detail = "Finalizó la primera mitad";
    } else if (time === 90) {
      action = "FINAL DEL PARTIDO"; detail = "Resultado del torneo";
    } else if (time % 7 === 0) {
      action = "PRESIÓN ALTA"; detail = "Recuperación y avance de líneas";
    } else if (time % 5 === 0) {
      action = "CONTRAATAQUE"; detail = "Salida rápida por las bandas";
    } else if (time % 3 === 0) {
      action = "JUEGO POR BANDA"; detail = "Desmarque y pase al espacio";
    }
    if (time % 11 === 0 && time > 0 && time < 90) {
      action = "LLEGADA AL ÁREA"; detail = "Ataque cerca de la portería";
      carrier = (side === "A" ? 0 : 11) + 9;
      players[carrier].x = side === "A" ? 84 : 16;
      players[carrier].y = 50;
    }
    let ball = {
      x: clamp(players[carrier].x + (side === "A" ? 3.2 : -3.2), 3, 97),
      y: clamp(players[carrier].y + wave(time + id) * 3, 5, 95)
    };
    if (goal) {
      carrier = (side === "A" ? 0 : 11) + 9;
      players[carrier].x = side === "A" ? 88 : 12;
      players[carrier].y = 50;
      ball = { x: side === "A" ? 97 : 3, y: 50 };
      action = "¡GOL!";
      detail = "Anotación registrada en el minuto " + time;
    }
    return { minute: time, side, players, carrier, ball, action, detail, goal: !!goal };
  }

  /** Monta 22 fichas numeradas + balón sobre la cancha ya dibujada en JSP. */
  function create(field, options) {
    if (!field) return null;
    const config = options || {};
    const home = String(config.home || "Local");
    const away = String(config.away || "Visita");
    const layer = document.createElement("div");
    layer.className = "arena-pitch-player-layer";
    layer.setAttribute("aria-hidden", "true");
    const elements = [];
    for (let i = 0; i < 22; i++) {
      const player = document.createElement("div");
      player.className = "arena-pitch-player";
      player.dataset.team = i < 11 ? "A" : "B";
      player.dataset.goalkeeper = String(i % 11 === 0);
      player.textContent = String(NUMBERS[i % 11]);
      player.title = (i < 11 ? home : away) +
        " · Jugador #" + NUMBERS[i % 11] + " (posición simulada)";
      layer.appendChild(player);
      elements.push(player);
    }
    field.appendChild(layer);
    const legend = document.createElement("div");
    legend.className = "arena-pitch-legend";
    for (const name of [home, away]) {
      const span = document.createElement("span");
      span.textContent = name;
      legend.appendChild(span);
    }
    field.appendChild(legend);
    const ballNode = field.querySelector("#ball-actor");
    ballNode?.classList.add("arena-pitch-ball");
    const trail = field.querySelector("#ball-vector-trail");
    const title = field.querySelector("#tactical-state");
    const subtitle = field.querySelector("#tactical-substate");
    const homeLabel = field.querySelector("[data-pitch-home]");
    const awayLabel = field.querySelector("[data-pitch-away]");
    if (homeLabel) homeLabel.textContent = home + " (LOCAL)";
    if (awayLabel) awayLabel.textContent = away + " (VISITA)";
    let previousBall = null;
    let previousMinute = null;
    const events = Array.isArray(config.events) ? config.events : [];

    function update(minute, speed) {
      const current = frame(minute, config.id, events);
      const duration = clamp(Math.round(390 / (Number(speed) || 1)), 100, 440);
      for (let i = 0; i < elements.length; i++) {
        const player = elements[i];
        const position = current.players[i];
        player.style.left = position.x + "%";
        player.style.top = position.y + "%";
        player.style.transitionDuration = duration + "ms";
        player.dataset.active = String(i === current.carrier);
      }
      if (ballNode) {
        ballNode.style.left = current.ball.x + "%";
        ballNode.style.top = current.ball.y + "%";
        ballNode.style.transitionDuration = duration + "ms";
      }
      if (trail) {
        const from = previousBall && previousMinute !== null &&
          Math.abs(previousMinute - current.minute) === 1
          ? previousBall : current.ball;
        trail.setAttribute("points",
          (from.x * 10).toFixed(0) + "," + (from.y * 6).toFixed(0) + " " +
          (current.ball.x * 10).toFixed(0) + "," + (current.ball.y * 6).toFixed(0));
      }
      if (title) title.textContent = "ESTADO: " + current.action;
      if (subtitle) subtitle.textContent = current.detail;
      field.dataset.tacticalMinute = String(current.minute);
      previousBall = current.ball;
      previousMinute = current.minute;
      return current;
    }
    return { update };
  }
  window.ArenaPitch = { frame, create };
})();
