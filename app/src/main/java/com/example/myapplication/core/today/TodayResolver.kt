package com.example.myapplication.core.today

data class ScheduledWorkout(
    val id: String,
    val sequence: Int,
    val dueEpochDay: Long,
    val completed: Boolean,
)

sealed interface TodayResult {
    data object NoGoal : TodayResult
    data object GoalComplete : TodayResult
    data class Workout(val workout: ScheduledWorkout) : TodayResult
    data class Recovery(val nextDueEpochDay: Long) : TodayResult
}

object TodayResolver {
    fun resolve(
        hasActiveGoal: Boolean,
        workouts: List<ScheduledWorkout>,
        todayEpochDay: Long,
    ): TodayResult {
        if (!hasActiveGoal) return TodayResult.NoGoal

        val nextWorkout = workouts
            .asSequence()
            .filterNot(ScheduledWorkout::completed)
            .minWithOrNull(compareBy(ScheduledWorkout::sequence, ScheduledWorkout::dueEpochDay, ScheduledWorkout::id))
            ?: return TodayResult.GoalComplete

        return if (nextWorkout.dueEpochDay <= todayEpochDay) {
            TodayResult.Workout(nextWorkout)
        } else {
            TodayResult.Recovery(nextWorkout.dueEpochDay)
        }
    }
}
