package com.example.myapplication.feature.today

import com.example.myapplication.core.program.ProgramPhase
import org.junit.Assert.assertEquals
import org.junit.Test

class TodayPhaseLabelTest {
    @Test
    fun `phase labels are concise Vietnamese copy`() {
        assertEquals("Giai đoạn làm quen", ProgramPhase.FOUNDATION.labelVi())
        assertEquals("Giai đoạn phát triển", ProgramPhase.BUILD.labelVi())
        assertEquals("Giai đoạn củng cố", ProgramPhase.CONSOLIDATE.labelVi())
        assertEquals("Giai đoạn giảm tải", ProgramPhase.DELOAD.labelVi())
    }
}
