package com.example.myapplication.core.program

import java.time.DayOfWeek
import java.time.LocalDate

data class ReschedulableSession(
    val sessionId: Long,
    val sequenceIndex: Int,
    val dueEpochDay: Long,
    val completedEpochDay: Long?,
    val demanding: Boolean,
)

data class ScheduleChangePreview(
    val changes: List<SessionDateChange>,
    val warningsVi: List<String>,
)

data class SessionDateChange(
    val sessionId: Long,
    val oldEpochDay: Long,
    val newEpochDay: Long,
)

object ScheduleRescheduler {
    fun preview(
        sessions: List<ReschedulableSession>,
        selectedSessionId: Long,
        newEpochDay: Long,
        todayEpochDay: Long,
        trainingDays: Set<DayOfWeek>,
    ): ScheduleChangePreview {
        require(newEpochDay >= todayEpochDay) { "New workout date cannot be in the past" }
        require(trainingDays.isNotEmpty()) { "At least one training weekday is required" }
        val selected = sessions.firstOrNull { it.sessionId == selectedSessionId }
            ?: throw IllegalArgumentException("Unknown session $selectedSessionId")
        require(selected.completedEpochDay == null) { "Completed sessions cannot be rescheduled" }

        val pending = sessions.filter {
            it.completedEpochDay == null && it.sequenceIndex >= selected.sequenceIndex
        }.sortedBy { it.sequenceIndex }
        if (pending.size > 1) Math.addExact(newEpochDay, 1L)

        val newDates = buildList {
            add(newEpochDay)
            var cursor = newEpochDay
            repeat(pending.size - 1) {
                cursor = nextTrainingEpochDay(cursor, trainingDays)
                add(cursor)
            }
        }
        val warnings = buildList {
            if (LocalDate.ofEpochDay(newEpochDay).dayOfWeek !in trainingDays) {
                add("Ngày đã chọn không phải ngày tập thường lệ.")
            }
            pending.zip(newDates).zipWithNext().forEach { (left, right) ->
                val (leftSession, leftDate) = left
                val (rightSession, rightDate) = right
                if (leftSession.demanding && rightSession.demanding && rightDate - leftDate == 1L) {
                    add("Hai buổi tập nặng được xếp liên tiếp; hãy cân nhắc thời gian hồi phục.")
                }
            }
        }
        return ScheduleChangePreview(
            changes = pending.zip(newDates).map { (session, date) ->
                SessionDateChange(session.sessionId, session.dueEpochDay, date)
            },
            warningsVi = warnings.distinct(),
        )
    }

    private fun nextTrainingEpochDay(
        afterEpochDay: Long,
        trainingDays: Set<DayOfWeek>,
    ): Long {
        var candidate = Math.addExact(afterEpochDay, 1L)
        repeat(7) {
            if (LocalDate.ofEpochDay(candidate).dayOfWeek in trainingDays) return candidate
            candidate = Math.addExact(candidate, 1L)
        }
        error("No selected training day found")
    }
}
