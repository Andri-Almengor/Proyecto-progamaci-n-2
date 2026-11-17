<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="partials/nav.jspf"%>
<%
    Store.State state = (Store.State)request.getAttribute("state");
    Store.Tournament tournament = state.tournament;
    boolean finished = tournament != null && "FINALIZADO".equals(tournament.status);
    boolean active = tournament != null && "ACTIVO".equals(tournament.status);
    String[] rounds = {"","OCTAVOS DE FINAL","CUARTOS DE FINAL","SEMIFINALES","GRAN FINAL"};
    int progress = state.finalized * 100 / 15;
    java.text.NumberFormat crc = java.text.NumberFormat.getIntegerInstance(new Locale("es","CR"));
%>
<section class="hero-section reveal">
  <div class="hero-ambient" aria-hidden="true"></div>
  <% if (tournament != null && !tournament.image.isEmpty()) { %>
    <img class="hero-cover" src="<%=Web.esc(tournament.image)%>" alt="" loading="eager">
  <% } %>
  <div class="hero-content">
    <span class="eyebrow"><span class="pulse-dot"></span> LA ARENA ESTÁ LISTA</span>
    <h1><%= tournament == null ? "UN SOLO" : Web.esc(tournament.name.toUpperCase(Locale.ROOT)) %><br>
      <span class="text-gradient"><%= tournament == null ? "CAMPEÓN." : finished ? "TENEMOS CAMPEÓN." : "RUMBO A LA GLORIA." %></span>
    </h1>
    <p><%= tournament == null ? "La competencia más emocionante empieza con 16 equipos. Armá tu escuadra, clasificá y perseguí la copa." :
      finished ? "La gran final terminó. Conocé al equipo que escribió su nombre en la historia." :
      "El cuadro está definido. Cada victoria acerca a un equipo a levantar el trofeo."%></p>
    <div class="hero-actions">
      <a class="btn-neon" href="#llaves"><%=tournament == null ? "Explorar el cuadro" : "Ver las llaves"%> <span>↗</span></a>
      <a class="btn-outline" href="<%=ctx%>/app?view=equipos">Ver equipos <span>→</span></a>
    </div>
    <div class="hero-meta">
      <span><i class="meta-icon">◈</i> 16 EQUIPOS</span><span class="meta-divider"></span>
      <span><i class="meta-icon">✦</i> 4 RONDAS</span><span class="meta-divider"></span>
      <span><i class="meta-icon">♕</i> 1 CAMPEÓN</span>
    </div>
  </div>
  <div class="hero-trophy" aria-hidden="true">
    <span class="trophy-ring ring-one"></span><span class="trophy-ring ring-two"></span>
    <div class="trophy-emoji">🏆</div>
    <span class="trophy-caption">THE CHAMPION</span>
  </div>
  <div class="hero-index" aria-hidden="true">01 / 04</div>
</section>
<section class="stats-bar reveal" aria-label="Estadísticas de torneo">
  <div class="stat-item"><span class="stat-symbol">⬡</span><div><strong><%=tournament == null ? state.approved : "16"%><span class="stat-suffix">/16</span></strong><small>EQUIPOS CLASIFICADOS</small></div></div>
  <div class="stat-item"><span class="stat-symbol">⚔</span><div><strong><%=state.finalized%><span class="stat-suffix">/15</span></strong><small>PARTIDOS JUGADOS</small></div></div>
  <div class="stat-item"><span class="stat-symbol">◎</span><div><strong>04</strong><small>RONDAS ELIMINATORIAS</small></div></div>
  <div class="stat-item"><span class="stat-symbol">✷</span><div><strong><%=finished ? "100" : progress%><span class="stat-suffix">%</span></strong><small>PROGRESO DEL TORNEO</small></div></div>
