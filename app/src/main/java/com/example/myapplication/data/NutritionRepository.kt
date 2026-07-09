package com.example.myapplication.data

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import com.example.myapplication.core.nutrition.EntrySource
import com.example.myapplication.core.nutrition.Nutrients
import com.example.myapplication.core.nutrition.NutritionDay
import com.example.myapplication.core.nutrition.NutritionTarget
import com.example.myapplication.core.nutrition.NutritionTargetAudit
import com.example.myapplication.core.nutrition.MealTemplate
import com.example.myapplication.data.local.MealTemplateEntity
import com.example.myapplication.data.local.DailyNutritionEntity
import com.example.myapplication.data.local.PersonalizationDao
import com.example.myapplication.data.local.LoggedFoodEntity
import com.example.myapplication.data.local.FoodCatalogEntity
import com.example.myapplication.data.local.FoodCatalogDao
import com.example.myapplication.data.local.LoggedFoodDao
import java.io.IOException
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.emitAll
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

data class NutritionData(
    val caloriesEaten: Int = 0,
    val proteinEaten: Int = 0,
    val carbsEaten: Int = 0,
    val fatEaten: Int = 0,
    val fiberEaten: Int = 0,
    val sweatExerciseId: String? = null,
    val sweatExerciseName: String? = null,
    val sweatExtraSets: Int = 0,
    val sweatActive: Boolean = false,
    val aiCoachReview: String? = null,
)

data class LegacyNutritionSnapshot(
    val caloriesEaten: Int = 0,
    val proteinEaten: Int = 0,
    val carbsEaten: Int = 0,
    val fatEaten: Int = 0,
    val sweatExerciseId: String? = null,
    val sweatExerciseName: String? = null,
    val sweatExtraSets: Int = 0,
    val sweatActive: Boolean = false,
    val aiCoachReview: String? = null,
)

data class NutritionPreferenceState(
    val roomMigrated: Boolean = false,
    val sweatExerciseId: String? = null,
    val sweatExerciseName: String? = null,
    val sweatExtraSets: Int = 0,
    val sweatActive: Boolean = false,
    val aiCoachReview: String? = null,
)

interface LegacyNutritionPreferences {
    val state: Flow<NutritionPreferenceState>
    suspend fun snapshotForMigration(): LegacyNutritionSnapshot
    suspend fun markRoomMigrated()
    suspend fun setSweatPayment(exerciseId: String, exerciseName: String, extraSets: Int, active: Boolean)
    suspend fun clearSweatPayment()
    suspend fun updateAiCoachReview(review: String)
    suspend fun clearAiCoachReview()
}

interface NutritionRepository {
    val nutritionData: Flow<NutritionData>
    fun observeDay(epochDay: Long): Flow<NutritionDay>
    fun observeRange(startEpochDay: Long, endEpochDay: Long): Flow<List<NutritionDay>>
    fun observeAllNutrition(): Flow<List<NutritionDay>>
    fun observeMealTemplates(): Flow<List<MealTemplate>> = kotlinx.coroutines.flow.flowOf(emptyList())
    suspend fun saveMealTemplate(id: Long?, nameVi: String, nutrients: Nutrients): Long =
        throw UnsupportedOperationException("Meal templates are unavailable")
    suspend fun deleteMealTemplate(id: Long) = Unit
    suspend fun applyMealTemplate(id: Long, epochDay: Long) = Unit
    suspend fun addNutrients(epochDay: Long, nutrients: Nutrients, source: EntrySource)
    suspend fun addWater(epochDay: Long, waterMl: Int)
    suspend fun setTarget(epochDay: Long, target: NutritionTarget)
    suspend fun setSweatPayment(exerciseId: String, exerciseName: String, extraSets: Int, active: Boolean)
    suspend fun clearSweatPayment()
    suspend fun updateAiCoachReview(review: String)
    suspend fun resetDaily()

