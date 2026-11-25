package com.torneo;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Endpoint de solo lectura que conecta la interfaz original de Stitch con MySQL.
 *
 * <p>Responde con el torneo más reciente, equipos, enfrentamientos, eventos de
 * partidos y sus estadísticas. No expone teléfonos de equipos a visitantes ni
 * presenta sanciones deportivas que la base todavía no registre.
 *
 * <p>Las estadísticas de los reportes son ilustrativas: se generan y guardan
 * mediante {@link MatchSimulation}, no se recopilan de encuentros reales.
 */
@WebServlet("/arena-data")
public final class ArenaDataServlet extends HttpServlet {

    /** Crea un objeto JSON ordenado a partir de pares clave-valor. */
    private static Map<String, Object> object(Object... fields) {
        Map<String, Object> result = new LinkedHashMap<>();
        for (int index = 0; index < fields.length; index += 2) {
            result.put((String) fields[index], fields[index + 1]);
        }
        return result;
    }

    private static String safe(String value) {
        return value == null ? "" : value;
    }

    /** Convierte las estadísticas de un tiempo a la estructura esperada por Stitch. */
    private static Map<String, Object> half(MatchSimulation.Half period) {
        return object(
                "period", period.number,
                "possessionA", period.possessionA,
                "possessionB", 100 - period.possessionA,
                "passesA", period.passesA,
                "passesB", period.passesB,
                "shotsA", period.shotsA,
                "shotsB", period.shotsB,
                "onA", period.onA,
                "onB", period.onB,
                "dangerousA", period.dangerousA,
                "dangerousB", period.dangerousB,
                "cornersA", period.cornersA,
                "cornersB", period.cornersB,
                "foulsA", period.foulsA,
                "foulsB", period.foulsB,
                "goalsA", period.goalsA,
                "goalsB", period.goalsB);
    }

    /**
     * Serializador JSON pequeño para las estructuras conocidas de la API.
     * Escapa <, > y & para impedir que cadenas de usuario formen HTML ejecutable.
     */
    private static void appendJson(StringBuilder output, Object value) {
        if (value == null) {
            output.append("null");
            return;
        }
        if (value instanceof Number || value instanceof Boolean) {
            output.append(value);
            return;
        }
        if (value instanceof Map<?, ?> map) {
            output.append('{');
            boolean first = true;
            for (Map.Entry<?, ?> field : map.entrySet()) {
                if (!first) {
                    output.append(',');
                }
                first = false;
                appendJson(output, String.valueOf(field.getKey()));
                output.append(':');
                appendJson(output, field.getValue());
            }
            output.append('}');
            return;
        }
        if (value instanceof Iterable<?> collection) {
            output.append('[');
            boolean first = true;
            for (Object item : collection) {
                if (!first) {
                    output.append(',');
                }
                first = false;
                appendJson(output, item);
            }
            output.append(']');
            return;
        }

        output.append('"');
        for (char character : value.toString().toCharArray()) {
            switch (character) {
                case '"' -> output.append("\\\"");
                case '\\' -> output.append("\\\\");
                case '\n' -> output.append("\\n");
                case '\r' -> output.append("\\r");
                case '\t' -> output.append("\\t");
                case '<' -> output.append("\\u003c");
                case '>' -> output.append("\\u003e");
                case '&' -> output.append("\\u0026");
                default -> {
                    if (character < 0x20 || character == 0x2028 || character == 0x2029) {
                        output.append(String.format("\\u%04x", (int) character));
                    } else {
                        output.append(character);
                    }
                }
            }
        }
        output.append('"');
    }

