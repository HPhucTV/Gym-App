package com.example.myapplication.core.today

import org.junit.Assert.assertEquals
import org.junit.Test

class TodayResolverTest {
    @Test
    fun inactiveGoalReturnsNoGoal() {
        assertEquals(TodayResult.NoGoal, TodayResolver.resolve(false, emptyList(), 100L))
    }

    @Test
    fun activeGoalWithEveryWorkoutCompletedReturnsGoalComplete() {
        val sessions = listOf(ScheduledWorkout("done", 0, 90L, completed = true))

        assertEquals(TodayResult.GoalComplete, TodayResolver.resolve(true, sessions, 100L))
    }

    @Test
    fun earliestIncompleteWorkoutBySequenceWinsEvenWhenInputIsUnorderedAndOverdue() {
        val earliest = ScheduledWorkout("first", 1, 90L, completed = false)
        val sessions = listOf(
            ScheduledWorkout("later", 2, 95L, completed = false),
            ScheduledWorkout("completed", 0, 80L, completed = true),
            earliest,
        )

        assertEquals(TodayResult.Workout(earliest), TodayResolver.resolve(true, sessions, 100L))
    }

    @Test
    fun futureEarliestWorkoutReturnsRecoveryWithNextDueDate() {
        val next = ScheduledWorkout("next", 0, 105L, completed = false)

        assertEquals(TodayResult.Recovery(105L), TodayResolver.resolve(true, listOf(next), 100L))
    }
}