    fun observeLoggedFoods(epochDay: Long): Flow<List<LoggedFoodEntity>> = kotlinx.coroutines.flow.flowOf(emptyList())
    suspend fun loggedFoodsNow(epochDay: Long): List<LoggedFoodEntity> = emptyList()
    fun observeRecentFoods(limit: Int): Flow<List<FoodCatalogEntity>> = kotlinx.coroutines.flow.flowOf(emptyList())
    fun observeFavorites(): Flow<List<FoodCatalogEntity>> = kotlinx.coroutines.flow.flowOf(emptyList())
    fun searchFavorites(query: String): Flow<List<FoodCatalogEntity>> = kotlinx.coroutines.flow.flowOf(emptyList())
    suspend fun toggleFavorite(foodCatalogId: Long, isFavorite: Boolean) = Unit
    suspend fun logFood(epochDay: Long, name: String, mealTime: String, grams: Double, calories: Int, proteinGrams: Int, carbsGrams: Int, fatGrams: Int, fiberGrams: Int = 0, foodCatalogId: Long? = null) = Unit
    suspend fun deleteLoggedFood(id: Long) = Unit
    suspend fun copyYesterdayMeals(yesterdayEpochDay: Long, todayEpochDay: Long) = Unit
}

class RoomNutritionRepository(
    private val personalizationDao: PersonalizationDao,
    private val foodCatalogDao: FoodCatalogDao,
    private val loggedFoodDao: LoggedFoodDao,
    private val legacyPreferences: LegacyNutritionPreferences,
    private val todayEpochDay: () -> Long,
    private val nowEpochMillis: () -> Long = { System.currentTimeMillis() },
) : NutritionRepository {
    private val migrationMutex = Mutex()
    private var migrationChecked = false

    override val nutritionData: Flow<NutritionData> = flow {
        ensureLegacyMigration()
        val today = todayEpochDay()
        emitAll(
            combine(
                personalizationDao.observeNutritionDay(today),
                legacyPreferences.state,
            ) { entity, preferences ->
                val day = entity.toNutritionDay(today)
                NutritionData(
                    caloriesEaten = day.consumed.calories,
                    proteinEaten = day.consumed.proteinGrams,
                    carbsEaten = day.consumed.carbsGrams,
                    fatEaten = day.consumed.fatGrams,
                    fiberEaten = day.consumed.fiberGrams,
                    sweatExerciseId = preferences.sweatExerciseId,
                    sweatExerciseName = preferences.sweatExerciseName,
                    sweatExtraSets = preferences.sweatExtraSets,
                    sweatActive = preferences.sweatActive,
                    aiCoachReview = preferences.aiCoachReview,
                )
            },
        )
    }

    override fun observeDay(epochDay: Long): Flow<NutritionDay> = flow {
        ensureLegacyMigration()
        emitAll(personalizationDao.observeNutritionDay(epochDay).map { it.toNutritionDay(epochDay) })
    }

    override fun observeRange(startEpochDay: Long, endEpochDay: Long): Flow<List<NutritionDay>> = flow {
        ensureLegacyMigration()
        emitAll(
            personalizationDao.observeNutritionRange(startEpochDay, endEpochDay)
                .map { rows -> rows.map { it.toNutritionDay(it.epochDay) } },
        )
    }

    override fun observeAllNutrition(): Flow<List<NutritionDay>> = flow {
        ensureLegacyMigration()
        emitAll(
            personalizationDao.observeAllNutrition()
                .map { rows -> rows.map { it.toNutritionDay(it.epochDay) } }
        )
    }

    override fun observeMealTemplates(): Flow<List<MealTemplate>> =
        personalizationDao.observeMealTemplates().map { rows -> rows.map(MealTemplateEntity::toDomain) }

    override suspend fun saveMealTemplate(
        id: Long?,
        nameVi: String,
        nutrients: Nutrients,
    ): Long {
        val normalizedName = nameVi.trim()
        require(normalizedName.length in 1..60) { "Meal template name must contain 1..60 characters" }
        require(nutrients.calories > 0) { "Calories must be greater than zero" }
        require(
            nutrients.proteinGrams >= 0 && nutrients.carbsGrams >= 0 && nutrients.fatGrams >= 0,
        ) { "Nutrients must be non-negative" }
        val duplicate = personalizationDao.mealTemplateByNameNow(normalizedName)
        require(duplicate == null || duplicate.id == id) { "Meal template name already exists" }
        val entity = MealTemplateEntity(
            id = id ?: 0,
            nameVi = normalizedName,
            calories = nutrients.calories,
            proteinGrams = nutrients.proteinGrams,
            carbsGrams = nutrients.carbsGrams,
            fatGrams = nutrients.fatGrams,
            fiberGrams = nutrients.fiberGrams,
            updatedAtEpochMillis = nowEpochMillis(),
        )
        if (id == null) return personalizationDao.insertMealTemplate(entity)
        require(personalizationDao.updateMealTemplate(entity) == 1) { "Unknown meal template $id" }
        return id
    }

    override suspend fun deleteMealTemplate(id: Long) {
        personalizationDao.deleteMealTemplate(id)
    }

    override suspend fun applyMealTemplate(id: Long, epochDay: Long) {
        ensureLegacyMigration()
        personalizationDao.applyMealTemplateToDay(
            id = id,
            epochDay = epochDay,
            source = EntrySource.TEMPLATE.name,
            updatedAtEpochMillis = nowEpochMillis(),
        )
    }

    override suspend fun addNutrients(epochDay: Long, nutrients: Nutrients, source: EntrySource) {
        ensureLegacyMigration()
        val current = entityNow(epochDay)
        personalizationDao.upsertDailyNutrition(
            current.copy(
                consumedCalories = current.consumedCalories + nutrients.calories,
                consumedProteinGrams = current.consumedProteinGrams + nutrients.proteinGrams,
                consumedCarbsGrams = current.consumedCarbsGrams + nutrients.carbsGrams,
                consumedFatGrams = current.consumedFatGrams + nutrients.fatGrams,
                consumedFiberGrams = current.consumedFiberGrams + nutrients.fiberGrams,
                lastEntrySource = source.name,
                updatedAtEpochMillis = nowEpochMillis(),
            ),
        )
    }

    override suspend fun addWater(epochDay: Long, waterMl: Int) {
        ensureLegacyMigration()
        val current = entityNow(epochDay)
        personalizationDao.upsertDailyNutrition(
            current.copy(
                waterIntakeMl = (current.waterIntakeMl + waterMl).coerceAtLeast(0),
                updatedAtEpochMillis = nowEpochMillis(),
            ),
        )
    }

    override suspend fun setTarget(epochDay: Long, target: NutritionTarget) {
        ensureLegacyMigration()
        val current = entityNow(epochDay)
        personalizationDao.upsertDailyNutrition(
            current.copy(
                targetBasalCalories = target.basalCalories,
                targetMaintenanceCalories = target.maintenanceCalories,
                targetCalories = target.calories,
                targetProteinGrams = target.proteinGrams,
                targetCarbsGrams = target.carbsGrams,
                targetFatGrams = target.fatGrams,
                updatedAtEpochMillis = nowEpochMillis(),
            ),
        )
    }

    override suspend fun setSweatPayment(
        exerciseId: String,
        exerciseName: String,
        extraSets: Int,
        active: Boolean,
    ) = legacyPreferences.setSweatPayment(exerciseId, exerciseName, extraSets, active)

    override suspend fun clearSweatPayment() = legacyPreferences.clearSweatPayment()

    override suspend fun updateAiCoachReview(review: String) = legacyPreferences.updateAiCoachReview(review)

    override suspend fun resetDaily() {
        ensureLegacyMigration()
        val today = todayEpochDay()
        val current = entityNow(today)
        personalizationDao.upsertDailyNutrition(
            current.copy(
                consumedCalories = 0,
                consumedProteinGrams = 0,
                consumedCarbsGrams = 0,
                consumedFatGrams = 0,
                consumedFiberGrams = 0,
                lastEntrySource = null,
                updatedAtEpochMillis = nowEpochMillis(),
            ),
        )
        legacyPreferences.clearAiCoachReview()
    }

    private suspend fun ensureLegacyMigration() {
        if (migrationChecked) return
        migrationMutex.withLock {
            if (migrationChecked) return
            if (!legacyPreferences.state.first().roomMigrated) {
                val snapshot = legacyPreferences.snapshotForMigration()
                if (snapshot.hasNutritionTotals()) {
                    val today = todayEpochDay()
                    val current = entityNow(today)
                    personalizationDao.upsertDailyNutrition(
                        current.copy(
                            consumedCalories = current.consumedCalories + snapshot.caloriesEaten,
                            consumedProteinGrams = current.consumedProteinGrams + snapshot.proteinEaten,
                            consumedCarbsGrams = current.consumedCarbsGrams + snapshot.carbsEaten,
                            consumedFatGrams = current.consumedFatGrams + snapshot.fatEaten,
                            lastEntrySource = EntrySource.MANUAL.name,
                            updatedAtEpochMillis = nowEpochMillis(),
                        ),
                    )
                }
                legacyPreferences.markRoomMigrated()
            }
            migrationChecked = true
        }
    }

    private suspend fun entityNow(epochDay: Long): DailyNutritionEntity =
        personalizationDao.nutritionRangeNow(epochDay, epochDay).firstOrNull()
            ?: DailyNutritionEntity(epochDay = epochDay, updatedAtEpochMillis = nowEpochMillis())

    private fun LegacyNutritionSnapshot.hasNutritionTotals(): Boolean =
        caloriesEaten != 0 || proteinEaten != 0 || carbsEaten != 0 || fatEaten != 0

    override fun observeLoggedFoods(epochDay: Long): Flow<List<LoggedFoodEntity>> {
        return loggedFoodDao.observeDay(epochDay)
    }

    override suspend fun loggedFoodsNow(epochDay: Long): List<LoggedFoodEntity> {
        return loggedFoodDao.dayNow(epochDay)
    }

    override fun observeRecentFoods(limit: Int): Flow<List<FoodCatalogEntity>> {
        return loggedFoodDao.observeRecentFoods(limit).map { logged ->
            logged.distinctBy { it.name }.map {
                val gramsFactor = if (it.grams > 0) it.grams else 100.0
                val servingFactor = 100.0 / gramsFactor
                FoodCatalogEntity(
                    id = it.foodCatalogId ?: 0L,
                    name = it.name,
                    gramsPerServing = 100.0,
                    caloriesPerServing = it.calories * servingFactor,
                    proteinPerServing = it.proteinGrams * servingFactor,
                    carbsPerServing = it.carbsGrams * servingFactor,
                    fatPerServing = it.fatGrams * servingFactor,
                    fiberPerServing = it.fiberGrams * servingFactor,
                    isFavorite = false
                )
            }
        }
    }

    override fun observeFavorites(): Flow<List<FoodCatalogEntity>> {
        return foodCatalogDao.observeFavorites()
    }

    override fun searchFavorites(query: String): Flow<List<FoodCatalogEntity>> {
        return foodCatalogDao.searchFavorites(query)
    }

    override suspend fun toggleFavorite(foodCatalogId: Long, isFavorite: Boolean) {
        if (foodCatalogId > 0) {
            foodCatalogDao.toggleFavorite(foodCatalogId, isFavorite)
        }
    }

    override suspend fun logFood(
        epochDay: Long,
        name: String,
        mealTime: String,
        grams: Double,
        calories: Int,
        proteinGrams: Int,
        carbsGrams: Int,
        fatGrams: Int,
        fiberGrams: Int,
        foodCatalogId: Long?,
    ) {
        ensureLegacyMigration()
        val entity = LoggedFoodEntity(
            epochDay = epochDay,
            name = name,
            mealTime = mealTime,
            grams = grams,
            calories = calories,
            proteinGrams = proteinGrams,
            carbsGrams = carbsGrams,
            fatGrams = fatGrams,
            fiberGrams = fiberGrams,
            foodCatalogId = foodCatalogId,
            timestamp = nowEpochMillis()
        )
        loggedFoodDao.insert(entity)

        // Update daily total
        val current = entityNow(epochDay)
        personalizationDao.upsertDailyNutrition(
            current.copy(
                consumedCalories = current.consumedCalories + calories,
                consumedProteinGrams = current.consumedProteinGrams + proteinGrams,
                consumedCarbsGrams = current.consumedCarbsGrams + carbsGrams,
                consumedFatGrams = current.consumedFatGrams + fatGrams,
                consumedFiberGrams = current.consumedFiberGrams + fiberGrams,
                lastEntrySource = EntrySource.MANUAL.name,
                updatedAtEpochMillis = nowEpochMillis(),
            )
        )
    }

    override suspend fun deleteLoggedFood(id: Long) {
        ensureLegacyMigration()
        val food = loggedFoodDao.getById(id) ?: return
        loggedFoodDao.delete(id)

        // Subtract from daily total
        val current = entityNow(food.epochDay)
        personalizationDao.upsertDailyNutrition(
            current.copy(
                consumedCalories = (current.consumedCalories - food.calories).coerceAtLeast(0),
                consumedProteinGrams = (current.consumedProteinGrams - food.proteinGrams).coerceAtLeast(0),
                consumedCarbsGrams = (current.consumedCarbsGrams - food.carbsGrams).coerceAtLeast(0),
                consumedFatGrams = (current.consumedFatGrams - food.fatGrams).coerceAtLeast(0),
                consumedFiberGrams = (current.consumedFiberGrams - food.fiberGrams).coerceAtLeast(0),
                updatedAtEpochMillis = nowEpochMillis(),
            )
        )
    }

    override suspend fun copyYesterdayMeals(yesterdayEpochDay: Long, todayEpochDay: Long) {
        ensureLegacyMigration()
        val yesterdayFoods = loggedFoodDao.dayNow(yesterdayEpochDay)
        if (yesterdayFoods.isEmpty()) return

        val newFoods = yesterdayFoods.map {
            it.copy(
                id = 0,
                epochDay = todayEpochDay,
                timestamp = nowEpochMillis()
            )
        }
        loggedFoodDao.insertAll(newFoods)

        // Accumulate macros
        val totalCalories = newFoods.sumOf { it.calories }
        val totalProtein = newFoods.sumOf { it.proteinGrams }
        val totalCarbs = newFoods.sumOf { it.carbsGrams }
        val totalFat = newFoods.sumOf { it.fatGrams }
        val totalFiber = newFoods.sumOf { it.fiberGrams }

        val current = entityNow(todayEpochDay)
        personalizationDao.upsertDailyNutrition(
            current.copy(
                consumedCalories = current.consumedCalories + totalCalories,
                consumedProteinGrams = current.consumedProteinGrams + totalProtein,
                consumedCarbsGrams = current.consumedCarbsGrams + totalCarbs,
                consumedFatGrams = current.consumedFatGrams + totalFat,
                consumedFiberGrams = current.consumedFiberGrams + totalFiber,
                lastEntrySource = EntrySource.MANUAL.name,
                updatedAtEpochMillis = nowEpochMillis(),
            )
        )
    }
}

