<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="partials/nav.jspf"%>
<%
  Store.MatchDetail detail = (Store.MatchDetail)request.getAttribute("detail");
  Store.Match match = detail.match;
  MatchSimulation.Report report = detail.report;
  String[] roundTitles = {"", "Octavos de final", "Cuartos de final", "Semifinal", "Gran final"};
  String nameA = match.aName == null ? "Por definir" : match.aName;
  String nameB = match.bName == null ? "Por definir" : match.bName;
  boolean completed = match.done();
  Long nextMatch = (Long)request.getAttribute("nextMatch");
%>
<section class="report-page">
  <div class="report-breadcrumb">
    <a href="<%=ctx%>/app?view=inicio#llaves">← Volver al cuadro eliminatorio</a>
    <span> / </span><span><%=roundTitles[match.round]%> · Partido <%=match.position%></span>
  </div>
  <header class="report-hero reveal">
    <div class="report-hero-line">
      <span class="eyebrow">EL PARTIDO, EN DETALLE</span>
      <span class="status-pill <%=completed ? "status-finished" : "status-wait"%>"><span class="status-dot"></span><%=completed ? "FINALIZADO" : "POR JUGAR"%></span>
    </div>
    <h1>Dentro de la <span class="text-gradient">cancha.</span></h1>
    <div class="report-scoreboard">
      <div class="report-team">
        <div class="report-crest"><span><%=Web.esc(nameA.substring(0,1).toUpperCase(Locale.ROOT))%></span>
          <% if (!Web.image(match.aShield).isEmpty()) { %><img src="<%=Web.esc(match.aShield)%>" alt="" loading="lazy"><% } %>
        </div>
        <strong><%=Web.esc(nameA)%></strong>
        <small>LOCAL</small>
      </div>
      <div class="report-center">
        <div class="report-final-score"><span><%=completed ? match.scoreA : "—"%></span><i>:</i><span><%=completed ? match.scoreB : "—"%></span></div>
        <span class="eyebrow"><%=completed ? "RESULTADO FINAL" : "PRÓXIMO ENFRENTAMIENTO"%></span>
        <small><%=roundTitles[match.round].toUpperCase(Locale.ROOT)%> · JUEGO <%=match.position%></small>
      </div>
      <div class="report-team">
        <div class="report-crest"><span><%=Web.esc(nameB.substring(0,1).toUpperCase(Locale.ROOT))%></span>
          <% if (!Web.image(match.bShield).isEmpty()) { %><img src="<%=Web.esc(match.bShield)%>" alt="" loading="lazy"><% } %>
        </div>
        <strong><%=Web.esc(nameB)%></strong>
        <small>VISITANTE</small>
      </div>
    </div>
    <% if (completed) { %>
      <p class="report-winner">✦ GANADOR: <strong><%=Web.esc(match.winnerId.equals(match.aId) ? nameA : nameB)%></strong> · Clasificado automáticamente</p>
    <% } %>
  </header>
  <% if (report == null) { %>
    <div class="report-unplayed">
      <div class="report-unplayed-icon">⚽</div>
      <h2>Este partido todavía no se ha disputado.</h2>
      <p>Cuando el administrador registre el marcador o simule el encuentro, las estadísticas y la cronología estarán disponibles aquí para todos.</p>
      <a href="<%=ctx%>/app?view=inicio#llaves" class="btn-neon">Regresar a las llaves ↗</a>
    </div>
  <% } else {
    MatchSimulation.Half[] periods = {report.first, report.second, report.total()};
    String[] periodLabels = {"PRIMER TIEMPO", "SEGUNDO TIEMPO", "PARTIDO COMPLETO"};
    String[] statLabels = {"Posesión del balón", "Dominio ofensivo · ataques peligrosos", "Pases", "Remates", "Tiros al marco", "Tiros de esquina", "Faltas"};
  %>
  <div class="report-disclaimer" role="note">
    <span>ⓘ</span>
    <p><strong>Simulación ilustrativa:</strong> la posesión, los pases, remates, goles por minuto, números de camiseta y cambios se generan ficticiamente. No son registros reales de un partido ni de jugadores inscritos.
      <% if ("RECONSTRUIDA".equals(report.mode)) { %>Este resumen corresponde a un partido anterior a la actualización y fue reconstruido con datos simulados.<% } %>
    </p>
  </div>
  <section class="match-playback reveal" data-match-playback data-auto-play="<%="1".equals(request.getParameter("play")) ? "true" : "false"%>">
    <div class="playback-heading">
      <div><span class="eyebrow">SIMULADOR DE PARTIDO</span><h2>Revive los <span class="text-gradient">90 minutos.</span></h2><p>Podés reproducir el relato, pausarlo o saltar directamente al análisis.</p></div>
      <span class="playback-illustration" aria-hidden="true">⚽</span>
    </div>
    <div class="playback-stage">
      <div class="stage-pitch" aria-hidden="true"><div class="pitch-center"></div><span class="pitch-ball">⚽</span></div>
      <div class="playback-overlay">
        <span class="playback-period" data-play-period>LISTO PARA JUGAR</span>
        <div class="playback-clock"><span data-play-minute>00</span><small>'</small></div>
        <div class="playback-live-score"><span data-play-a>0</span> – <span data-play-b>0</span></div>
        <p data-play-narration>Presioná «Reproducir» para ver los goles y cambios minuto a minuto.</p>
      </div>
    </div>
    <div class="playback-progress"><div data-play-progress></div></div>
    <div class="playback-controls">
      <button type="button" class="btn-neon btn-small" data-play-toggle>▶ Reproducir</button>
      <button type="button" class="btn-outline btn-small" data-play-skip>Saltar y ver resumen ↗</button>
      <span class="playback-note">Animación opcional · podés consultarlo cuando quieras</span>
    </div>
  </section>
  <section class="match-report-body" id="estadisticas">
    <div class="report-heading">
      <div><span class="eyebrow">REPORTE DEL PARTIDO</span><h2>Estadísticas <span class="text-gradient">comparadas.</span></h2></div>
      <div class="period-tabs" role="tablist" aria-label="Período del partido">
        <button role="tab" type="button" aria-selected="false" data-period-tab="1">1.er tiempo</button>
        <button role="tab" type="button" aria-selected="false" data-period-tab="2">2.º tiempo</button>
        <button role="tab" type="button" aria-selected="true" class="active" data-period-tab="3">Partido completo</button>
      </div>
    </div>
    <div class="report-columns">
      <div class="report-metrics">
      <% for (int period = 0; period < 3; period++) {
          MatchSimulation.Half h = periods[period];
          int[] as = {h.possessionA,h.dangerousA,h.passesA,h.shotsA,h.onA,h.cornersA,h.foulsA};
          int[] bs = {100-h.possessionA,h.dangerousB,h.passesB,h.shotsB,h.onB,h.cornersB,h.foulsB};
      %>
        <div class="report-period" data-period-panel="<%=period+1%>" <%=period == 2 ? "" : "hidden"%>>
          <div class="period-overview"><span><%=periodLabels[period]%></span><strong><%=h.goalsA%> <span>—</span> <%=h.goalsB%></strong><small>GOLES EN ESTE PERÍODO</small></div>
          <div class="period-comparison-names"><span><%=Web.esc(nameA)%></span><span><%=Web.esc(nameB)%></span></div>
          <% for (int s = 0; s < statLabels.length; s++) {
              int total = as[s] + bs[s];
              int proportion = total == 0 ? 50 : (int)Math.round(as[s] * 100.0 / total);
          %>
          <div class="report-stat">
            <div class="report-stat-header"><strong><%=as[s]%><%=s == 0 ? "%" : ""%></strong><span><%=statLabels[s]%></span><strong><%=bs[s]%><%=s == 0 ? "%" : ""%></strong></div>
            <div class="report-compare-track" role="img" aria-label="<%=Web.esc(statLabels[s] + ": " + nameA + " " + as[s] + ", " + nameB + " " + bs[s])%>">
              <div class="report-bar-left" style="width:<%=proportion%>%"></div><div class="report-bar-right" style="width:<%=100-proportion%>%"></div>
            </div>
          </div>
          <% } %>
        </div>
      <% } %>
      </div>
      <aside class="report-timeline">
        <div class="timeline-heading"><div><span class="eyebrow">MOMENTOS CLAVE</span><h3>Cronología del encuentro</h3></div><span class="timeline-icon">◷</span></div>
        <ol class="timeline-events" data-play-events>
          <% for (MatchSimulation.Event event : report.events) {
              boolean goal = "GOL".equals(event.type);
              String team = "A".equals(event.side) ? nameA : nameB;
          %>
          <li data-event data-minute="<%=event.minute%>" data-half="<%=event.minute <= 45 ? "1" : "2"%>"
              data-kind="<%=event.type%>" data-team="<%=Web.esc(team)%>" data-side="<%=event.side%>">
            <span class="event-time"><%=event.minute%>'</span>
            <div class="event-icon <%=goal ? "event-goal" : "event-change"%>"><%=goal ? "⚽" : "↗"%></div>
            <div class="event-text"><strong><%=goal ? "¡GOOOL!" : "Sustitución"%> · <%=Web.esc(team)%></strong>
              <small><%=goal ? "Anotó " + Web.esc(event.player) : "Sale " + Web.esc(event.outgoing) + " · Entra " + Web.esc(event.player)%></small>
            </div>
          </li>
          <% } %>
        </ol>
        <p class="timeline-caption">Los nombres «Jugador #» son identificadores ficticios. Los eventos se guardan junto con el partido.</p>
      </aside>
    </div>
  </section>
  <div class="report-bottom-links">
    <a class="btn-outline" href="<%=ctx%>/app?view=inicio#llaves">← Todas las llaves</a>
    <div class="report-next-controls">
      <button type="button" class="btn-outline" data-report-replay>↻ Repetir partido</button>
      <% if (nextMatch != null) { %><a class="btn-neon" href="<%=ctx%>/app?view=partido&amp;id=<%=nextMatch%>&amp;play=1">Siguiente simulación →</a><% } else { %><a class="btn-neon" href="<%=ctx%>/app?view=inicio#llaves">🏆 Ver campeón y cuadro final ↗</a><% } %>
    </div>
  </div>
  <% } %>
</section>
<%@include file="partials/footer.jspf"%>
