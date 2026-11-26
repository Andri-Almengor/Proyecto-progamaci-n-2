/* BracketArena — simulación táctica 2D, sin motor de físicas externo.
 * Reproduce movimiento ilustrativo de 22 jugadores, pases, presión y disparos.
 * SOLO los eventos GOL de /arena-data se muestran como anotaciones reales del torneo.
 * No modifica el resultado, las estadísticas guardadas ni la base de datos.
 */
(() => {
  "use strict";

  const FORMATION = [
    [8, 50],                                     // portero
    [23, 17], [20, 39], [20, 61], [23, 83],     // cuatro defensas
    [39, 24], [38, 50], [39, 76],               // tres mediocampistas
    [60, 20], [63, 50], [60, 80]                // tres delanteros
  ];
  const NUMBERS = [1, 2, 4, 5, 3, 6, 8, 10, 7, 9, 11];
  const clamp = (value, low, high) => Math.max(low, Math.min(high, value));
  const mix = (a, b, t) => a + (b - a) * t;
  const smooth = (t) => t * t * (3 - 2 * t);
  const wave = (n) => Math.sin(n * 1.33) * Math.cos(n * .71);
  const num = (n, fallback = 0) => Number.isFinite(Number(n)) ? Number(n) : fallback;

  function goalAt(minute, events) {
    return (Array.isArray(events) ? events : []).find((e) =>
      e.type === "GOL" && Number(e.minute) === minute &&
      (e.side === "A" || e.side === "B"));
  }

  function possession(minute, seed, events) {
    const goal = goalAt(minute, events);
    if (goal) return goal.side;
    if (minute <= 0) return "A";
    if (minute === 46) return "B";
    const block = Math.floor((minute + seed % 7) / 4);
    return (block + Math.floor(block / 3) + seed % 2) % 2 ? "B" : "A";
  }

  /** Fotograma de referencia de un minuto virtual. El gol solo ocurre si existe en MySQL. */
  function pose(minute, seed, events) {
    const id = Math.abs(Math.floor(num(seed, 1))) || 1;
    const time = clamp(Math.floor(num(minute)), 0, 90);
    const goal = goalAt(time, events);
    const side = possession(time, id, events);
    const previous = time > 0 ? possession(time - 1, id, events) : side;
    const recovered = previous !== side;
    const attackingA = side === "A";
    const direction = attackingA ? 1 : -1;
    const phase = (time % 12) / 12;
    const players = [];

    // Toda la formación avanza o retrocede como un bloque: no hay 22 recorridos aleatorios.
    for (let team = 0; team < 2; team++) {
      const home = team === 0;
      const ownsBall = home === attackingA;
      for (let i = 0; i < FORMATION.length; i++) {
        const [originX, originY] = FORMATION[i];
        const dir = home ? 1 : -1;
        const advance = i === 0 ? 0 : ownsBall ? 4 + phase * 8 : -3 + phase * 2;
        const variationX = i === 0 ? 0 : wave(time * .43 + i * 1.73 + id * .1) * 2.6;
        const variationY = i === 0 ? 0 : wave(time * .51 + i * 1.31 + id * .13) * 4;
        players.push({
          team: home ? "A" : "B", number: NUMBERS[i],
          goalkeeper: i === 0,
          x: clamp((home ? originX : 100 - originX) + dir * advance + variationX,
            i === 0 ? (home ? 5 : 89) : 5,
            i === 0 ? (home ? 11 : 95) : 95),
          y: clamp(originY + variationY, 8, 92)
        });
      }
    }

    const rotation = [5, 7, 6, 8, 9, 10, 7, 5, 9, 6];
    let index = rotation[(time + id) % rotation.length];
    let carrier = (attackingA ? 0 : 11) + index;
    let action = "PASE Y APOYO";
    let detail = "Circulación y desmarque entre líneas";
    if (time === 0 || time === 46) {
      index = 6;
      carrier = (attackingA ? 0 : 11) + index;
      action = "SAQUE DE CENTRO";
      detail = "Comienza la jugada desde la mitad de cancha";
      players[carrier].x = 50 + (attackingA ? -3 : 3);
      players[carrier].y = 50;
    } else if (goal) {
      index = 9;
      carrier = (attackingA ? 0 : 11) + index;
      action = "¡GOL!";
      detail = "Gol registrado en el minuto " + time;
      players[carrier].x = attackingA ? 86 : 14;
      players[carrier].y = 50;
      // Los jugadores ofensivos se acercan al rematador para celebrar.
      [8, 10].forEach((p, pos) => {
        const mate = players[(attackingA ? 0 : 11) + p];
        mate.x = attackingA ? 78 + pos * 5 : 22 - pos * 5;
        mate.y = pos ? 61 : 39;
      });
    } else if (time === 45) {
      action = "DESCANSO"; detail = "Final de la primera parte";
    } else if (time === 90) {
      action = "FINAL DEL PARTIDO"; detail = "Replay terminado";
    } else if (recovered) {
      action = "RECUPERACIÓN"; detail = "Presión defensiva y recuperación del balón";
    } else if (time % 13 === 0) {
      action = "DISPARO A PORTERÍA"; detail = "Remate ilustrativo sin modificar el marcador";
      index = 9;
      carrier = (attackingA ? 0 : 11) + index;
      players[carrier].x = attackingA ? 80 : 20;
      players[carrier].y = 50;
    } else if (time % 7 === 0) {
      action = "PRESIÓN ALTA"; detail = "Los defensores cierran espacios";
    } else if (time % 5 === 0) {
      action = "CONTRAATAQUE"; detail = "Transición rápida al espacio";
    } else if (time % 3 === 0) {
      action = "DESMARQUE"; detail = "Un atacante busca una línea de pase";
    }

    // Seguimiento al poseedor: dos defensores se aproximan, el resto cubre.
    if (!goal && time !== 45 && time !== 90) {
      const defenderBase = attackingA ? 11 : 0;
      for (const [indexDef, amount] of [[6, .35], [2, .19]]) {
        const defender = players[defenderBase + indexDef];
        const target = players[carrier];
        defender.x = clamp(mix(defender.x, target.x, amount), 5, 95);
        defender.y = clamp(mix(defender.y, target.y, amount), 8, 92);
      }
      // El compañero de ataque corre hacia espacio libre, sin seguir el balón.
      const runner = players[(attackingA ? 0 : 11) + ((index + 2) % 6 + 5)];
      runner.x = clamp(runner.x + direction * 4, 5, 95);
      runner.y = clamp(runner.y + wave(time + id) * 3, 8, 92);
    }

    const ball = goal ? { x: attackingA ? 97 : 3, y: 50 } : {
      x: clamp(players[carrier].x + direction * 2.7, 3, 97),
      y: clamp(players[carrier].y + wave(time + id) * 1.8, 5, 95)
    };
    return {
      minute: time, side, players, carrier, ball,
      action, detail, goal: !!goal, recovered,
      eventPlayer: goal?.player || null
    };
  }

  /** Interpolación determinista. Los pases y tiros viajan, no se teletransportan. */
  function frame(minute, seed, events) {
    const time = clamp(num(minute), 0, 90);
    const index = Math.floor(time);
    const fraction = time - index;
    const from = pose(index, seed, events);
    if (fraction < .000001 || index === 90)
      return { ...from, progress: 0, fromBall: from.ball, toBall: from.ball };

    const next = pose(Math.min(index + 1, 90), seed, events);
    const eased = smooth(fraction);
    const players = from.players.map((p, i) => ({
      ...p, x: mix(p.x, next.players[i].x, eased),
      y: mix(p.y, next.players[i].y, eased)
    }));
    // Pequeña parábola para distinguir pases y centros de un balón conducido.
    const arc = (from.carrier === next.carrier && from.side === next.side) ?
      1.1 : 4.3;
    const ball = {
      x: clamp(mix(from.ball.x, next.ball.x, eased), 3, 97),
      y: clamp(mix(from.ball.y, next.ball.y, eased) -
        Math.sin(Math.PI * fraction) * arc, 5, 95)
    };
    let action = from.action;
    let detail = from.detail;
    if (next.goal) {
      action = "DISPARO A PUERTA";
      detail = "Balón en trayectoria hacia el arco";
    } else if (from.goal) {
      action = "CELEBRACIÓN";
      detail = "Los compañeros festejan el gol registrado";
    } else if (next.side !== from.side) {
      action = "DISPUTA DEL BALÓN";
      detail = "El equipo rival intenta recuperar la posesión";
    } else if (from.action !== "DESCANSO" && from.action !== "FINAL DEL PARTIDO" &&
        fraction > .15) {
      action = "PASE EN MOVIMIENTO";
      detail = "Pase al compañero que se desmarca";
    }
    return {
      ...from, minute: time, players, ball, action, detail,
      progress: fraction, fromBall: from.ball, toBall: next.ball
    };
  }

  function create(field, options) {
    if (!field) return null;
    const config = options || {};
    const home = String(config.home || "Local");
    const away = String(config.away || "Visita");
    const events = Array.isArray(config.events) ? config.events : [];
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
        " · Jugador #" + NUMBERS[i % 11] + " (posición ilustrativa)";
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
    const overlay = document.createElement("div");
    overlay.className = "arena-pitch-moment";
    overlay.setAttribute("aria-hidden", "true");
    field.appendChild(overlay);
    let previousMinute = null;

    function update(minute, speed) {
      const current = frame(minute, config.id, events);
      const fractional = current.progress > .000001;
      const transition = previousMinute == null || fractional ? "0ms" :
        clamp(Math.round(160 / (Number(speed) || 1)), 50, 200) + "ms";
      for (let i = 0; i < elements.length; i++) {
        const player = elements[i];
        const position = current.players[i];
        player.style.left = position.x.toFixed(3) + "%";
        player.style.top = position.y.toFixed(3) + "%";
        player.style.transitionDuration = transition;
        player.dataset.active = String(i === current.carrier);
      }
      if (ballNode) {
        ballNode.style.left = current.ball.x.toFixed(3) + "%";
        ballNode.style.top = current.ball.y.toFixed(3) + "%";
        ballNode.style.transitionDuration = transition;
        ballNode.dataset.flight = String(fractional &&
          (Math.abs(current.toBall.x - current.fromBall.x) > 7 ||
           Math.abs(current.toBall.y - current.fromBall.y) > 8));
      }
      if (trail) {
        trail.setAttribute("points",
          (current.fromBall.x * 10).toFixed(0) + "," +
          (current.fromBall.y * 6).toFixed(0) + " " +
          (current.ball.x * 10).toFixed(0) + "," +
          (current.ball.y * 6).toFixed(0));
      }
      if (title) title.textContent = "ESTADO: " + current.action;
      if (subtitle) subtitle.textContent = current.detail;
      field.dataset.tacticalMinute = String(Math.floor(current.minute));
      field.dataset.tacticalAction = current.action;
      field.dataset.possession = current.side;
      overlay.textContent = current.goal ? "¡GOL! " +
        (current.side === "A" ? home : away) : "";
      overlay.dataset.visible = String(current.goal && current.progress < .25);
      previousMinute = current.minute;
      return current;
    }

    return { update };
  }

  window.ArenaPitch = { frame, pose, create };
})();
