/* Interacciones complementarias. La seguridad y los resultados se validan en el servidor. */
(() => {
  "use strict";
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
  const menuButton = $('[data-menu-toggle]');
  const menu = $('[data-menu]');
  if (menuButton && menu) {
    menuButton.addEventListener('click', () => {
      const open = menu.classList.toggle('open');
      menuButton.setAttribute('aria-expanded', String(open));
      menuButton.textContent = open ? '✕' : '☰';
    });
    $$('.nav-links a').forEach(a => a.addEventListener('click', () => menu.classList.remove('open')));
  }

  $('[data-dismiss-flash]')?.addEventListener('click', () => $('[data-flash]')?.remove());
  $('[data-password-toggle]')?.addEventListener('click', () => {
    const input = $('#password');
    if (!input) return;
    input.type = input.type === 'password' ? 'text' : 'password';
  });

  // Si una URL externa falla, conservamos el monograma en vez del icono de imagen rota.
  $('.mini-shield img, .team-card-shield img').forEach(img => {
    img.addEventListener('error', () => img.remove());
    if (img.complete && img.naturalWidth === 0) img.remove();
  });

  const search = $('[data-team-search]');
  const filter = $('[data-team-filter]');
  const cards = $$('[data-team-name]');
  const updateTeams = () => {
    const query = (search?.value || '').trim().toLocaleLowerCase('es');
    const status = filter?.value || 'TODOS';
    let visible = 0;
    cards.forEach(card => {
      const show = card.dataset.teamName.includes(query) && (status === 'TODOS' || card.dataset.teamStatus === status);
      card.hidden = !show;
      if (show) visible++;
    });
    const empty = $('[data-empty-teams]');
    if (empty) empty.hidden = visible > 0 || cards.length === 0;
  };
  search?.addEventListener('input', updateTeams);
  filter?.addEventListener('change', updateTeams);

  $$('[data-image-input]').forEach(input => {
    const destination = $(input.dataset.preview);
    if (!destination) return;
    const original = destination.innerHTML;
    const update = () => {
      const value = input.value.trim();
      destination.innerHTML = original;
      if (!value) return;
      try {
        const url = new URL(value);
        if (!['https:', 'http:'].includes(url.protocol)) return;
        const img = document.createElement('img');
        img.alt = 'Vista previa';
        img.loading = 'lazy';
        img.onerror = () => img.remove();
        img.src = url.href;
        destination.appendChild(img);
      } catch (_) { /* La validación HTML y servidor dará el mensaje. */ }
    };
    input.addEventListener('input', update);
    input.addEventListener('change', update);
  });

  const options = $$('[data-team-option]');
  const selectedDisplay = $('[data-selected-count]');
  const updateCount = () => {
    const selected = options.filter(input => input.checked).length;
    if (selectedDisplay) {
      selectedDisplay.textContent = selected + ' / 16';
      selectedDisplay.style.color = selected === 16 ? 'var(--lime)' : 'var(--warning)';
    }
  };
  options.forEach(input => input.addEventListener('change', updateCount));
  updateCount();
  $('[data-tournament-form]')?.addEventListener('submit', event => {
    if (options.filter(input => input.checked).length !== 16) {
      event.preventDefault();
      window.alert('Seleccioná exactamente los 16 equipos aprobados.');
      return;
    }
    const start = $('[name=start]', event.currentTarget)?.value;
    const end = $('[name=end]', event.currentTarget)?.value;
    if (start && end && end < start) {
      event.preventDefault();
      window.alert('La fecha de finalización no puede ser anterior a la fecha de inicio.');
      return;
    }
    const auto = event.currentTarget.elements.autoSimulate?.checked;
    const message = auto ? 'Se generarán los 15 marcadores y el campeón inmediatamente. ¿Confirmar la simulación automática completa?' : 'Se sortearán los 16 equipos y las llaves quedarán bloqueadas. ¿Crear el torneo?';
    if (!window.confirm(message)) event.preventDefault();
  });


  $('[data-simulate-confirm]').forEach(button => button.closest('form')?.addEventListener('submit', event => {
    if (!window.confirm('Se generará un marcador definitivo con goles y estadísticas simuladas. ¿Continuar?')) event.preventDefault();
  }));
  $('[data-simulate-all-confirm]')?.addEventListener('submit', event => {
    if (!window.confirm('Esto resolverá TODOS los partidos pendientes y determinará al campeón. ¿Simular el resto del torneo?')) event.preventDefault();
  });
  $('[data-score-form]').forEach(form => form.addEventListener('submit', event => {
    const a = Number(form.elements.scoreA.value);
    const b = Number(form.elements.scoreB.value);
    if (!Number.isInteger(a) || !Number.isInteger(b) || a < 0 || b < 0 || a > 999 || b > 999) {
      event.preventDefault();
      window.alert('Ingresá dos marcadores enteros de 0 a 999.'); return;
    }
    if (a === b) {
      event.preventDefault();
      window.alert('No se permiten empates. Debe existir un ganador.'); return;
    }
    if (!window.confirm('Este resultado será definitivo y avanzará automáticamente el ganador. ¿Confirmar?')) event.preventDefault();
  }));

  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (!prefersReducedMotion && 'IntersectionObserver' in window) {
    document.documentElement.classList.add('js-reveal');
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: .05, rootMargin: '30px 0px 30px 0px' });
    $$('.reveal').forEach(el => observer.observe(el));
  }

  const banner = $('[data-champion-celebrate]');
  if (banner && !prefersReducedMotion) {
    const colors = ['#bdff76', '#60edbf', '#f5d16e', '#ffffff'];
    for (let i = 0; i < 40; i++) {
      const piece = document.createElement('i');
      piece.className = 'confetti';
      piece.style.left = (4 + Math.random() * 91) + '%';
      piece.style.top = (Math.random() * 15) + '%';
      piece.style.backgroundColor = colors[i % colors.length];
      piece.style.animationDelay = (Math.random() * 2.2) + 's';
      piece.style.animationDuration = (2.5 + Math.random() * 2) + 's';
      piece.style.transform = 'rotate(' + Math.random() * 360 + 'deg)';
      banner.appendChild(piece);
    }
  }
})();