class DataStoreNutritionPreferences(context: Context) : LegacyNutritionPreferences {
    private val store = context.applicationContext.dataStore

    override val state: Flow<NutritionPreferenceState> = store.data
        .catch { error -> if (error is IOException) emit(emptyPreferences()) else throw error }
        .map(::preferencesToNutritionPreferenceState)

    override suspend fun snapshotForMigration(): LegacyNutritionSnapshot {
        val preferences = store.data
            .catch { error -> if (error is IOException) emit(emptyPreferences()) else throw error }
            .first()
        return LegacyNutritionSnapshot(
            caloriesEaten = preferences[CALORIES] ?: 0,
            proteinEaten = preferences[PROTEIN] ?: 0,
            carbsEaten = preferences[CARBS] ?: 0,
            fatEaten = preferences[FAT] ?: 0,
            sweatExerciseId = preferences[SWEAT_ID],
            sweatExerciseName = preferences[SWEAT_NAME],
            sweatExtraSets = preferences[SWEAT_SETS] ?: 0,
            sweatActive = preferences[SWEAT_ACTIVE] ?: false,
            aiCoachReview = preferences[AI_COACH_REVIEW],
        )
    }

    override suspend fun markRoomMigrated() {
        store.edit { preferences -> preferences[NUTRITION_ROOM_MIGRATED] = true }
    }

