package com.torneo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.HashSet;
import java.util.Set;

/**
 * Controlador web principal de Bracket Arena.
 *
 * <p>GET presenta las páginas JSP y POST ejecuta operaciones de negocio. Las validaciones del
 * torneo se encuentran en {@link Store}; la autorización y los tokens CSRF se verifican antes de
 * modificar la base de datos.
 *
 * <p>Las vistas originales de Stitch están agrupadas en {@code /WEB-INF/views/arena/}; no deben
 * invocarse directamente por URL.
 */
@WebServlet("/app")
public final class AppServlet extends HttpServlet {

    private static final String VIEW_FOLDER = "/WEB-INF/views/arena/";

    // Sirve para detectar si Tomcat está mostrando un WAR anterior.
    private static final String UI_RELEASE = "2026-11-25-navbar-r2";

    private static final Set<String> ALLOWED_VIEWS =
            Set.of("inicio", "cuadro", "equipos", "admin", "crear", "login", "registro", "partido");

    /** Construye una URL relativa al contexto de Tomcat. */
    private String path(HttpServletRequest request, String view) {
        return request.getContextPath() + "/app?view=" + view;
    }

    /** Guarda un mensaje de una sola lectura para mostrarlo tras la redirección. */
    private void flash(HttpServletRequest request, String kind, String message) {
        HttpSession session = request.getSession(true);
        session.setAttribute("flashKind", kind);
        session.setAttribute("flash", message);
    }