</section>
<% if (finished) { %>
<section class="champion-banner reveal" data-champion-celebrate>
  <div class="champion-spark">✦</div>
  <div class="champion-crown">👑</div>
  <div class="champion-details">
    <span class="eyebrow">EL GRAN CAMPEÓN</span>
    <h2><%=Web.esc(tournament.championName)%></h2>
    <p>¡El equipo que conquistó la arena y levantó el trofeo!</p>
  </div>
  <div class="champion-gold">🏆</div>
</section>
<% } %>
<section class="bracket-section" id="llaves">
  <div class="section-heading reveal">
    <div><span class="eyebrow">EL CAMINO A LA VICTORIA</span><h2>Cuadro <span class="text-gradient">eliminatorio.</span></h2><p>Cada enfrentamiento define quién sigue en carrera por la copa.</p></div>
    <div class="status-cluster">
      <span class="status-pill <%=finished ? "status-finished" : active ? "status-live" : "status-wait"%>">
        <span class="status-dot"></span><%=finished ? "FINALIZADO" : active ? "EN COMPETENCIA" : "ESPERANDO EQUIPOS"%>
      </span>
      <% if (tournament != null) { %>
      <small>Del <%=tournament.start%> al <%=tournament.end%></small>
      <% } %>
    </div>
  </div>
  <% if (active && signedIn != null && signedIn.admin()) { %>
  <form class="sim-all-control" method="post" action="<%=ctx%>/app" data-simulate-all-confirm>
    <input type="hidden" name="csrf" value="<%=Web.esc(token)%>">
    <input type="hidden" name="action" value="tournament.simulateAll">
    <span>¿Querés terminar todas las llaves con resultados simulados?</span>
    <button class="btn-outline btn-small" type="submit">⚡ Simular todos los partidos pendientes</button>
  </form>
  <% } %>
  <p class="sim-disclaimer">ℹ Los informes incluyen estadísticas y cronologías ficticias generadas para fines demostrativos, no mediciones reales.</p>
  <div class="bracket-toolbar">
    <div class="legend"><span><i class="legend-dot dot-done"></i> Finalizado</span><span><i class="legend-dot dot-upcoming"></i> Por jugar</span><span>🏆 Campeón</span></div>
    <span class="scroll-tip">Deslizá para ver todas las rondas <span>→</span></span>
  </div>
  <div class="bracket-scroll" data-bracket-scroll tabindex="0" aria-label="Cuadro eliminatorio de cuatro rondas">
    <div class="bracket-grid">
    <% for (int round = 1; round <= 4; round++) {
       List<Store.Match> matchList = state.round(round);
       int slots = 16 >> round;
    %>
      <section class="bracket-round round-<%=round%>" aria-label="<%=rounds[round]%>">
        <div class="round-header"><span class="round-step">0<%=round%></span><div><strong><%=rounds[round]%></strong><small><%=slots%> <%=slots == 1 ? "PARTIDO" : "PARTIDOS"%></small></div><span class="round-icon"><%=round==4 ? "♛" : "↗"%></span></div>
        <div class="round-matches">
        <% for (int idx = 0; idx < slots; idx++) {
           Store.Match match = idx < matchList.size() ? matchList.get(idx) : null;
           boolean done = match != null && match.done();
           boolean ready = match != null && match.aId != null && match.bId != null && active;
           String teamA = match == null || match.aName == null ? "Por definir" : match.aName;
           String teamB = match == null || match.bName == null ? "Por definir" : match.bName;
        %>
          <article class="match-card <%=done ? "match-done" : ready ? "match-ready" : ""%>" data-round="<%=round%>">
            <div class="match-label"><span>PARTIDO <%=idx+1%></span><span class="<%=done ? "label-done" : "label-pending"%>"><%=done ? "● FINALIZADO" : "○ PENDIENTE"%></span></div>
            <div class="match-team <%=done && match.winnerId != null && match.winnerId.equals(match.aId) ? "match-winner" : ""%>">
              <div class="mini-shield"><span><%=Web.esc(teamA.substring(0,1).toUpperCase(Locale.ROOT))%></span>
                <% if (match != null && !Web.image(match.aShield).isEmpty()) { %><img src="<%=Web.esc(match.aShield)%>" alt="" loading="lazy"><% } %>
              </div>
              <span class="match-team-name"><%=Web.esc(teamA)%></span>
              <% if (done && match.winnerId.equals(match.aId)) { %><span class="winner-icon">✦</span><% } %>
              <strong class="match-score"><%=done ? match.scoreA : "—"%></strong>
            </div>
            <div class="match-separator"></div>
            <div class="match-team <%=done && match.winnerId != null && match.winnerId.equals(match.bId) ? "match-winner" : ""%>">
              <div class="mini-shield"><span><%=Web.esc(teamB.substring(0,1).toUpperCase(Locale.ROOT))%></span>
                <% if (match != null && !Web.image(match.bShield).isEmpty()) { %><img src="<%=Web.esc(match.bShield)%>" alt="" loading="lazy"><% } %>
              </div>
              <span class="match-team-name"><%=Web.esc(teamB)%></span>
              <% if (done && match.winnerId.equals(match.bId)) { %><span class="winner-icon">✦</span><% } %>
              <strong class="match-score"><%=done ? match.scoreB : "—"%></strong>
            </div>
            <% if (done) { %>
            <div class="match-report-links">
              <a href="<%=ctx%>/app?view=partido&amp;id=<%=match.id%>&amp;play=1">▶ Ver simulación</a>
              <a href="<%=ctx%>/app?view=partido&amp;id=<%=match.id%>">Estadísticas ↗</a>
            </div>
            <% } %>
            <% if (ready && signedIn != null && signedIn.admin()) { %>
            <form action="<%=ctx%>/app" method="post" class="match-auto-form">
              <input type="hidden" name="csrf" value="<%=Web.esc(token)%>">
              <input type="hidden" name="action" value="match.simulate">
              <input type="hidden" name="matchId" value="<%=match.id%>">
              <button type="submit" class="match-simulate-button" data-simulate-confirm>⚡ Simular automáticamente</button>
            </form>
            <details class="score-editor">
              <summary>Registrar resultado <span>＋</span></summary>
              <form action="<%=ctx%>/app" method="post" data-score-form>
                <input type="hidden" name="csrf" value="<%=Web.esc(token)%>">
                <input type="hidden" name="action" value="match.result">
                <input type="hidden" name="matchId" value="<%=match.id%>">
                <div class="score-fields"><label><span>Local</span><input type="number" min="0" max="999" step="1" name="scoreA" required aria-label="Goles del primer equipo"></label><span>—</span><label><span>Visita</span><input type="number" min="0" max="999" step="1" name="scoreB" required aria-label="Goles del segundo equipo"></label></div>
                <small class="score-hint">Sin empates. El registro es definitivo.</small>
                <button type="submit" class="btn-neon btn-small btn-block">Confirmar marcador ↗</button>
              </form>
            </details>
            <% } %>
          </article>
        <% } %>
        </div>
      </section>
    <% } %>
    <section class="bracket-champion" aria-label="Equipo campeón">
      <div class="round-header"><span class="round-step">05</span><div><strong>CAMPEÓN</strong><small>EL GANADOR</small></div></div>
      <div class="champion-pedestal <%=finished ? "has-champion" : ""%>">
        <span class="pedestal-shine"></span><div class="pedestal-cup">🏆</div>
        <span class="eyebrow"><%=finished ? "CAMPEÓN " + tournament.end.getYear() : "EN DISPUTA"%></span>
        <strong><%=finished ? Web.esc(tournament.championName) : "¿QUIÉN SERÁ?"%></strong>
        <small><%=finished ? "LEYENDA DE LA ARENA" : "LA GLORIA TE ESPERA"%></small>
      </div>
    </section>
    </div>
  </div>
</section>
<section class="overview-grid reveal">
  <article class="overview-card">
    <span class="eyebrow">EL PREMIO MAYOR</span><div class="overview-symbol">₡</div>
    <h3><%=tournament == null ? "₡ —" : "₡ " + crc.format(tournament.prize)%></h3>
    <p>El premio que recibirá el equipo que conquiste la final.</p>
  </article>
  <article class="overview-card overview-card-accent">
    <span class="eyebrow">FORMÁ PARTE DEL TORNEO</span><h3>¿LISTO PARA COMPETIR?</h3>
    <p>Inscribí tu escuadra y seguí cada ronda de la competencia desde cualquier dispositivo.</p>
    <a class="btn-outline" href="<%=ctx%>/app?view=equipos">Explorar equipos <span>↗</span></a>
  </article>
</section>
<%@include file="partials/footer.jspf"%>
