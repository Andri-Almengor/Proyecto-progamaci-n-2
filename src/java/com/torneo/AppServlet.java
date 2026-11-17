package com.torneo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/app")
public final class AppServlet extends HttpServlet {
    private String path(HttpServletRequest req, String view) { return req.getContextPath() + "/app?view=" + view; }
    private void flash(HttpServletRequest req, String kind, String message) {
        req.getSession(true).setAttribute("flashKind", kind);
        req.getSession(true).setAttribute("flash", message);
    }
    @Override protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setHeader("Cache-Control", "no-store");
        String view = req.getParameter("view");
        if (view == null || view.isBlank()) view = "inicio";
        if (!("inicio".equals(view) || "equipos".equals(view) || "admin".equals(view) ||
              "login".equals(view) || "registro".equals(view) || "partido".equals(view))) {
            res.sendError(404); return;
        }
        Store.User current = Web.user(req);
        if ("admin".equals(view) && (current == null || !current.admin())) { res.sendError(403); return; }
        if (("login".equals(view) || "registro".equals(view)) && current != null) {
            res.sendRedirect(path(req, "inicio")); return;
        }
        req.setAttribute("csrf", Web.token(req));
        HttpSession s = req.getSession();
        req.setAttribute("flash", s.getAttribute("flash"));
        req.setAttribute("flashKind", s.getAttribute("flashKind"));
        s.removeAttribute("flash"); s.removeAttribute("flashKind");
        req.setAttribute("view", view);
        if ("partido".equals(view)) {
            try {
                long id = Long.parseLong(req.getParameter("id"));
                Store.MatchDetail detail = Store.loadMatchDetail(id);
                if (detail == null) { res.sendError(404); return; }
                req.setAttribute("detail", detail);
                req.setAttribute("nextMatch", Store.nextMatchId(detail.match));
            } catch (NumberFormatException e) { res.sendError(404); return; }
            catch (SQLException e) { log("Error consultando simulación", e); res.sendError(503, "No se pudo consultar el partido"); return; }
        }
        if (!("login".equals(view) || "registro".equals(view))) {
            try { req.setAttribute("state", Store.load()); }
            catch (SQLException ex) {
                log("Error consultando el sistema de torneos", ex);
                req.setAttribute("state", new Store.State());
                req.setAttribute("dbError", "No se pudo conectar con MySQL. Revisá database/torneos.sql y las variables DB_URL, DB_USER y DB_PASSWORD.");
            }
        }
        String page;
        switch (view) {
            case "login": case "registro": page = "auth.jsp"; break;
            case "equipos": page = "teams.jsp"; break;
            case "partido": page = "match.jsp"; break;
            case "admin": page = "admin.jsp"; break;
            default: page = "home.jsp"; break;
        }
        req.getRequestDispatcher("/WEB-INF/views/" + page).forward(req, res);
    }
    @Override protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setHeader("Cache-Control", "no-store");
        if (!Web.csrfValid(req)) { res.sendError(403, "Formulario expirado. Actualizá la página."); return; }
        String action = req.getParameter("action");
        if (action == null) { res.sendError(400); return; }
        String target = "inicio";
        try {
            if ("login".equals(action)) {
                target = "login";
                String email = req.getParameter("email"), pass = req.getParameter("password");
                if (email == null || email.length() > 190 || pass == null || pass.length() > 128)
                    throw new Store.RuleException("Revisá el correo y la contraseña.");
                Store.User user = Store.login(email, pass);
                if (user == null) throw new Store.RuleException("Correo o contraseña incorrectos.");
                HttpSession old = req.getSession(false);
                if (old != null) old.invalidate();
                HttpSession fresh = req.getSession(true);
                fresh.setAttribute("user", user);
                fresh.setMaxInactiveInterval(1800);
                Web.token(req);
                target = "inicio";
                flash(req, "ok", "¡Bienvenido, " + user.name + "! Ya podés participar.");
            } else if ("register".equals(action)) {
                target = "registro";
                Store.register(req.getParameter("name"), req.getParameter("email"), req.getParameter("password"));
                target = "login";
                flash(req, "ok", "Cuenta creada. Iniciá sesión para registrar tu equipo.");
            } else if ("logout".equals(action)) {
                HttpSession s = req.getSession(false);
                if (s != null) s.invalidate();
                target = "inicio";
            } else if ("team.create".equals(action)) {
                requireUser(req);
                target = "equipos";
                Store.addTeam(Web.user(req), req.getParameter("name"),
                              req.getParameter("phone"), req.getParameter("shield"));
                flash(req, "ok", "¡Equipo inscrito! Está pendiente de aprobación del administrador.");
            } else if ("team.approve".equals(action) || "team.reject".equals(action)) {
                requireAdmin(req);
                target = "admin";
                Store.setApproval(Long.parseLong(req.getParameter("teamId")), "team.approve".equals(action));
                flash(req, "ok", "El estado del equipo se actualizó.");
            } else if ("tournament.create".equals(action)) {
                requireAdmin(req);
                target = "admin";
                Set<Long> selected = new HashSet<>();
                String[] ids = req.getParameterValues("teamIds");
                if (ids != null) for (String id : ids) selected.add(Long.parseLong(id));
                Store.createTournament(req.getParameter("name"), req.getParameter("image"),
                    LocalDate.parse(req.getParameter("start")), LocalDate.parse(req.getParameter("end")),
                    new BigDecimal(req.getParameter("prize")), selected);
                if ("on".equals(req.getParameter("autoSimulate"))) {
                    int done = Store.simulateRemaining();
                    target = "partido&id=" + Store.load().round(1).get(0).id + "&play=1";
                    flash(req, "ok", "¡Torneo simulado! Elegí reproducir cada partido, saltarlo o ver directamente su resumen.");
                } else {
                    flash(req, "ok", "¡Torneo creado! Podés simular partido a partido o ingresar los marcadores.");
                }
                if (!"on".equals(req.getParameter("autoSimulate"))) target = "inicio";
            } else if ("tournament.simulateAll".equals(action)) {
                requireAdmin(req);
                target = "inicio";
                int done = Store.simulateRemaining();
                flash(req, "ok", "Se simularon " + done + " partidos. ¡Todos los resúmenes quedaron guardados!");
            } else if ("match.simulate".equals(action)) {
                requireAdmin(req);
                long matchId = Long.parseLong(req.getParameter("matchId"));
                target = "inicio";
                Store.simulateMatch(matchId);
                target = "partido&id=" + matchId + "&play=1";
                flash(req, "ok", "¡Partido simulado! Podés reproducirlo, ver sus estadísticas o saltar la animación.");
            } else if ("match.result".equals(action)) {
                requireAdmin(req);
                target = "inicio";
                long matchId = Long.parseLong(req.getParameter("matchId"));
                Store.recordScore(matchId, Integer.parseInt(req.getParameter("scoreA")),
                    Integer.parseInt(req.getParameter("scoreB")));
                target = "partido&id=" + matchId + "&play=1";
                flash(req, "ok", "¡Resultado guardado! Revisá o saltá la simulación; el ganador ya avanzó.");
            } else {
                res.sendError(400, "Acción desconocida"); return;
            }
        } catch (Store.RuleException ex) {
            flash(req, "error", ex.getMessage());
        } catch (NumberFormatException | java.time.format.DateTimeParseException ex) {
            flash(req, "error", "Revisá los números, fechas y selecciones del formulario.");
        } catch (SQLException ex) {
            log("Error SQL en " + action, ex);
            flash(req, "error", "No se pudo guardar la operación. Verificá los datos y la conexión MySQL.");
        }
        res.sendRedirect(path(req, target));
    }
    private void requireUser(HttpServletRequest req) throws Store.RuleException {
        if (Web.user(req) == null) throw new Store.RuleException("Iniciá sesión para realizar esta operación.");
    }
    private void requireAdmin(HttpServletRequest req) throws Store.RuleException {
        Store.User user = Web.user(req);
        if (user == null || !user.admin()) throw new Store.RuleException("Solo el administrador puede realizar esta operación.");
    }
}
