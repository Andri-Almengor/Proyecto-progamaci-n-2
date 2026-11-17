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
    if (!window.confirm('Se sortearán los 16 equipos y las llaves quedarán bloqueadas. ¿Crear el torneo?')) event.preventDefault();
  });

  $$('[data-score-form]').forEach(form => form.addEventListener('submit', event => {
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