/* Reportes de simulación: visualización opcional, sin mutar el marcador real. */
(() => {
  'use strict';
  const root = document.querySelector('[data-match-playback]');
  if (!root) return;
  const by = (selector, area=document) => area.querySelector(selector);
  const all = (selector, area=document) => Array.from(area.querySelectorAll(selector));
  const playButton = by('[data-play-toggle]', root);
  const skipButton = by('[data-play-skip]', root);
  const replayButton = by('[data-report-replay]');
  const minuteLabel = by('[data-play-minute]', root);
  const firstScore = by('[data-play-a]', root);
  const secondScore = by('[data-play-b]', root);
  const periodLabel = by('[data-play-period]', root);
  const narration = by('[data-play-narration]', root);
  const progress = by('[data-play-progress]', root);
  const events = all('[data-event]');
  const tabs = all('[data-period-tab]');
  const panels = all('[data-period-panel]');
  const fullScoreA = events.filter(e=>e.dataset.kind==='GOL' && e.dataset.side==='A').length;
  const fullScoreB = events.filter(e=>e.dataset.kind==='GOL' && e.dataset.side==='B').length;
  const speed = 400; // 90 minutos en 36 segundos, con controles para saltar.
  let minute = 90, timer = null, playing = false;
  let activePeriod = 3;
  function choosePeriod(period) {
    activePeriod = period;
    tabs.forEach(t => {
      const active = Number(t.dataset.periodTab)===period;
      t.classList.toggle('active',active);
      t.setAttribute('aria-selected',String(active));
    });
    panels.forEach(p => p.hidden=Number(p.dataset.periodPanel)!==period);
    showEvents();
  }
  function showEvents() {
    events.forEach(e=>{
      const fitsPeriod = activePeriod===3 || Number(e.dataset.half)===activePeriod;
      e.hidden = !fitsPeriod || (playing && Number(e.dataset.minute)>minute);
    });
  }
  function update() {
    minuteLabel.textContent = String(minute).padStart(2,'0');
    const elapsed = events.filter(e=>e.dataset.kind==='GOL' && Number(e.dataset.minute)<=minute);
    firstScore.textContent = String(elapsed.filter(e=>e.dataset.side==='A').length);
    secondScore.textContent = String(elapsed.filter(e=>e.dataset.side==='B').length);
    progress.style.width = String(minute/90*100)+'%';
    if (minute===0) periodLabel.textContent='COMIENZA EL PARTIDO';
    else if (minute<=45) periodLabel.textContent='PRIMER TIEMPO';
    else if (minute<90) periodLabel.textContent='SEGUNDO TIEMPO';
    else periodLabel.textContent='FINAL DEL PARTIDO';
    showEvents();
  }
  function pause() {
    clearInterval(timer); timer=null; playing=false;
    playButton.textContent='▶ Continuar simulación';
    showEvents();
  }
  function finish() {
    pause();
    minute=90;
    update();
    firstScore.textContent=String(fullScoreA);
    secondScore.textContent=String(fullScoreB);
    choosePeriod(3);
    playButton.textContent='↻ Reproducir de nuevo';
    narration.textContent='Fin del partido. Elegí primer tiempo, segundo tiempo o partido completo para analizarlo.';
  }
  function start(reset) {
    if (timer) return;
    if (reset || minute>=90) {
      minute=0;
      narration.textContent='¡Rueda la pelota! Seguimos los momentos más importantes del encuentro.';
    }
    playing=true;
    choosePeriod(minute<=45?1:2);
    update();
    playButton.textContent='Ⅱ Pausar';
    timer=setInterval(()=>{
      minute=Math.min(90,minute+1);
      if (minute===46) choosePeriod(2);
      const now=events.filter(e=>Number(e.dataset.minute)===minute);
      if (now.length) {
        const current=now[now.length-1];
        narration.textContent=current.dataset.kind==='GOL'
          ? '¡GOOOL! '+current.dataset.team+' marca en el minuto '+minute+'.'
          : current.dataset.team+' realiza una sustitución en el minuto '+minute+'.';
        now.forEach(e=>{e.classList.add('event-highlight');setTimeout(()=>e.classList.remove('event-highlight'),1600);});
      } else if (minute===46) narration.textContent='Comienza el segundo tiempo.';
      update();
      if(minute>=90) finish();
    },speed);
  }
  playButton.addEventListener('click',()=>timer?pause():start(minute>=90));
  skipButton.addEventListener('click',()=>{
    finish();
    document.querySelector('#estadisticas')?.scrollIntoView({behavior:'smooth',block:'start'});
  });
  replayButton?.addEventListener('click',()=>{
    root.scrollIntoView({behavior:'smooth',block:'center'});start(true);
  });
  tabs.forEach(tab=>tab.addEventListener('click',()=>{
    if(timer) pause(); // Permite inspeccionar libremente cada período.
    choosePeriod(Number(tab.dataset.periodTab));
  }));
  minute=90;
  update();
  choosePeriod(3);
  narration.textContent='Reproducí los momentos destacados o consultá directamente las estadísticas.';
  if (root.dataset.autoPlay==='true' && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) start(true);
})();
