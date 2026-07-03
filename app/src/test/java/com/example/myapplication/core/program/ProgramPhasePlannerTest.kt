package com.example.myapplication.core.program

import com.example.myapplication.core.program.ProgramPhase.BUILD
import com.example.myapplication.core.program.ProgramPhase.CONSOLIDATE
import com.example.myapplication.core.program.ProgramPhase.DELOAD
import com.example.myapplication.core.program.ProgramPhase.FOUNDATION
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Test

class ProgramPhasePlannerTest {
    @Test
    fun `eight week plan uses foundation build consolidate and deload phases`() {
        val phases = (1..8).map { ProgramPhasePlanner.phaseFor(it, 8) }

        assertEquals(
            listOf(FOUNDATION, FOUNDATION, BUILD, BUILD, BUILD, CONSOLIDATE, CONSOLIDATE, DELOAD),
            phases,
        )
    }

    @Test
    fun `short plan does not force a deload week`() {
        assertEquals(listOf(CONSOLIDATE), (1..1).map { ProgramPhasePlanner.phaseFor(it, 1) })
        assertEquals(
            listOf(BUILD, BUILD, CONSOLIDATE),
            (1..3).map { ProgramPhasePlanner.phaseFor(it, 3) },
        )
    }

    @Test
    fun `phase rejects a week outside program duration`() {
        assertThrows(IllegalArgumentException::class.java) { ProgramPhasePlanner.phaseFor(0, 8) }
        assertThrows(IllegalArgumentException::class.java) { ProgramPhasePlanner.phaseFor(9, 8) }
    }
}
