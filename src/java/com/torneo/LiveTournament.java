package com.torneo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.security.SecureRandom;

/**
 * Orquesta el modo «partido a partido» de un torneo.
 *
 * <p>Cada encuentro dura 60 segundos reales y tiene 20 segundos de descanso.
 * El reloj, resultado planificado y semilla del informe se guardan en MySQL;
 * ningún navegador, sesión de administrador o hilo en memoria controla el avance.
 *
 * <p>La llamada a /arena-data actualiza el estado pendiente dentro de una
 * transacción bloqueada. Si no hay visitantes durante un rato, la siguiente
 * consulta recupera todos los partidos cuyo tiempo ya haya transcurrido.
 * Dos visitantes no pueden finalizar el mismo encuentro dos veces.
 *
 * <p>Las cifras deportivas son totalmente SIMULADAS, nunca resultados reales.
 */
public final class LiveTournament {
    public static final int MATCH_SECONDS = 60;
    public static final int BREAK_SECONDS = 20;
    private static final SecureRandom RNG = new SecureRandom();

    private LiveTournament() {}

    private static Map<String, Object> obj(Object... pairs) {
        Map<String, Object> result = new LinkedHashMap<>();
        for (int i = 0; i < pairs.length; i += 2) {
            result.put((String) pairs[i], pairs[i + 1]);
        }
        return result;
    }

