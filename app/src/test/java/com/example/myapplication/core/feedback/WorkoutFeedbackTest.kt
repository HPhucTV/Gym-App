package com.example.myapplication.core.feedback

import org.junit.Assert.assertEquals
import org.junit.Test

class WorkoutFeedbackTest {
    @Test
    fun `rating score preserves easy right hard ordering`() {
        assertEquals(-1, WorkoutDifficulty.EASY.score)
        assertEquals(0, WorkoutDifficulty.RIGHT.score)
        assertEquals(1, WorkoutDifficulty.HARD.score)
    }
}
