package com.torneo;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.Instant;
import java.util.*;

/** Verifica la rúbrica contra MySQL: 16 equipos, 15 partidos y un campeón persistido. */
@EnabledIfEnvironmentVariable(named = "RUN_DB_TESTS", matches = "true")
public class TournamentFlowTest {
    @Test
    void fullSixteenTeamTournament() throws Exception {
        long owner;
        try (Connection c = DB.open();
                PreparedStatement p =
                        c.prepareStatement(
                                "SELECT id FROM users WHERE email='admin@torneo.local'");
                ResultSet r = p.executeQuery()) {
            assertTrue(r.next(), "El script SQL debe crear el administrador");
            owner = r.getLong(1);
        }
        String suffix = UUID.randomUUID().toString().substring(0, 8);
        Set<Long> teamIds = new HashSet<>();
        for (int i = 1; i <= 16; i++) {
            String name = "CI Equipo " + i + " " + suffix;
            long id;
            try (Connection c = DB.open();
                    PreparedStatement p =
                            c.prepareStatement(
                                    "INSERT INTO teams(name, shield_url, phone, owner_id) VALUES"
                                        + " (?, '', '88888888', ?)",
                                    Statement.RETURN_GENERATED_KEYS)) {
                p.setString(1, name);
                p.setLong(2, owner);
                p.executeUpdate();
                try (ResultSet r = p.getGeneratedKeys()) {
                    assertTrue(r.next());
                    id = r.getLong(1);
                }
            }
            teamIds.add(id);
            Store.setApproval(id, true);
        }
        assertEquals(16, Store.load().approved);
        Store.createTournament(
                "Copa CI " + suffix,
                "",
                LocalDate.now(),
                LocalDate.now().plusDays(10),
                new BigDecimal("250000.00"),
                teamIds);
        Store.State started = Store.load();
        assertEquals(15, started.matches.size());
        assertEquals(16, started.participantIds.size());
        assertEquals("ACTIVO", started.tournament.status);
        Set<Long> shuffledTeams = new HashSet<>();
        for (Store.Match m : started.round(1)) {
            assertNotNull(m.aId);
            assertNotNull(m.bId);
            shuffledTeams.add(m.aId);
            shuffledTeams.add(m.bId);
        }
        assertEquals(teamIds, shuffledTeams, "Los 16 participantes deben sortearse sin duplicados");
        Store.Match opening = started.round(1).get(0);
        assertThrows(Store.RuleException.class, () -> Store.recordScore(opening.id, 2, 2));
        assertThrows(
                Store.RuleException.class,
                () ->
                        Store.createTournament(
                                "Otra Copa",
                                "",
                                LocalDate.now(),
                                LocalDate.now().plusDays(3),
                                BigDecimal.TEN,
                                teamIds));
        for (int round = 1; round <= 4; round++) {
            List<Store.Match> matches = Store.load().round(round);
            assertEquals(16 >> round, matches.size());
            for (Store.Match match : matches) {
                assertNotNull(match.aId, "El equipo A avanzó automáticamente");
                assertNotNull(match.bId, "El equipo B avanzó automáticamente");
                Store.recordScore(match.id, 3, 1);
            }
        }
        Store.State completed = Store.load();
        assertEquals(15, completed.finalized);
        assertEquals("FINALIZADO", completed.tournament.status);
        assertNotNull(completed.tournament.championId);
        assertEquals(completed.round(4).get(0).winnerId, completed.tournament.championId);
        assertThrows(Store.RuleException.class, () -> Store.recordScore(opening.id, 1, 0));
        // El resultado manual genera una ficha accesible con los mismos goles.
        Store.MatchDetail manual = Store.loadMatchDetail(opening.id);
        assertEquals("MANUAL", manual.report.mode);
        assertEquals(manual.match.scoreA.intValue(), manual.report.total().goalsA);
        assertEquals(manual.match.scoreB.intValue(), manual.report.total().goalsB);
        assertEquals(
                100, manual.report.first.possessionA + (100 - manual.report.first.possessionA));

        // Segundo torneo sobre los mismos 16 equipos: simulación completa con un clic.
        Store.createTournament(
                "Copa Automática " + suffix,
                "",
                LocalDate.now(),
                LocalDate.now().plusDays(10),
                BigDecimal.valueOf(180000),
                teamIds);
        assertEquals(15, Store.simulateRemaining());
        Store.State automatic = Store.load();
        assertEquals("FINALIZADO", automatic.tournament.status);
        assertNotNull(automatic.tournament.championId);
        assertEquals(15, automatic.finalized);
        for (Store.Match m : automatic.matches) {
            assertTrue(m.done());
            Store.MatchDetail d = Store.loadMatchDetail(m.id);
            assertNotNull(d.report);
            assertEquals("AUTOMATICA", d.report.mode);
            assertEquals(m.scoreA.intValue(), d.report.total().goalsA);
            assertEquals(m.scoreB.intValue(), d.report.total().goalsB);
            assertTrue(d.report.first.shotsA >= d.report.first.onA);
            assertTrue(d.report.first.onA >= d.report.first.goalsA);
            assertTrue(d.report.second.shotsB >= d.report.second.onB);
            assertTrue(d.report.second.onB >= d.report.second.goalsB);
            assertEquals(
                    d.report.first.passesA + d.report.second.passesA, d.report.total().passesA);
        }
        assertThrows(Store.RuleException.class, Store::simulateRemaining);
        // Tercera edición: transmisión real controlada por reloj persistente.
        Store.createTournament(
                "Copa en vivo " + suffix, "", LocalDate.now(),
                LocalDate.now().plusDays(10), new BigDecimal("350000.00"),
                teamIds, "LIVE");
        Instant start = Instant.now().plusSeconds(2);
        Map<String, Object> kickoff = LiveTournament.tickAt(start);
        assertEquals("LIVE", kickoff.get("mode"));
        assertEquals("PLAYING", kickoff.get("phase"));
        assertEquals(0, Store.load().finalized,
                "El marcador definitivo no debe publicarse antes de 60 segundos");
        assertThrows(Store.RuleException.class, Store::simulateRemaining,
                "La simulación inmediata no debe pisar un torneo en vivo");

        Store.Match firstLive = Store.load().round(1).get(0);
        assertThrows(Store.RuleException.class,
                () -> Store.recordScore(firstLive.id, 2, 1),
                "No se permite registrar un resultado manual durante el vivo");

        Map<String, Object> breakTime = LiveTournament.tickAt(start.plusSeconds(64));
        assertEquals("BREAK", breakTime.get("phase"));
        assertEquals(1, Store.load().finalized,
                "Solo el primer encuentro debe haberse guardado");
        // Dos espectadores consultan: no debe repetirse el resultado.
        LiveTournament.tickAt(start.plusSeconds(64));
        assertEquals(1, Store.load().finalized);

        Map<String, Object> nextGame = LiveTournament.tickAt(start.plusSeconds(85));
        assertEquals("PLAYING", nextGame.get("phase"));
        assertNotEquals(firstLive.id, ((Number) nextGame.get("matchId")).longValue());

        // Adelantamos el reloj: no depende de dejar una pestaña abierta.
        Map<String, Object> completedLive = LiveTournament.tickAt(start.plusSeconds(1400));
        assertEquals("FINISHED", completedLive.get("phase"));
        Store.State liveFinished = Store.load();
        assertEquals(15, liveFinished.finalized);
        assertEquals("FINALIZADO", liveFinished.tournament.status);
        assertNotNull(liveFinished.tournament.championId);
        for (Store.Match game : liveFinished.matches) {
            assertTrue(game.done());
            assertNotNull(Store.loadMatchDetail(game.id).report);
        }
    }
}