    /**
     * Consulta los datos persistidos y devuelve JSON al navegador.
     * No requiere login porque el tablero y las estadísticas son públicos.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        try {
            Store.State state = Store.load();
            Store.User currentUser = Web.user(request);

            List<Object> teams = new ArrayList<>();
            List<Object> matches = new ArrayList<>();
            List<Object> scorers = new ArrayList<>();
            Map<String, Map<String, Object>> scorersByKey = new HashMap<>();

            int totalGoals = 0;
            int totalFouls = 0;

            // Los números de contacto son privados para visitantes y otros usuarios.
            for (Store.Team team : state.teams) {
                boolean mayReadPhone = currentUser != null
                        && (currentUser.admin() || currentUser.id == team.ownerId);

                teams.add(object(
                        "id", team.id,
                        "name", team.name,
                        "shield", safe(team.shield),
                        "status", team.status,
                        "owner", team.owner,
                        "phone", mayReadPhone ? team.phone : "",
                        "participant", state.participantIds.contains(team.id)));
            }

            // Cada encuentro puede tener un reporte con estadísticas y eventos.
            for (Store.Match game : state.matches) {
                Map<String, Object> match = object(
                        "id", game.id,
                        "round", game.round,
                        "position", game.position,
                        "aId", game.aId,
                        "bId", game.bId,
                        "aName", safe(game.aName),
                        "bName", safe(game.bName),
                        "aShield", safe(game.aShield),
                        "bShield", safe(game.bShield),
                        "scoreA", game.scoreA,
                        "scoreB", game.scoreB,
                        "winnerId", game.winnerId,
                        "done", game.done(),
                        "ready", !game.done() && game.aId != null && game.bId != null);

                if (game.done()) {
                    Store.MatchDetail detail = Store.loadMatchDetail(game.id);
                    MatchSimulation.Report report = detail.report;
                    if (report != null) {
                        Map<String, Object> reportJson = object(
                                "mode", report.mode,
                                "first", half(report.first),
                                "second", half(report.second),
                                "total", half(report.total()));

                        List<Object> events = new ArrayList<>();
                        for (MatchSimulation.Event event : report.events) {
                            boolean homeTeam = "A".equals(event.side);
                            Long teamId = homeTeam ? game.aId : game.bId;
                            String teamName = homeTeam ? safe(game.aName) : safe(game.bName);

                            events.add(object(
                                    "minute", event.minute,
                                    "type", event.type,
                                    "side", event.side,
                                    "player", event.player,
                                    "outgoing", event.outgoing,
                                    "team", teamName));

                            // Solo eventos GOL contribuyen a la tabla de goleadores.
                            if ("GOL".equals(event.type) && teamId != null) {
                                String key = teamId + "/" + event.player;
                                Map<String, Object> scorer = scorersByKey.get(key);
                                if (scorer == null) {
                                    scorer = object(
                                            "player", event.player,
                                            "team", teamName,
                                            "teamId", teamId,
                                            "goals", 0,
                                            "matches", 0);
                                    scorersByKey.put(key, scorer);
                                }
                                int goals = ((Number) scorer.get("goals")).intValue();
                                scorer.put("goals", goals + 1);
                            }
                        }

                        reportJson.put("events", events);
                        match.put("report", reportJson);
                        totalGoals += game.scoreA + game.scoreB;
                        totalFouls += report.total().foulsA + report.total().foulsB;
                    }
                }
                matches.add(match);
            }

            // Goleadores agrupados por ID de equipo y número ficticio de jugador.
            for (Map<String, Object> scorer : scorersByKey.values()) {
                long teamId = ((Number) scorer.get("teamId")).longValue();
                long gamesPlayed = state.matches.stream()
                        .filter(game -> game.done()
                                && (Long.valueOf(teamId).equals(game.aId)
                                    || Long.valueOf(teamId).equals(game.bId)))
                        .count();
                scorer.put("matches", gamesPlayed);
                scorers.add(scorer);
            }
            scorers.sort((left, right) -> {
                Map<?, ?> a = (Map<?, ?>) left;
                Map<?, ?> b = (Map<?, ?>) right;
                int goalsA = ((Number) a.get("goals")).intValue();
                int goalsB = ((Number) b.get("goals")).intValue();
                int comparison = Integer.compare(goalsB, goalsA);
                return comparison != 0
                        ? comparison
                        : String.valueOf(a.get("player")).compareTo(String.valueOf(b.get("player")));
            });

            Map<String, Object> tournament = null;
            if (state.tournament != null) {
                Store.Tournament cup = state.tournament;
                tournament = object(
                        "id", cup.id,
                        "name", cup.name,
                        "image", safe(cup.image),
                        "start", cup.start.toString(),
                        "end", cup.end.toString(),
                        "prize", cup.prize,
                        "status", cup.status,
                        "championName", safe(cup.championName),
                        "championId", cup.championId,
                        "championShield", safe(cup.championShield));
            }

            Map<String, Object> user = currentUser == null
                    ? null
                    : object(
                            "id", currentUser.id,
                            "name", currentUser.name,
                            "role", currentUser.role,
                            "admin", currentUser.admin());

            // Las tarjetas no forman parte del esquema; nunca inventar sanciones.
            Map<String, Object> root = object(
                    "ok", true,
                    "year", 2026,
                    "tournament", tournament,
                    "user", user,
                    "csrf", Web.token(request),
                    "approved", state.approved,
                    "pending", state.pending,
                    "finalized", state.finalized,
                    "totalMatches", 15,
                    "totalGoals", totalGoals,
                    "totalFouls", totalFouls,
                    "teams", teams,
                    "matches", matches,
                    "scorers", scorers,
                    "discipline", object(
                            "fouls", totalFouls,
                            "yellow", null,
                            "red", null,
                            "explanation", "El sistema registra faltas simuladas, "
                                    + "pero todavía no registra tarjetas amarillas o rojas."));

            StringBuilder output = new StringBuilder(19000);
            appendJson(output, root);
            response.getWriter().write(output.toString());
        } catch (SQLException ex) {
            log("Error preparando los datos del tablero de Stitch", ex);
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write(
                    "{\"ok\":false,\"error\":\"No se pudo consultar MySQL. "
                    + "Verificá DB_URL, DB_USER y DB_PASSWORD.\"}");
        }
    }
}