    /**
     * Carga datos y selecciona la vista correspondiente. El partido y las estadísticas son
     * públicos; la administración no.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // Nunca cachear el HTML autenticado. Los recursos estáticos se versionan
        // con un parámetro ?v para evitar conservar estilos/scripts antiguos.
        response.setHeader("Cache-Control", "no-store, no-cache, max-age=0, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0L);
        response.setHeader("X-Bracket-Arena-UI", UI_RELEASE);

        String view = request.getParameter("view");
        if (view == null || view.isBlank()) {
            view = "inicio";
        }
        if (!ALLOWED_VIEWS.contains(view)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Store.User current = Web.user(request);
        boolean adminView = "admin".equals(view) || "crear".equals(view);
        if (adminView && (current == null || !current.admin())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (current != null && ("login".equals(view) || "registro".equals(view))) {
            response.sendRedirect(path(request, "inicio"));
            return;
        }

        // Se emite el token antes de renderizar formularios de Stitch.
        request.setAttribute("csrf", Web.token(request));

        // Los mensajes flash se consumen una sola vez por sesión.
        HttpSession session = request.getSession();
        request.setAttribute("flash", session.getAttribute("flash"));
        request.setAttribute("flashKind", session.getAttribute("flashKind"));
        session.removeAttribute("flash");
        session.removeAttribute("flashKind");
        request.setAttribute("view", view);

        // El detalle de partido incluye la simulación y el siguiente encuentro.
        if ("partido".equals(view)) {
            try {
                long matchId = Long.parseLong(request.getParameter("id"));
                Store.MatchDetail detail = Store.loadMatchDetail(matchId);
                if (detail == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                request.setAttribute("detail", detail);
                request.setAttribute("nextMatch", Store.nextMatchId(detail.match));
            } catch (NumberFormatException ex) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            } catch (SQLException ex) {
                log("Error consultando simulación", ex);
                response.sendError(503, "No se pudo consultar el partido");
                return;
            }
        }

        // La página de login/registro no necesita consultar equipos y partidos.
        if (!"login".equals(view) && !"registro".equals(view)) {
            try {
                request.setAttribute("state", Store.load());
            } catch (SQLException ex) {
                log("Error consultando el sistema de torneos", ex);
                request.setAttribute("state", new Store.State());
                request.setAttribute(
                        "dbError",
                        "No se pudo conectar con MySQL. Revisá database/schema/torneos.sql "
                                + "y las variables DB_URL, DB_USER y DB_PASSWORD.");
            }
        }

        String template =
                switch (view) {
                    case "login" -> "login.jsp";
                    case "registro" -> "register.jsp";
                    case "equipos" -> "teams.jsp";
                    case "partido" -> "match.jsp";
                    case "cuadro" -> "bracket.jsp";
                    case "crear" -> "create.jsp";
                    case "admin" -> "admin.jsp";
                    default -> "home.jsp";
                };
        request.getRequestDispatcher(VIEW_FOLDER + template).forward(request, response);
    }

    /**
     * Procesa acciones por POST: sesiones, equipos, torneo y resultados. Se utiliza patrón
     * POST/Redirect/GET para evitar envíos duplicados.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        if (!Web.csrfValid(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN, "Formulario expirado. Actualizá la página.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String target = "inicio";
        try {
            switch (action) {
                case "login" -> {
                    target = "login";
                    String email = request.getParameter("email");
                    String password = request.getParameter("password");
                    if (email == null
                            || email.length() > 190
                            || password == null
                            || password.length() > 128) {
                        throw new Store.RuleException("Revisá el correo y la contraseña.");
                    }
                    Store.User user = Store.login(email, password);
                    if (user == null) {
                        throw new Store.RuleException("Correo o contraseña incorrectos.");
                    }

                    // Regenerar sesión evita reutilizar el ID anterior al login.
                    HttpSession oldSession = request.getSession(false);
                    if (oldSession != null) {
                        oldSession.invalidate();
                    }
                    HttpSession session = request.getSession(true);
                    session.setAttribute("user", user);
                    session.setMaxInactiveInterval(1800);
                    Web.token(request);
                    target = "inicio";
                    flash(request, "ok", "¡Bienvenido, " + user.name + "! Ya podés participar.");
                }
                case "register" -> {
                    target = "registro";
                    Store.register(
                            request.getParameter("name"),
                            request.getParameter("email"),
                            request.getParameter("password"));
                    target = "login";
                    flash(request, "ok", "Cuenta creada. Iniciá sesión para registrar tu equipo.");
                }
                case "logout" -> {
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        session.invalidate();
                    }
                }
                case "team.create" -> {
                    requireUser(request);
                    target = "equipos";
                    Store.addTeam(
                            Web.user(request),
                            request.getParameter("name"),
                            request.getParameter("phone"),
                            request.getParameter("shield"));
                    flash(
                            request,
                            "ok",
                            "¡Equipo inscrito! Está pendiente de aprobación del administrador.");
                }
                case "team.approve", "team.reject" -> {
                    requireAdmin(request);
                    target = "admin";
                    long teamId = Long.parseLong(request.getParameter("teamId"));
                    Store.setApproval(teamId, "team.approve".equals(action));
                    flash(request, "ok", "El estado del equipo se actualizó.");
                }
                case "tournament.create" -> {
                    requireAdmin(request);
                    target = "admin";
                    Set<Long> selected = new HashSet<>();
                    String[] ids = request.getParameterValues("teamIds");
                    if (ids != null) {
                        for (String id : ids) {
                            selected.add(Long.parseLong(id));
                        }
                    }

                    // Compatibilidad con formularios anteriores: autoSimulate=on.
                    String mode = request.getParameter("simulationMode");
                    if (mode == null || mode.isBlank()) {
                        mode = "on".equals(request.getParameter("autoSimulate"))
                                ? "INSTANT" : "MANUAL";
                    }
                    Store.createTournament(
                            request.getParameter("name"),
                            request.getParameter("image"),
                            LocalDate.parse(request.getParameter("start")),
                            LocalDate.parse(request.getParameter("end")),
                            new BigDecimal(request.getParameter("prize")),
                            selected, mode);

                    if ("INSTANT".equals(mode)) {
                        Store.simulateRemaining();
                        target = "partido&id=" + Store.load().round(1).get(0).id + "&play=1";
                        flash(request, "ok",
                                "¡Torneo simulado! Los 15 resultados están disponibles.");
                    } else if ("LIVE".equals(mode)) {
                        target = "cuadro";
                        flash(request, "ok",
                                "¡Transmisión en vivo iniciada! Cada partido dura 60 segundos "
                                + "y hay 20 segundos entre encuentros. "
                                + "Inicio y Cuadro se actualizan automáticamente.");
                    } else {
                        target = "inicio";
                        flash(request, "ok",
                                "¡Torneo creado! Podés simular partido a partido "
                                + "o ingresar los marcadores.");
                    }
                }
                case "tournament.simulateLive" -> {
                    requireAdmin(request);
                    LiveTournament.startActive();
                    target = "admin";
                    flash(request, "ok",
                            "¡Modo en vivo iniciado! Los visitantes verán cada gol "
                            + "y el avance de los clasificados automáticamente.");
                }
                case "tournament.simulateAll" -> {
                    requireAdmin(request);
                    int completed = Store.simulateRemaining();
                    flash(
                            request,
                            "ok",
                            "Se simularon "
                                    + completed
                                    + " partidos. ¡Todos los resúmenes quedaron guardados!");
                }
                case "match.simulate" -> {
                    requireAdmin(request);
                    long matchId = Long.parseLong(request.getParameter("matchId"));
                    Store.simulateMatch(matchId);
                    target = "partido&id=" + matchId + "&play=1";
                    flash(
                            request,
                            "ok",
                            "¡Partido simulado! Podés reproducirlo, "
                                    + "ver sus estadísticas o saltar la animación.");
                }
                case "match.result" -> {
                    requireAdmin(request);
                    long matchId = Long.parseLong(request.getParameter("matchId"));
                    Store.recordScore(
                            matchId,
                            Integer.parseInt(request.getParameter("scoreA")),
                            Integer.parseInt(request.getParameter("scoreB")));
                    target = "partido&id=" + matchId + "&play=1";
                    flash(
                            request,
                            "ok",
                            "¡Resultado guardado! Revisá o saltá la simulación; "
                                    + "el ganador ya avanzó.");
                }
                default -> {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción desconocida");
                    return;
                }
            }
        } catch (Store.RuleException ex) {
            flash(request, "error", ex.getMessage());
        } catch (NumberFormatException | DateTimeParseException ex) {
            flash(request, "error", "Revisá los números, fechas y selecciones del formulario.");
        } catch (SQLException ex) {
            log("Error SQL en " + action, ex);
            flash(
                    request,
                    "error",
                    "No se pudo guardar la operación. "
                            + "Verificá los datos y la conexión MySQL.");
        }
        response.sendRedirect(path(request, target));
    }

    /** La inscripción requiere sesión, pero no el rol administrador. */
    private void requireUser(HttpServletRequest request) throws Store.RuleException {
        if (Web.user(request) == null) {
            throw new Store.RuleException("Iniciá sesión para realizar esta operación.");
        }
    }

    /** Las aprobaciones, simulaciones y resultados requieren rol ADMIN. */
    private void requireAdmin(HttpServletRequest request) throws Store.RuleException {
        Store.User user = Web.user(request);
        if (user == null || !user.admin()) {
            throw new Store.RuleException("Solo el administrador puede realizar esta operación.");
        }
    }
}
