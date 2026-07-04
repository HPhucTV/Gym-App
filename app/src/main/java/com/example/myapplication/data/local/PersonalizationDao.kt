package com.example.myapplication.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Upsert
import androidx.room.Update
import androidx.room.Transaction
import com.example.myapplication.core.adaptation.AdaptationKind
import com.example.myapplication.core.adaptation.AdaptationStatus
import kotlinx.coroutines.flow.Flow

@Dao
interface PersonalizationDao {
    @Upsert
    suspend fun upsertProfile(profile: PersonalProfileEntity)

    @Query("SELECT * FROM personal_profiles WHERE id = 1 LIMIT 1")
    fun observeProfile(): Flow<PersonalProfileEntity?>

    @Query("SELECT * FROM personal_profiles WHERE id = 1 LIMIT 1")
    suspend fun profileNow(): PersonalProfileEntity?

    @Upsert
    suspend fun upsertWeight(measurement: WeightMeasurementEntity)

    @Query("SELECT * FROM weight_measurements ORDER BY epochDay DESC LIMIT 1")
    suspend fun latestWeightNow(): WeightMeasurementEntity?

    @Query("SELECT * FROM weight_measurements ORDER BY epochDay ASC")
    fun observeWeightHistory(): Flow<List<WeightMeasurementEntity>>

    @Query("SELECT * FROM weight_measurements ORDER BY epochDay ASC")
    suspend fun weightHistoryNow(): List<WeightMeasurementEntity>

    @Upsert
    suspend fun upsertDailyNutrition(day: DailyNutritionEntity)

    @Query("SELECT * FROM daily_nutrition WHERE epochDay = :epochDay LIMIT 1")
    fun observeNutritionDay(epochDay: Long): Flow<DailyNutritionEntity?>

    @Query("SELECT * FROM daily_nutrition WHERE epochDay BETWEEN :startEpochDay AND :endEpochDay ORDER BY epochDay ASC")
    fun observeNutritionRange(startEpochDay: Long, endEpochDay: Long): Flow<List<DailyNutritionEntity>>

    @Query("SELECT * FROM daily_nutrition WHERE epochDay BETWEEN :startEpochDay AND :endEpochDay ORDER BY epochDay ASC")
    suspend fun nutritionRangeNow(startEpochDay: Long, endEpochDay: Long): List<DailyNutritionEntity>

    @Query("SELECT * FROM daily_nutrition ORDER BY epochDay DESC")
    fun observeAllNutrition(): Flow<List<DailyNutritionEntity>>

    @Query("SELECT * FROM meal_templates ORDER BY nameVi COLLATE NOCASE ASC, id ASC")
    fun observeMealTemplates(): Flow<List<MealTemplateEntity>>

    @Query("SELECT * FROM meal_templates WHERE id = :id LIMIT 1")
    suspend fun mealTemplateNow(id: Long): MealTemplateEntity?

    @Query("SELECT * FROM meal_templates WHERE nameVi = :nameVi COLLATE NOCASE LIMIT 1")
    suspend fun mealTemplateByNameNow(nameVi: String): MealTemplateEntity?

    @Insert
    suspend fun insertMealTemplate(template: MealTemplateEntity): Long

    @Update
    suspend fun updateMealTemplate(template: MealTemplateEntity): Int

    @Query("DELETE FROM meal_templates WHERE id = :id")
    suspend fun deleteMealTemplate(id: Long): Int

    @Transaction
    suspend fun applyMealTemplateToDay(
        id: Long,
        epochDay: Long,
        source: String,
        updatedAtEpochMillis: Long,
    ) {
        val template = mealTemplateNow(id) ?: throw IllegalArgumentException("Unknown meal template $id")
        val current = nutritionRangeNow(epochDay, epochDay).firstOrNull()
            ?: DailyNutritionEntity(epochDay = epochDay, updatedAtEpochMillis = updatedAtEpochMillis)
        upsertDailyNutrition(
            current.copy(
                consumedCalories = current.consumedCalories + template.calories,
                consumedProteinGrams = current.consumedProteinGrams + template.proteinGrams,
                consumedCarbsGrams = current.consumedCarbsGrams + template.carbsGrams,
                consumedFatGrams = current.consumedFatGrams + template.fatGrams,
                lastEntrySource = source,
                updatedAtEpochMillis = updatedAtEpochMillis,
            ),
        )
    }

    @Upsert
    suspend fun upsertWeeklyCheckIn(checkIn: WeeklyCheckInEntity)

    @Query("SELECT * FROM weekly_check_ins ORDER BY weekStartEpochDay DESC LIMIT 1")
    fun observeLatestCheckIn(): Flow<WeeklyCheckInEntity?>

    @Query("SELECT * FROM weekly_check_ins ORDER BY weekStartEpochDay DESC")
    fun observeAllCheckIns(): Flow<List<WeeklyCheckInEntity>>

    @Query("SELECT * FROM weekly_check_ins ORDER BY weekStartEpochDay DESC LIMIT 1")
    suspend fun latestCheckInNow(): WeeklyCheckInEntity?

    @Insert
    suspend fun insertDecision(decision: AdaptationDecisionEntity): Long

    @Query("UPDATE adaptation_decisions SET status = :status, resolvedAtEpochMillis = :resolvedAt WHERE id = :id")
    suspend fun updateDecisionStatus(id: Long, status: AdaptationStatus, resolvedAt: Long)

    @Query("UPDATE adaptation_decisions SET afterJson = :afterJson, undoJson = :undoJson WHERE id = :id")
    suspend fun updateDecisionPayloads(id: Long, afterJson: String, undoJson: String)

    @Query("SELECT * FROM adaptation_decisions WHERE id = :id LIMIT 1")
    suspend fun decisionByIdNow(id: Long): AdaptationDecisionEntity?

    @Query("SELECT * FROM adaptation_decisions WHERE kind = :kind AND status = :status ORDER BY createdAtEpochMillis DESC, id DESC LIMIT 1")
    suspend fun latestDecisionByKindAndStatus(kind: AdaptationKind, status: AdaptationStatus): AdaptationDecisionEntity?

    @Query("SELECT * FROM adaptation_decisions ORDER BY createdAtEpochMillis DESC, id DESC")
    fun observeDecisionHistory(): Flow<List<AdaptationDecisionEntity>>

    @Query("SELECT * FROM adaptation_decisions ORDER BY createdAtEpochMillis DESC, id DESC")
    suspend fun decisionHistoryNow(): List<AdaptationDecisionEntity>
}
