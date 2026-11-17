<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="partials/nav.jspf"%>
<%
  Store.State state = (Store.State)request.getAttribute("state");
  boolean open = state.tournament == null || "FINALIZADO".equals(state.tournament.status);
  boolean canCreate = open && state.approved == 16;
  java.time.LocalDate today = java.time.LocalDate.now(java.time.ZoneId.of("America/Costa_Rica"));
%>
<section class="page-hero reveal"><span class="eyebrow">CENTRO DE CONTROL</span><h1>Panel de <span class="text-gradient">administración.</span></h1><p>Aprobá equipos, configurá la competencia y seguí los enfrentamientos.</p></section>
<section class="admin-metrics reveal">
  <div class="metric-card"><span>INSCRIPCIONES</span><strong><%=state.teams.size()%></strong><small>Equipos registrados</small></div>
  <div class="metric-card"><span>APROBADOS</span><strong><%=state.approved%><small> / 16</small></strong><small>Listos para sorteo</small></div>
  <div class="metric-card"><span>PENDIENTES</span><strong><%=state.pending%></strong><small>Esperando revisión</small></div>
  <div class="metric-card"><span>RESULTADOS</span><strong><%=state.finalized%><small> / 15</small></strong><small>Partidos finalizados</small></div>
</section>
<section class="admin-columns">
  <article class="admin-panel reveal">
    <div class="panel-heading"><div><span class="eyebrow">PASO 01</span><h2>Aprobar equipos</h2><p>Se necesitan exactamente 16 equipos aprobados para comenzar.</p></div><span class="panel-icon">☑</span></div>
    <div class="approval-progress"><span>Progreso de cupos</span><strong><%=state.approved%>/16</strong></div>
    <div class="progress-track"><div style="width:<%=Math.min(100,state.approved*100/16)%>%"></div></div>
    <% if (!open) { %><div class="notice-box">🔒 Torneo activo. La lista de participantes ya está cerrada.</div><% } %>
    <div class="approval-list">
      <% for (Store.Team team : state.teams) { %>
      <div class="approval-item">
        <div class="approval-shield"><%=Web.esc(team.name.substring(0,1).toUpperCase(Locale.ROOT))%></div>
        <div class="approval-info"><strong><%=Web.esc(team.name)%></strong><small><%=Web.esc(team.owner)%> · <%=Web.esc(team.phone)%></small><span class="team-badge team-badge-<%=team.status.toLowerCase(Locale.ROOT)%>"><%=Web.esc(team.status)%></span></div>
        <% if (open) { %>
        <div class="approval-actions">
          <% if (!"APROBADO".equals(team.status)) { %>
          <form method="post" action="<%=ctx%>/app"><input type="hidden" name="csrf" value="<%=Web.esc(token)%>"><input type="hidden" name="action" value="team.approve"><input type="hidden" name="teamId" value="<%=team.id%>"><button title="Aprobar equipo" type="submit" class="action-accept" <%=state.approved>=16?"disabled":""%>>✓</button></form>
          <% } %>
          <% if (!"RECHAZADO".equals(team.status)) { %>
          <form method="post" action="<%=ctx%>/app"><input type="hidden" name="csrf" value="<%=Web.esc(token)%>"><input type="hidden" name="action" value="team.reject"><input type="hidden" name="teamId" value="<%=team.id%>"><button title="Rechazar equipo" type="submit" class="action-reject">✕</button></form>
          <% } %>
        </div>
        <% } %>
      </div>
      <% } %>
      <% if (state.teams.isEmpty()) { %><p class="muted">Todavía no hay equipos. Invitá a los participantes a registrarse.</p><% } %>
    </div>
  </article>
  <article class="admin-panel reveal" id="crear-torneo">
    <div class="panel-heading"><div><span class="eyebrow">PASO 02</span><h2>Crear torneo</h2><p>Configurá la copa y generá automáticamente las llaves.</p></div><span class="panel-icon">🏆</span></div>
    <% if (!open) { %>
      <div class="notice-box">🏁 Ya hay un torneo activo: <strong><%=Web.esc(state.tournament.name)%></strong>. Terminá la final para organizar uno nuevo.</div>
      <a class="btn-neon btn-block" href="<%=ctx%>/app?view=inicio#llaves">Ver llaves y registrar marcadores ↗</a>
    <% } else { %>
      <form method="post" action="<%=ctx%>/app" class="form-stack" data-tournament-form>
        <input type="hidden" name="csrf" value="<%=Web.esc(token)%>">
        <input type="hidden" name="action" value="tournament.create">
        <label class="field"><span>Nombre del torneo *</span><input type="text" minlength="3" maxlength="140" name="name" placeholder="Ej. Copa de Campeones 2026" required></label>
        <label class="field"><span>URL de portada <small>(opcional)</small></span><input type="url" maxlength="1024" name="image" placeholder="https://ejemplo.com/copa.jpg" data-image-input data-preview="#tournament-preview"></label>
        <div class="image-preview" id="tournament-preview"><span>🏆</span><small>Portada de la competencia</small></div>
        <div class="form-double">
          <label class="field"><span>Fecha de inicio *</span><input type="date" name="start" value="<%=today%>" required></label>
          <label class="field"><span>Fecha de finalización *</span><input type="date" name="end" value="<%=today.plusDays(30)%>" required></label>
        </div>
        <label class="field"><span>Premio en colones (₡) *</span><input type="number" name="prize" min="0" max="999999999999.99" step="0.01" placeholder="250000" required></label>
        <div class="selection-title"><div><strong>Seleccioná los participantes</strong><small>La selección se sortea al crear el torneo.</small></div><span class="selected-count" data-selected-count><%=state.approved%> / 16</span></div>
        <div class="team-selector">
          <% for (Store.Team team : state.teams) if ("APROBADO".equals(team.status)) { %>
          <label class="team-option"><input type="checkbox" name="teamIds" value="<%=team.id%>" checked data-team-option><span class="checkbox-custom">✓</span><span><%=Web.esc(team.name)%></span></label>
          <% } %>
          <% if (state.approved < 16) { %><div class="notice-box">Faltan <strong><%=16-state.approved%></strong> equipos aprobados. Cuando se complete el cupo podrás crear el torneo.</div><% } %>
        </div>
        <p class="subtle">Una vez creado, los participantes y las llaves quedan bloqueados. El sorteo es aleatorio.</p>
        <button type="submit" class="btn-neon btn-block" <%=canCreate?"":"disabled title=\"Necesitás 16 equipos aprobados\""%>>🏆 Generar las 15 llaves <span>↗</span></button>
      </form>
    <% } %>
  </article>
</section>
<%@include file="partials/footer.jspf"%>
