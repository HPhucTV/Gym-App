package com.example.myapplication.core.program

import org.junit.Assert.assertThrows
import org.junit.Test

class SchedulePlannerOverflowTest {
    @Test
    fun dueDateOverflowIsRejectedInsteadOfWrapping() {
        assertThrows(ArithmeticException::class.java) {
            SchedulePlanner.dueEpochDays(Long.MAX_VALUE, listOf(0, 0))
        }
    }

    @Test
    fun latenessOverflowIsRejectedInsteadOfWrapping() {
        assertThrows(ArithmeticException::class.java) {
            SchedulePlanner.carryForwardAfterCompletion(
                dueEpochDays = listOf(Long.MIN_VALUE, 0L),
                completedIndex = 0,
                completionEpochDay = Long.MAX_VALUE,
            )
        }
    }

    @Test
    fun shiftedDueDateOverflowIsRejectedInsteadOfWrapping() {
        assertThrows(ArithmeticException::class.java) {
            SchedulePlanner.carryForwardAfterCompletion(
                dueEpochDays = listOf(0L, Long.MAX_VALUE),
                completedIndex = 0,
                completionEpochDay = 1L,
            )
        }
    }
}
