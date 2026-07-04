package com.example.myapplication.core.program

import java.time.DayOfWeek
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class ScheduleReschedulerTest {
    private val sessions = listOf(
        ReschedulableSession(1, 0, 100, completedEpochDay = 100, demanding = true),
        ReschedulableSession(2, 1, 102, completedEpochDay = null, demanding = true),
        ReschedulableSession(3, 2, 104, completedEpochDay = null, demanding = true),
        ReschedulableSession(4, 3, 107, completedEpochDay = null, demanding = false),
    )

    @Test
    fun `moves pending session earlier and never changes completed rows`() {
        val preview = ScheduleRescheduler.preview(
            sessions, 2, 101, todayEpochDay = 100,
            trainingDays = setOf(day(101), day(103), day(106)),
        )

        assertEquals(listOf(2L, 3L, 4L), preview.changes.map { it.sessionId })
        assertTrue(preview.changes.none { it.sessionId == 1L })
        assertEquals(listOf(101L, 103L, 106L), preview.changes.map { it.newEpochDay })
    }

    @Test
    fun `moves later over week boundary while preserving sequence`() {
        val preview = ScheduleRescheduler.preview(
            sessions, 2, 108, todayEpochDay = 100,
            trainingDays = setOf(day(108), day(110), day(113)),
        )

        assertEquals(listOf(108L, 110L, 113L), preview.changes.map { it.newEpochDay })
        assertEquals(preview.changes.sortedBy { it.newEpochDay }, preview.changes)
    }

    @Test
    fun `warns when anchor is not a selected training weekday`() {
        val preview = ScheduleRescheduler.preview(
            sessions, 2, 103, todayEpochDay = 100,
            trainingDays = setOf(day(102), day(104)),
        )

        assertTrue(preview.warningsVi.any { "ngày tập" in it })
        assertEquals(103L, preview.changes.first().newEpochDay)
    }

    @Test
    fun `warns for consecutive demanding sessions`() {
        val preview = ScheduleRescheduler.preview(
            sessions, 2, 101, todayEpochDay = 100,
            trainingDays = setOf(day(101), day(102), day(105)),
        )

        assertTrue(preview.warningsVi.any { "liên tiếp" in it })
    }

    @Test
    fun `rejects past date and arithmetic overflow`() {
        assertThrows(IllegalArgumentException::class.java) {
            ScheduleRescheduler.preview(sessions, 2, 99, 100, setOf(day(100)))
        }
        assertThrows(ArithmeticException::class.java) {
            ScheduleRescheduler.preview(
                sessions,
                2,
                Long.MAX_VALUE,
                Long.MAX_VALUE,
                setOf(DayOfWeek.MONDAY),
            )
        }
    }

    private fun day(epochDay: Long): DayOfWeek = java.time.LocalDate.ofEpochDay(epochDay).dayOfWeek
}
