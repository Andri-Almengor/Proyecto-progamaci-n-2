package com.torneo;

import static org.junit.jupiter.api.Assertions.*;
import java.util.Random;
import org.junit.jupiter.api.Test;

/** Las estadísticas ficticias respetan cada marcador y la duración del encuentro. */
public class MatchSimulationTest {
    @Test void halftimeAndTotalAreConsistent() {
        for (int a=0;a<=5;a++) for (int b=0;b<=5;b++) {
            if(a==b) continue;
            MatchSimulation.Report report = MatchSimulation.generate(a,b,"AUTOMATICA",new Random(22+a*33+b));
            assertEquals(a, report.total().goalsA);
            assertEquals(b, report.total().goalsB);
            assertEquals(report.first.goalsA+report.second.goalsA, a);
            assertEquals(report.first.goalsB+report.second.goalsB, b);
            assertEquals(report.first.passesA+report.second.passesA, report.total().passesA);
            assertEquals(report.first.passesB+report.second.passesB, report.total().passesB);
            assertEquals(report.first.shotsA+report.second.shotsA, report.total().shotsA);
            assertEquals((report.first.possessionA+report.second.possessionA)/2, report.total().possessionA);
            assertTrue(report.first.shotsA>=report.first.onA);
            assertTrue(report.first.onA>=report.first.goalsA);
            assertTrue(report.first.shotsB>=report.first.onB);
            assertTrue(report.first.onB>=report.first.goalsB);
            assertTrue(report.second.shotsA>=report.second.onA);
            assertTrue(report.second.onA>=report.second.goalsA);
            assertTrue(report.second.shotsB>=report.second.onB);
            assertTrue(report.second.onB>=report.second.goalsB);
            int last = 0;
            int goals=0, changes=0;
            for (MatchSimulation.Event e: report.events) {
                assertTrue(e.minute>=1 && e.minute<=90);
                assertTrue(e.minute>=last);
                last=e.minute;
                if ("GOL".equals(e.type)) goals++;
                if ("CAMBIO".equals(e.type)) changes++;
            }
            assertEquals(a+b, goals);
            assertTrue(changes>=4 && changes<=8);
        }
    }
    @Test void tieIsForbidden() {
        assertThrows(IllegalArgumentException.class, () ->
                MatchSimulation.generate(1,1,"MANUAL",new Random(1)));
    }
}
