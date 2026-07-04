package com.example.myapplication.core.progress

import com.example.myapplication.core.feedback.WorkoutDifficulty
import com.example.myapplication.core.feedback.WorkoutFeedback
import com.example.myapplication.core.model.WorkoutHistoryEntry
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.temporal.TemporalAdjusters
import kotlin.math.abs
import kotlin.math.roundToInt

sealed interface WeeklyInsight {
    val messageVi: String

    data class AdherenceTrend(override val messageVi: String) : WeeklyInsight
    data class ReliableWeekday(override val messageVi: String) : WeeklyInsight
    data class DifficultyTrend(override val messageVi: String) : WeeklyInsight
    data class TimeBudgetPattern(override val messageVi: String) : WeeklyInsight
    data class ScheduleDrift(override val messageVi: String) : WeeklyInsight
}

object WeeklyInsightEngine {
    fun generate(
        history: List<WorkoutHistoryEntry>,
        feedback: List<WorkoutFeedback>,
        todayEpochDay: Long,
    ): List<WeeklyInsight> {
        val currentMonday = LocalDate.ofEpochDay(todayEpochDay)
            .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
            .toEpochDay()
        val windowStart = currentMonday - 28
        val evidence = history.filter { it.dueEpochDay in windowStart until currentMonday }
        val byWeek = evidence.groupBy { weekStart(it.dueEpochDay) }.toSortedMap()
        if (byWeek.size < 2) return emptyList()

        return buildList {
            adherenceInsight(byWeek)?.let(::add)
            reliableWeekdayInsight(evidence)?.let(::add)
            difficultyInsight(evidence, feedback)?.let(::add)
            timeBudgetInsight(evidence)?.let(::add)
            scheduleDriftInsight(evidence)?.let(::add)
        }.take(3)
    }

    private fun adherenceInsight(
        byWeek: Map<Long, List<WorkoutHistoryEntry>>,
    ): WeeklyInsight.AdherenceTrend? {
        val rates = byWeek.values.map { week ->
            week.count { it.completedEpochDay != null } * 100.0 / week.size
        }
        val split = rates.size / 2
        if (split == 0) return null
        val older = rates.take(split).average()
        val newer = rates.drop(split).average()
        val difference = (newer - older).roundToInt()
        if (abs(difference) < 15) return null
        val direction = if (difference > 0) "tăng" else "giảm"
        return WeeklyInsight.AdherenceTrend(
            "Tỷ lệ bám lịch $direction ${abs(difference)} điểm phần trăm qua ${rates.size} tuần đầy đủ.",
        )
    }

    private fun reliableWeekdayInsight(
        evidence: List<WorkoutHistoryEntry>,
    ): WeeklyInsight.ReliableWeekday? {
        val candidate = evidence.groupBy { LocalDate.ofEpochDay(it.dueEpochDay).dayOfWeek }
            .filterValues { it.size >= 3 }
            .entries
            .sortedWith(
                compareByDescending<Map.Entry<DayOfWeek, List<WorkoutHistoryEntry>>> {
                    it.value.count { row -> row.completedEpochDay != null }.toDouble() / it.value.size
                }.thenBy { it.key.value },
            )
            .firstOrNull() ?: return null
        val completed = candidate.value.count { it.completedEpochDay != null }
        return WeeklyInsight.ReliableWeekday(
            "${weekdayVi(candidate.key)} ổn định nhất: hoàn thành $completed/${candidate.value.size} buổi đã xếp.",
        )
    }

    private fun difficultyInsight(
        evidence: List<WorkoutHistoryEntry>,
        feedback: List<WorkoutFeedback>,
    ): WeeklyInsight.DifficultyTrend? {
        val sessionIds = evidence.mapTo(mutableSetOf()) { it.sessionId }
        val relevant = feedback.filter { it.sessionId in sessionIds }
        if (relevant.size < 4) return null
        val hard = relevant.count { it.difficulty == WorkoutDifficulty.HARD }
        val easy = relevant.count { it.difficulty == WorkoutDifficulty.EASY }
        val message = when {
            hard * 2 >= relevant.size -> "$hard/${relevant.size} buổi được đánh giá quá nặng; nên ưu tiên hồi phục."
            easy * 2 >= relevant.size -> "$easy/${relevant.size} buổi được đánh giá quá nhẹ; chương trình có thể cần tăng dần."
            else -> "${relevant.size} phản hồi cho thấy độ khó nhìn chung vừa sức."
        }
        return WeeklyInsight.DifficultyTrend(message)
    }

    private fun timeBudgetInsight(
        evidence: List<WorkoutHistoryEntry>,
    ): WeeklyInsight.TimeBudgetPattern? {
        val shortened = evidence.filter { it.selectedTimeBudgetMinutes != null }
        if (shortened.size < 4) return null
        val common = shortened.groupingBy { it.selectedTimeBudgetMinutes!! }.eachCount()
            .entries.sortedWith(compareByDescending<Map.Entry<Int, Int>> { it.value }.thenBy { it.key }).first()
        return WeeklyInsight.TimeBudgetPattern(
            "Bạn đã chọn bản ${common.key} phút trong ${shortened.size} buổi gần đây.",
        )
    }

    private fun scheduleDriftInsight(
        evidence: List<WorkoutHistoryEntry>,
    ): WeeklyInsight.ScheduleDrift? {
        val completed = evidence.filter { it.completedEpochDay != null }
        if (completed.size < 3) return null
        val shifted = completed.filter { it.completedEpochDay != it.dueEpochDay }
        if (shifted.isEmpty()) return null
        return WeeklyInsight.ScheduleDrift(
            "${shifted.size}/${completed.size} buổi hoàn thành khác ngày dự kiến.",
        )
    }

    private fun weekStart(epochDay: Long): Long = LocalDate.ofEpochDay(epochDay)
        .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)).toEpochDay()

    private fun weekdayVi(day: DayOfWeek): String = when (day) {
        DayOfWeek.MONDAY -> "Thứ Hai"
        DayOfWeek.TUESDAY -> "Thứ Ba"
        DayOfWeek.WEDNESDAY -> "Thứ Tư"
        DayOfWeek.THURSDAY -> "Thứ Năm"
        DayOfWeek.FRIDAY -> "Thứ Sáu"
        DayOfWeek.SATURDAY -> "Thứ Bảy"
        DayOfWeek.SUNDAY -> "Chủ Nhật"
    }
}
