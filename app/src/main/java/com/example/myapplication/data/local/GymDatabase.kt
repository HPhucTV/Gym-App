package com.example.myapplication.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverter
import androidx.room.TypeConverters
import com.example.myapplication.core.model.EquipmentProfile
import com.example.myapplication.core.model.ExperienceLevel
import com.example.myapplication.core.model.FitnessGoal
import com.example.myapplication.core.model.RestDayMode

class WorkoutTypeConverters {
    @TypeConverter fun fitnessGoalToString(value: FitnessGoal): String = value.name
    @TypeConverter fun stringToFitnessGoal(value: String): FitnessGoal = FitnessGoal.valueOf(value)
    @TypeConverter fun experienceLevelToString(value: ExperienceLevel): String = value.name
    @TypeConverter fun stringToExperienceLevel(value: String): ExperienceLevel = ExperienceLevel.valueOf(value)
    @TypeConverter fun equipmentProfileToString(value: EquipmentProfile): String = value.name
    @TypeConverter fun stringToEquipmentProfile(value: String): EquipmentProfile = EquipmentProfile.valueOf(value)
    @TypeConverter fun restDayModeToString(value: RestDayMode): String = value.name
    @TypeConverter fun stringToRestDayMode(value: String): RestDayMode = RestDayMode.valueOf(value)
}

@Database(
    entities = [GoalEntity::class, WorkoutSessionEntity::class, SessionExerciseEntity::class],
    version = 1,
    exportSchema = true,
)
@TypeConverters(WorkoutTypeConverters::class)
abstract class GymDatabase : RoomDatabase() {
    abstract fun workoutDao(): WorkoutDao
}