    override suspend fun setSweatPayment(
        exerciseId: String,
        exerciseName: String,
        extraSets: Int,
        active: Boolean,
    ) {
        store.edit { preferences ->
            preferences[SWEAT_ID] = exerciseId
            preferences[SWEAT_NAME] = exerciseName
            preferences[SWEAT_SETS] = extraSets
            preferences[SWEAT_ACTIVE] = active
        }
    }

    override suspend fun clearSweatPayment() {
        store.edit { preferences -> preferences[SWEAT_ACTIVE] = false }
    }

    override suspend fun updateAiCoachReview(review: String) {
        store.edit { preferences -> preferences[AI_COACH_REVIEW] = review }
    }

    override suspend fun clearAiCoachReview() {
        store.edit { preferences -> preferences[AI_COACH_REVIEW] = "" }
    }
}

private val CALORIES = intPreferencesKey("nutrition_calories")
private val PROTEIN = intPreferencesKey("nutrition_protein")
private val CARBS = intPreferencesKey("nutrition_carbs")
private val FAT = intPreferencesKey("nutrition_fat")
private val SWEAT_ID = stringPreferencesKey("sweat_exercise_id")
private val SWEAT_NAME = stringPreferencesKey("sweat_exercise_name")
private val SWEAT_SETS = intPreferencesKey("sweat_extra_sets")
private val SWEAT_ACTIVE = booleanPreferencesKey("sweat_active")
private val AI_COACH_REVIEW = stringPreferencesKey("ai_coach_review")
private val NUTRITION_ROOM_MIGRATED = booleanPreferencesKey("nutrition_room_migrated")