    /** Llamar dentro de la transacción que ya crea el torneo y tiene el candado. */
    static void schedule(Connection connection, long tournamentId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "INSERT INTO tournament_live_runs"
                + " (tournament_id,status,next_start_at) VALUES (?, 'RUNNING', ?)")) {
            statement.setLong(1, tournamentId);
            statement.setTimestamp(2, Timestamp.from(Instant.now()));
            statement.executeUpdate();
        }
    }

    /**
     * Impide que una acción manual altere un cuadro que ya tiene
     * un simulador en ejecución. El llamador debe haber bloqueado system_lock.
     */
    static void assertNotRunning(Connection connection) throws SQLException, Store.RuleException {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT tournament_id FROM tournament_live_runs"
                + " WHERE status='RUNNING' LIMIT 1 FOR UPDATE");
             ResultSet rows = statement.executeQuery()) {
            if (rows.next()) {
                throw new Store.RuleException(
                        "El torneo se está disputando en vivo. "
                        + "Esperá a que termine la secuencia de partidos.");
            }
        }
    }

    /** Permite comenzar un modo secuencial desde Administración sin crear otra copa. */
    public static void startActive() throws SQLException, Store.RuleException {
        try (Connection connection = DB.open()) {
            connection.setAutoCommit(false);
            try {
                Store.lockCoordinator(connection);
                long tournamentId;
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT id FROM tournaments WHERE status='ACTIVO' LIMIT 1 FOR UPDATE");
                     ResultSet rows = statement.executeQuery()) {
                    if (!rows.next()) {
                        throw new Store.RuleException("No hay un torneo activo.");
                    }
                    tournamentId = rows.getLong(1);
                }
                assertNotRunning(connection);
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT tournament_id FROM tournament_live_runs WHERE tournament_id=?")) {
                    statement.setLong(1, tournamentId);
                    try (ResultSet rows = statement.executeQuery()) {
                        if (rows.next()) {
                            throw new Store.RuleException(
                                    "Este torneo ya tuvo una simulación secuencial.");
                        }
                    }
                }
                // Se admite continuar un torneo que tenga resultados manuales;
                // únicamente los partidos pendientes se disputarán en vivo.
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT COUNT(*) FROM matches WHERE tournament_id=?"
                        + " AND status='PENDIENTE'")) {
                    statement.setLong(1, tournamentId);
                    try (ResultSet rows = statement.executeQuery()) {
                        rows.next();
                        if (rows.getInt(1) == 0) {
                            throw new Store.RuleException("No quedan encuentros pendientes.");
                        }
                    }
                }
                schedule(connection, tournamentId);
                connection.commit();
            } catch (SQLException | Store.RuleException | RuntimeException ex) {
                connection.rollback();
                throw ex;
            }
        }
    }

    /**
     * Recalcula el progreso usando el tiempo real y devuelve exclusivamente
     * lo que el visitante puede conocer en este instante.
     */
    public static Map<String, Object> tick() throws SQLException {
        return tickAt(Instant.now());
    }

    /** Reloj inyectable para pruebas deterministas sin esperar 20 minutos. */
    static Map<String, Object> tickAt(Instant now) throws SQLException {
        try (Connection connection = DB.open()) {
            connection.setAutoCommit(false);
            try {
                Store.lockCoordinator(connection);
                long tournamentId;
                String status;
                Long matchId;
                Instant startedAt;
                Instant nextAt;
                Integer scoreA, scoreB;
                Long seed;
                String tournamentStatus;
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT r.*, t.status AS tournament_status"
                        + " FROM tournament_live_runs r JOIN tournaments t"
                        + " ON t.id=r.tournament_id"
                        + " WHERE t.id=(SELECT MAX(id) FROM tournaments)"
                        + " FOR UPDATE");
                     ResultSet rows = statement.executeQuery()) {
                    if (!rows.next()) {
                        connection.commit();
                        return obj("mode", "NORMAL", "phase", "NONE");
                    }
                    tournamentId = rows.getLong("tournament_id");
                    status = rows.getString("status");
                    tournamentStatus = rows.getString("tournament_status");
                    long current = rows.getLong("current_match_id");
                    matchId = rows.wasNull() ? null : current;
                    Timestamp started = rows.getTimestamp("match_started_at");
                    Timestamp next = rows.getTimestamp("next_start_at");
                    startedAt = started == null ? null : started.toInstant();
                    nextAt = next.toInstant();
                    int a = rows.getInt("planned_score_a");
                    scoreA = rows.wasNull() ? null : a;
                    int b = rows.getInt("planned_score_b");
                    scoreB = rows.wasNull() ? null : b;
                    long randomSeed = rows.getLong("rng_seed");
                    seed = rows.wasNull() ? null : randomSeed;
                }

                if ("FINISHED".equals(status) || !"ACTIVO".equals(tournamentStatus)) {
                    connection.commit();
                    return obj("mode", "LIVE", "phase", "FINISHED",
                            "matchSeconds", MATCH_SECONDS, "breakSeconds", BREAK_SECONDS);
                }

                // Cada iteración cierra un partido vencido o programa el siguiente.
                // Como solo hay 15 encuentros, este bucle está estrictamente limitado.
                for (int step = 0; step < 16; step++) {
                    if (matchId != null) {
                        Instant end = startedAt.plusSeconds(MATCH_SECONDS);
                        if (now.isBefore(end)) {
                            Map<String, Object> live = runningSnapshot(
                                    connection, matchId, startedAt, scoreA, scoreB, seed, now);
                            connection.commit();
                            return live;
                        }
                        MatchSimulation.Report report = MatchSimulation.generate(
                                scoreA, scoreB, "AUTOMATICA", new Random(seed));
                        Store.finishMatchScheduled(connection, matchId, scoreA, scoreB, report);

                        // Esta pausa pertenece al tiempo previsto, no al instante
                        // en el que llegó la siguiente petición HTTP.
                        nextAt = startedAt.plusSeconds(MATCH_SECONDS + BREAK_SECONDS);
                        matchId = null;
                        startedAt = null;
                        scoreA = null;
                        scoreB = null;
                        seed = null;
                        try (PreparedStatement statement = connection.prepareStatement(
                                "UPDATE tournament_live_runs SET current_match_id=NULL,"
                                + " match_started_at=NULL, planned_score_a=NULL,"
                                + " planned_score_b=NULL, rng_seed=NULL,next_start_at=?"
                                + " WHERE tournament_id=?")) {
                            statement.setTimestamp(1, Timestamp.from(nextAt));
                            statement.setLong(2, tournamentId);
                            statement.executeUpdate();
                        }
                    }

                    Long nextMatch = nextReadyMatch(connection, tournamentId);
                    if (nextMatch == null) {
                        try (PreparedStatement statement = connection.prepareStatement(
                                "UPDATE tournament_live_runs SET status='FINISHED'"
                                + " WHERE tournament_id=?")) {
                            statement.setLong(1, tournamentId);
                            statement.executeUpdate();
                        }
                        connection.commit();
                        return obj("mode", "LIVE", "phase", "FINISHED",
                                "matchSeconds", MATCH_SECONDS, "breakSeconds", BREAK_SECONDS);
                    }

                    if (now.isBefore(nextAt)) {
                        int remaining = (int) Math.max(0,
                                (Duration.between(now, nextAt).toMillis() + 999) / 1000);
                        connection.commit();
                        return obj("mode", "LIVE", "phase", "BREAK",
                                "nextMatchId", nextMatch,
                                "remainingSeconds", remaining,
                                "matchSeconds", MATCH_SECONDS, "breakSeconds", BREAK_SECONDS);
                    }

                    int a = RNG.nextInt(5);
                    int b = RNG.nextInt(5);
                    if (a == b) b = (b + 1) % 5;
                    long randomSeed = RNG.nextLong();
                    try (PreparedStatement statement = connection.prepareStatement(
                            "UPDATE tournament_live_runs SET current_match_id=?,"
                            + " match_started_at=?,planned_score_a=?,"
                            + " planned_score_b=?,rng_seed=? WHERE tournament_id=?")) {
                        statement.setLong(1, nextMatch);
                        statement.setTimestamp(2, Timestamp.from(nextAt));
                        statement.setInt(3, a);
                        statement.setInt(4, b);
                        statement.setLong(5, randomSeed);
                        statement.setLong(6, tournamentId);
                        statement.executeUpdate();
                    }
                    matchId = nextMatch;
                    startedAt = nextAt;
                    scoreA = a;
                    scoreB = b;
                    seed = randomSeed;
                }

                throw new SQLException("Se superó el máximo de 15 partidos por torneo.");
            } catch (SQLException | Store.RuleException | RuntimeException ex) {
                connection.rollback();
                if (ex instanceof SQLException sql) throw sql;
                throw new SQLException("No fue posible avanzar el torneo en vivo", ex);
            }
        }
    }

    /** Siguiente partido listo según ronda y posición, igual que el motor normal. */
    private static Long nextReadyMatch(Connection connection, long tournamentId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT id FROM matches WHERE tournament_id=? AND status='PENDIENTE'"
                + " AND team_a_id IS NOT NULL AND team_b_id IS NOT NULL"
                + " ORDER BY round_no,match_no LIMIT 1")) {
            statement.setLong(1, tournamentId);
            try (ResultSet rows = statement.executeQuery()) {
                return rows.next() ? rows.getLong(1) : null;
            }
        }
    }

    /** Muestra goles y eventos solo hasta el minuto virtual actual, sin spoilers. */
    private static Map<String, Object> runningSnapshot(
            Connection connection, long matchId, Instant startedAt,
            int scoreA, int scoreB, long seed, Instant now) throws SQLException {
        int elapsed = (int) Math.max(0, Math.min(MATCH_SECONDS - 1,
                Duration.between(startedAt, now).toSeconds()));
        int minute = (int) (elapsed * 90L / MATCH_SECONDS);
        MatchSimulation.Report report = MatchSimulation.generate(
                scoreA, scoreB, "AUTOMATICA", new Random(seed));
        int goalsA = 0;
        int goalsB = 0;
        List<Object> events = new ArrayList<>();
        for (MatchSimulation.Event event : report.events) {
            if (event.minute > minute) continue;
            events.add(obj("minute", event.minute, "type", event.type,
                    "side", event.side, "player", event.player, "outgoing", event.outgoing));
            if ("GOL".equals(event.type)) {
                if ("A".equals(event.side)) goalsA++;
                else goalsB++;
            }
        }
        int firstMinutes = Math.min(45, minute);
        int secondMinutes = Math.max(0, minute - 45);
        Map<String, Object> first = partialHalf(report.first, firstMinutes);
        Map<String, Object> second = partialHalf(report.second, secondMinutes);

        int round, position;
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT round_no, match_no FROM matches WHERE id=?")) {
            statement.setLong(1, matchId);
            try (ResultSet rows = statement.executeQuery()) {
                if (!rows.next()) throw new SQLException("Partido en vivo no encontrado.");
                round = rows.getInt(1);
                position = rows.getInt(2);
            }
        }
        return obj("mode", "LIVE", "phase", "PLAYING",
                "matchId", matchId, "round", round, "position", position,
                "minute", minute, "scoreA", goalsA, "scoreB", goalsB,
                "events", events, "first", first, "second", second,
                "remainingSeconds", MATCH_SECONDS - elapsed,
                "matchSeconds", MATCH_SECONDS, "breakSeconds", BREAK_SECONDS);
    }

    private static Map<String, Object> partialHalf(MatchSimulation.Half half, int minutes) {
        double fraction = Math.min(45, Math.max(0, minutes)) / 45.0;
        return obj("period", half.number,
                "possessionA", minutes == 0 ? 50 : half.possessionA,
                "possessionB", minutes == 0 ? 50 : 100 - half.possessionA,
                "passesA", (int) Math.floor(half.passesA * fraction),
                "passesB", (int) Math.floor(half.passesB * fraction),
                "shotsA", (int) Math.floor(half.shotsA * fraction),
                "shotsB", (int) Math.floor(half.shotsB * fraction),
                "onA", (int) Math.floor(half.onA * fraction),
                "onB", (int) Math.floor(half.onB * fraction),
                "dangerousA", (int) Math.floor(half.dangerousA * fraction),
                "dangerousB", (int) Math.floor(half.dangerousB * fraction),
                "cornersA", (int) Math.floor(half.cornersA * fraction),
                "cornersB", (int) Math.floor(half.cornersB * fraction),
                "foulsA", (int) Math.floor(half.foulsA * fraction),
                "foulsB", (int) Math.floor(half.foulsB * fraction));
    }
}
