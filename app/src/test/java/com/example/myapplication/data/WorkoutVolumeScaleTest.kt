package com.example.myapplication.data

import org.junit.Assert.assertEquals
import org.junit.Test

class WorkoutVolumeScaleTest {
    @Test
    fun `scale rounds down and always keeps one set`() {
        assertEquals(3, scaledSets(3, 100))
        assertEquals(2, scaledSets(3, 70))
        assertEquals(1, scaledSets(1, 70))
        assertEquals(1, scaledSets(1, 1))
    }
}