private fun preferencesToNutritionPreferenceState(preferences: Preferences) = NutritionPreferenceState(
    roomMigrated = preferences[NUTRITION_ROOM_MIGRATED] ?: false,
    sweatExerciseId = preferences[SWEAT_ID],
    sweatExerciseName = preferences[SWEAT_NAME],
    sweatExtraSets = preferences[SWEAT_SETS] ?: 0,
    sweatActive = preferences[SWEAT_ACTIVE] ?: false,
    aiCoachReview = preferences[AI_COACH_REVIEW],
)

private fun DailyNutritionEntity?.toNutritionDay(epochDay: Long): NutritionDay {
    if (this == null) {
        return NutritionDay(
            epochDay = epochDay,
            consumed = Nutrients(),
            target = null,
        )
    }
    return NutritionDay(
        epochDay = this.epochDay,
        consumed = Nutrients(
            calories = consumedCalories,
            proteinGrams = consumedProteinGrams,
            carbsGrams = consumedCarbsGrams,
            fatGrams = consumedFatGrams,
            fiberGrams = consumedFiberGrams,
        ),
        target = toNutritionTarget(),
        waterIntakeMl = waterIntakeMl,
    )
}

private fun DailyNutritionEntity.toNutritionTarget(): NutritionTarget? {
    val basal = targetBasalCalories ?: return null
    val maintenance = targetMaintenanceCalories ?: return null
    val calories = targetCalories ?: return null
    val protein = targetProteinGrams ?: return null
    val carbs = targetCarbsGrams ?: return null
    val fat = targetFatGrams ?: return null
    return NutritionTarget(
        basalCalories = basal,
        maintenanceCalories = maintenance,
        calories = calories,
        proteinGrams = protein,
        carbsGrams = carbs,
        fatGrams = fat,
        audit = NutritionTargetAudit(
            rawBasalCalories = basal.toDouble(),
            rawMaintenanceCalories = maintenance.toDouble(),
            rawTargetCalories = calories.toDouble(),
            rawProteinGrams = protein.toDouble(),
            rawCarbsGrams = carbs.toDouble(),
            rawFatGrams = fat.toDouble(),
        ),
    )
}

private fun MealTemplateEntity.toDomain() = MealTemplate(
    id = id,
    nameVi = nameVi,
    nutrients = Nutrients(calories, proteinGrams, carbsGrams, fatGrams, fiberGrams),
    updatedAtEpochMillis = updatedAtEpochMillis,
)
