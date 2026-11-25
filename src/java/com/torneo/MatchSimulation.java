package com.torneo;

import java.sql.*;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Narrativa estadística ILUSTRATIVA de un partido, sin datos deportivos reales.
 * Se guarda junto con el resultado para que cualquier usuario pueda verla otra vez.
 */
public final class MatchSimulation {

    private MatchSimulation() {
        // Solo contiene lógica de generación, persistencia y lectura.
    }
    /** Métricas de uno de los dos tiempos (o el total calculado). */
    public static final class Half {
        public int number, possessionA, passesA, passesB, shotsA, shotsB, onA, onB,
                dangerousA, dangerousB, cornersA, cornersB, foulsA, foulsB;
        public int goalsA, goalsB;
        public Half(int number) { this.number = number; }
    }
    /** Evento ilustrativo de gol o sustitución, con minuto y lado del campo. */
    public static final class Event {
        public final int minute;
        public final String type, side, player, outgoing;
        Event(int minute, String type, String side, String player, String outgoing) {
            this.minute = minute; this.type = type; this.side = side;
            this.player = player; this.outgoing = outgoing;
        }
    }
    /** Informe persistido: ambos tiempos, eventos ordenados y origen del dato. */
    public static final class Report {
        public final Half first, second;
        public final List<Event> events;
        public final String mode;
        Report(Half first, Half second, List<Event> events, String mode) {
            this.first = first; this.second = second;
            this.events = Collections.unmodifiableList(events); this.mode = mode;
        }
        public Half total() {
            Half a = first, b = second, t = new Half(0);
            t.possessionA = (a.possessionA + b.possessionA) / 2;
            t.passesA = a.passesA + b.passesA; t.passesB = a.passesB + b.passesB;
            t.shotsA = a.shotsA + b.shotsA; t.shotsB = a.shotsB + b.shotsB;
            t.onA = a.onA + b.onA; t.onB = a.onB + b.onB;
            t.dangerousA = a.dangerousA + b.dangerousA; t.dangerousB = a.dangerousB + b.dangerousB;
            t.cornersA = a.cornersA + b.cornersA; t.cornersB = a.cornersB + b.cornersB;
            t.foulsA = a.foulsA + b.foulsA; t.foulsB = a.foulsB + b.foulsB;
            t.goalsA = a.goalsA + b.goalsA; t.goalsB = a.goalsB + b.goalsB;
            return t;
        }
    }
    /** Número aleatorio inclusivo dentro del intervalo solicitado. */
    private static int between(Random random, int min, int max) {
        return min + random.nextInt(max - min + 1);
    }
    /** Crea una nueva narración estadística a partir del marcador final. */
    public static Report generate(int scoreA, int scoreB, String mode) {
        return generate(scoreA, scoreB, mode, new Random(ThreadLocalRandom.current().nextLong()));
    }
    static Report generate(int scoreA, int scoreB, String mode, Random rng) {
        if (scoreA < 0 || scoreB < 0 || scoreA > 999 || scoreB > 999 || scoreA == scoreB)
            throw new IllegalArgumentException("Marcador inválido");
        if (!Arrays.asList("MANUAL", "AUTOMATICA", "RECONSTRUIDA").contains(mode))
            throw new IllegalArgumentException("Modo inválido");
        Half first = new Half(1), second = new Half(2);
        List<Event> events = new ArrayList<>();
        for (int side = 0; side <= 1; side++) {
            int goals = side == 0 ? scoreA : scoreB;
            for (int i = 0; i < goals; i++) {
                int minute = between(rng, 1, 90);
                boolean firstHalf = minute <= 45;
                if (side == 0) { if (firstHalf) first.goalsA++; else second.goalsA++; }
                else { if (firstHalf) first.goalsB++; else second.goalsB++; }
                events.add(new Event(minute, "GOL", side == 0 ? "A" : "B",
                        "Jugador #" + between(rng, 7, 11), null));
            }
            int changes = between(rng, 2, 4);
            for (int i = 0; i < changes; i++) {
                int minute = between(rng, 46, 89);
                events.add(new Event(minute, "CAMBIO", side == 0 ? "A" : "B",
                        "Jugador #" + between(rng, 12, 23),
                        "Jugador #" + between(rng, 2, 11)));
            }
        }
        events.sort(Comparator.comparingInt((Event e) -> e.minute).thenComparing(e -> e.type));
        stats(first, rng);
        stats(second, rng);
        ensureShots(first);
        ensureShots(second);
        return new Report(first, second, events, mode);
    }
    /** Distribuye métricas plausibles en un tiempo de 45 minutos. */
    private static void stats(Half half, Random rng) {
        half.possessionA = between(rng, 34, 66);
        half.passesA = 75 + half.possessionA * 4 + between(rng, -25, 25);
        half.passesB = 75 + (100-half.possessionA)*4 + between(rng, -25, 25);
        half.onA = between(rng, 1, 5); half.onB = between(rng, 1, 5);
        half.shotsA = half.onA + between(rng, 1, 6); half.shotsB = half.onB + between(rng, 1, 6);
        half.dangerousA = between(rng, 9, 24); half.dangerousB = between(rng, 9, 24);
        half.cornersA = between(rng, 0, 6); half.cornersB = between(rng, 0, 6);
        half.foulsA = between(rng, 3, 10); half.foulsB = between(rng, 3, 10);
    }
    /** Garantiza que tiros a puerta no sean menores que goles ni mayores que tiros. */
    private static void ensureShots(Half half) {
        half.onA = Math.max(half.onA, half.goalsA);
        half.onB = Math.max(half.onB, half.goalsB);
        half.shotsA = Math.max(half.shotsA, half.onA);
        half.shotsB = Math.max(half.shotsB, half.onB);
    }
    /** Inserta los dos tiempos y los eventos en la transacción recibida. */
    public static void save(Connection c, long matchId, Report report) throws SQLException {
        try (PreparedStatement p = c.prepareStatement("INSERT INTO match_simulations(match_id,mode) VALUES (?,?)")) {
            p.setLong(1,matchId); p.setString(2, report.mode); p.executeUpdate();
        }
        try (PreparedStatement p = c.prepareStatement(
                "INSERT INTO match_half_stats(match_id,half_no,possession_a,passes_a,passes_b," +
                "shots_a,shots_b,on_target_a,on_target_b,dangerous_a,dangerous_b," +
                "corners_a,corners_b,fouls_a,fouls_b) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
            for (Half h : new Half[]{report.first, report.second}) {
                p.setLong(1,matchId); p.setInt(2,h.number); p.setInt(3,h.possessionA);
                p.setInt(4,h.passesA); p.setInt(5,h.passesB);
                p.setInt(6,h.shotsA); p.setInt(7,h.shotsB);
                p.setInt(8,h.onA); p.setInt(9,h.onB);
                p.setInt(10,h.dangerousA); p.setInt(11,h.dangerousB);
                p.setInt(12,h.cornersA); p.setInt(13,h.cornersB);
                p.setInt(14,h.foulsA); p.setInt(15,h.foulsB);
                p.addBatch();
            }
            p.executeBatch();
        }
        try (PreparedStatement p = c.prepareStatement(
                "INSERT INTO match_events(match_id,minute_no,event_type,team_side,player_name,player_out) VALUES (?,?,?,?,?,?)")) {
            for (Event event : report.events) {
                p.setLong(1,matchId); p.setInt(2,event.minute); p.setString(3,event.type);
                p.setString(4,event.side); p.setString(5,event.player);
                p.setString(6,event.outgoing); p.addBatch();
            }
            p.executeBatch();
        }
    }
    /** Reconstruye un informe ya guardado a partir de sus tablas SQL. */
    public static Report read(Connection c, long matchId) throws SQLException {
        String mode;
        try (PreparedStatement p = c.prepareStatement("SELECT mode FROM match_simulations WHERE match_id=?")) {
            p.setLong(1,matchId);
            try (ResultSet r = p.executeQuery()) {
                if (!r.next()) return null;
                mode = r.getString(1);
            }
        }
        Half[] halves = {new Half(1),new Half(2)};
        try (PreparedStatement p = c.prepareStatement("SELECT * FROM match_half_stats WHERE match_id=?")) {
            p.setLong(1,matchId);
            try (ResultSet r = p.executeQuery()) {
                int count = 0;
                while (r.next()) {
                    int number = r.getInt("half_no");
                    if (number < 1 || number > 2) throw new SQLException("Período no válido");
                    Half h = halves[number-1]; count++;
                    h.possessionA = r.getInt("possession_a");
                    h.passesA = r.getInt("passes_a"); h.passesB = r.getInt("passes_b");
                    h.shotsA = r.getInt("shots_a"); h.shotsB = r.getInt("shots_b");
                    h.onA = r.getInt("on_target_a"); h.onB = r.getInt("on_target_b");
                    h.dangerousA = r.getInt("dangerous_a"); h.dangerousB = r.getInt("dangerous_b");
                    h.cornersA = r.getInt("corners_a"); h.cornersB = r.getInt("corners_b");
                    h.foulsA = r.getInt("fouls_a"); h.foulsB = r.getInt("fouls_b");
                }
                if (count != 2) throw new SQLException("Informe incompleto para partido " + matchId);
            }
        }
        List<Event> events = new ArrayList<>();
        try (PreparedStatement p = c.prepareStatement("SELECT * FROM match_events WHERE match_id=? ORDER BY minute_no,id")) {
            p.setLong(1,matchId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    Event e = new Event(r.getInt("minute_no"),r.getString("event_type"),r.getString("team_side"),r.getString("player_name"),r.getString("player_out"));
                    events.add(e);
                    if ("GOL".equals(e.type)) {
                        Half h = e.minute <= 45 ? halves[0] : halves[1];
                        if ("A".equals(e.side)) h.goalsA++; else h.goalsB++;
                    }
                }
            }
        }
        return new Report(halves[0],halves[1],events,mode);
    }
}
