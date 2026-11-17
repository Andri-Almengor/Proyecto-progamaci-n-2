<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="partials/nav.jspf"%>
<%
  Store.State state = (Store.State)request.getAttribute("state");
  boolean registrationOpen = state.tournament == null || !"ACTIVO".equals(state.tournament.status);
%>
<section class="page-hero reveal"><span class="eyebrow">LOS PROTAGONISTAS</span><h1>Equipos <span class="text-gradient">de la arena.</span></h1><p>Conocé a los aspirantes al título. Cada escudo representa una historia por escribir.</p></section>
<section class="team-layout">
  <div class="teams-content">
    <div class="section-heading compact"><div><h2>Todos los equipos <span class="counter-bubble"><%=state.teams.size()%></span></h2><p><%=state.approved%> aprobados · <%=state.pending%> pendientes</p></div></div>
    <div class="team-tools">
      <input type="search" class="team-search" placeholder="⌕  Buscar por nombre de equipo..." aria-label="Buscar equipo" data-team-search>
      <select class="team-filter" aria-label="Filtrar por estado" data-team-filter><option value="TODOS">Todos los estados</option><option value="APROBADO">Aprobados</option><option value="PENDIENTE">Pendientes</option><option value="RECHAZADO">Rechazados</option></select>
    </div>
    <div class="team-grid" data-team-grid>
    <% for (Store.Team team : state.teams) { %>
      <article class="team-card reveal" data-team-name="<%=Web.esc(team.name.toLowerCase(Locale.ROOT))%>" data-team-status="<%=Web.esc(team.status)%>">
        <div class="team-card-top"><span class="team-number">#<%=String.format("%02d",team.id)%></span><span class="team-badge team-badge-<%=team.status.toLowerCase(Locale.ROOT)%>"><%=Web.esc(team.status)%></span></div>
        <div class="team-card-shield"><span><%=Web.esc(team.name.substring(0,1).toUpperCase(Locale.ROOT))%></span>
          <% if (!Web.image(team.shield).isEmpty()) { %><img src="<%=Web.esc(team.shield)%>" alt="Escudo de <%=Web.esc(team.name)%>" loading="lazy"><% } %>
        </div>
        <h3><%=Web.esc(team.name)%></h3>
        <div class="team-meta"><span>◈ <%=Web.esc(team.owner)%></span><span>☎ <%=Web.esc(team.phone)%></span></div>
        <% if (state.participantIds.contains(team.id)) { %><div class="team-participant">✓ PARTICIPANTE DEL TORNEO</div><% } %>
      </article>
    <% } %>
    </div>
    <div class="empty-filter" data-empty-teams hidden>No se encontraron equipos con esos filtros.</div>
    <% if (state.teams.isEmpty()) { %><div class="empty-panel">⚑ <strong>La arena todavía espera a sus equipos.</strong><p>Sé el primero en inscribir tu escuadra.</p></div><% } %>
  </div>
  <aside class="registration-panel reveal" id="inscribir">
    <span class="eyebrow">SUMATE A LA ACCIÓN</span><h2>Inscribí tu <span class="text-gradient">equipo.</span></h2>
    <% if (!registrationOpen) { %>
      <div class="notice-box">🔒 Las inscripciones están cerradas mientras haya un torneo activo. Podrás inscribir nuevos equipos después de la final.</div>
    <% } else if (signedIn == null) { %>
      <p class="muted">Creá una cuenta o iniciá sesión para inscribir equipos al torneo.</p>
      <a class="btn-neon btn-block" href="<%=ctx%>/app?view=registro">Crear cuenta ↗</a>
      <a class="btn-outline btn-block" href="<%=ctx%>/app?view=login">Ya tengo cuenta →</a>
    <% } else { %>
      <p class="muted">Completá los datos de tu escuadra. El administrador revisará su inscripción.</p>
      <form method="post" action="<%=ctx%>/app" class="form-stack">
        <input type="hidden" name="csrf" value="<%=Web.esc(token)%>">
        <input type="hidden" name="action" value="team.create">
        <label class="field"><span>Nombre del equipo *</span><input type="text" name="name" minlength="3" maxlength="100" required placeholder="Ej. Halcones del Norte"></label>
        <label class="field"><span>Número de teléfono *</span><input type="tel" name="phone" minlength="8" maxlength="20" required placeholder="8888-8888" pattern="[+]?[0-9 ()-]{8,20}"></label>
        <label class="field"><span>URL del escudo <small>(opcional)</small></span><input type="url" name="shield" maxlength="1024" placeholder="https://ejemplo.com/escudo.png" data-image-input data-preview="#team-preview"></label>
        <div class="image-preview" id="team-preview"><span>🛡</span><small>Vista previa del escudo</small></div>
        <button class="btn-neon btn-block" type="submit">Solicitar inscripción <span>↗</span></button>
        <small class="subtle">Solo un administrador puede aprobar los equipos. El nombre no puede repetirse.</small>
      </form>
    <% } %>
  </aside>
</section>
<%@include file="partials/footer.jspf"%>
