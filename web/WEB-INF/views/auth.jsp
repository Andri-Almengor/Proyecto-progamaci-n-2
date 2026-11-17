<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="partials/nav.jspf"%>
<% boolean register = "registro".equals(viewName); %>
<section class="auth-layout">
  <div class="auth-story reveal">
    <span class="eyebrow"><span class="pulse-dot"></span> BIENVENIDO A LA COMPETENCIA</span>
    <h1>LA GLORIA SE <span class="text-gradient">GANA.</span></h1>
    <p>16 equipos. 15 enfrentamientos. Un solo campeón. Tu camino hacia la final empieza aquí.</p>
    <div class="auth-stat-row">
      <div><strong>16</strong><small>EQUIPOS</small></div>
      <div><strong>04</strong><small>RONDAS</small></div>
      <div><strong>01</strong><small>CAMPEÓN</small></div>
    </div>
    <div class="auth-decoration" aria-hidden="true">🏆</div>
  </div>
  <div class="auth-card reveal">
    <div class="auth-icon"><%=register ? "✦" : "↗"%></div>
    <span class="eyebrow"><%=register ? "UNÍTE A LA ARENA" : "VOLVÉ A LA ARENA"%></span>
    <h2><%=register ? "Creá tu cuenta" : "Iniciá sesión"%></h2>
    <p class="muted"><%=register ? "Registrate y llevá tu equipo a competir." : "Ingresá para gestionar tu equipo y seguir el torneo."%></p>
    <form method="post" action="<%=ctx%>/app" class="form-stack" autocomplete="on">
      <input type="hidden" name="csrf" value="<%=Web.esc(token)%>">
      <input type="hidden" name="action" value="<%=register ? "register" : "login"%>">
      <% if (register) { %>
      <label class="field"><span>Nombre completo</span><input type="text" name="name" minlength="3" maxlength="120" required placeholder="Tu nombre y apellido" autocomplete="name"></label>
      <% } %>
      <label class="field"><span>Correo electrónico</span><input type="email" name="email" maxlength="190" required placeholder="correo@ejemplo.com" autocomplete="email"></label>
      <label class="field"><span>Contraseña</span><span class="password-wrap">
        <input type="password" name="password" id="password" minlength="<%=register ? "8" : "1"%>" maxlength="128" required placeholder="<%=register ? "Mínimo 8 caracteres" : "Tu contraseña"%>" autocomplete="<%=register ? "new-password" : "current-password"%>">
        <button type="button" class="reveal-password" data-password-toggle aria-label="Mostrar contraseña">◉</button>
      </span></label>
      <button type="submit" class="btn-neon btn-block"><%=register ? "Crear mi cuenta" : "Entrar a la arena"%> <span>↗</span></button>
    </form>
    <p class="auth-switch"><%=register ? "¿Ya tenés una cuenta?" : "¿Todavía no tenés cuenta?"%>
      <a href="<%=ctx%>/app?view=<%=register ? "login" : "registro"%>"><%=register ? "Iniciá sesión" : "Registrate gratis"%></a></p>
  </div>
</section>
<%@include file="partials/footer.jspf"%>
