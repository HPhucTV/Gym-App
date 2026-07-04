package com.example.myapplication.core.progress

import com.example.myapplication.core.feedback.WorkoutDifficulty
import com.example.myapplication.core.feedback.WorkoutFeedback
import com.example.myapplication.core.model.WorkoutHistoryEntry
import java.time.LocalDate
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class WeeklyInsightEngineTest {
    private val today = day("2026-07-06")

    @Test
    fun `fewer than two complete weeks returns no conclusions`() {
        val history = listOf(entry(1, "2026-06-29", "2026-06-29"))

        assertTrue(WeeklyInsightEngine.generate(history, emptyList(), today).isEmpty())
    }

    @Test
    fun `returns at most three conclusions in documented priority`() {
        val history = buildList {
            var id = 1L
            listOf("2026-06-08", "2026-06-10", "2026-06-12").forEach { add(entry(id++, it, null)) }
            listOf("2026-06-15", "2026-06-17", "2026-06-19").forEach { add(entry(id++, it, it)) }
            listOf("2026-06-22", "2026-06-24", "2026-06-26").forEach { add(entry(id++, it, it, budget = 15)) }
            listOf("2026-06-29", "2026-07-01", "2026-07-03").forEach { add(entry(id++, it, it, budget = 15)) }
        }
        val feedback = history.filter { it.completedEpochDay != null }.take(4).map {
            WorkoutFeedback(it.sessionId, 1, it.completedEpochDay!!, WorkoutDifficulty.HARD, 0)
        }

        val insights = WeeklyInsightEngine.generate(history, feedback, today)

        assertEquals(3, insights.size)
        assertTrue(insights[0] is WeeklyInsight.AdherenceTrend)
        assertTrue(insights[1] is WeeklyInsight.ReliableWeekday)
        assertTrue(insights[2] is WeeklyInsight.DifficultyTrend)
        assertTrue(insights.all { Regex("\\d").containsMatchIn(it.messageVi) })
    }

    @Test
    fun `evidence thresholds suppress weak claims`() {
        val history = listOf(
            entry(1, "2026-06-16", "2026-06-16", budget = 15),
            entry(2, "2026-06-23", "2026-06-23", budget = 15),
            entry(3, "2026-06-30", "2026-06-30", budget = 15),
        )
        val feedback = history.map {
            WorkoutFeedback(it.sessionId, 1, it.completedEpochDay!!, WorkoutDifficulty.HARD, 0)
        }

        val insights = WeeklyInsightEngine.generate(history, feedback, today)

        assertTrue(insights.none { it is WeeklyInsight.DifficultyTrend })
        assertTrue(insights.none { it is WeeklyInsight.TimeBudgetPattern })
    }

    private fun entry(
        id: Long,
        due: String,
        completed: String?,
        budget: Int? = null,
    ) = WorkoutHistoryEntry(
        sessionId = id,
        goalId = 1,
        sequenceIndex = id.toInt(),
        dueEpochDay = day(due),
        completedEpochDay = completed?.let(::day),
        estimatedMinutes = 30,
        selectedTimeBudgetMinutes = budget,
    )

    private fun day(value: String) = LocalDate.parse(value).toEpochDay()
}
