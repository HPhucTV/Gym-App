package com.example.myapplication.data

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.example.myapplication.core.adaptation.AdaptationKind
import com.example.myapplication.core.adaptation.AdaptationMode
import com.example.myapplication.core.adaptation.AdaptationStatus
import com.example.myapplication.core.profile.ActivityLevel
import com.example.myapplication.core.profile.GoalPace
import com.example.myapplication.core.profile.MetabolicSex
import com.example.myapplication.data.local.AdaptationDecisionEntity
import com.example.myapplication.data.local.DailyNutritionEntity
import com.example.myapplication.data.local.GymDatabase
import com.example.myapplication.data.local.PersonalProfileEntity
import com.example.myapplication.data.local.PersonalizationDao
import com.example.myapplication.data.local.WeeklyCheckInEntity
import com.example.myapplication.data.local.WeightMeasurementEntity
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class PersonalizationDatabaseTest {
    private lateinit var database: GymDatabase
    private lateinit var dao: PersonalizationDao

    @Before
    fun setUp() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database = Room.inMemoryDatabaseBuilder(context, GymDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        dao = database.personalizationDao()
    }

    @After
    fun tearDown() {
        database.close()
    }

    @Test
    fun profile_measurements_and_decisions_are_persisted() = runTest {
        val profile = profileEntity()
        dao.upsertProfile(profile)
        dao.upsertWeight(WeightMeasurementEntity(epochDay = 20_636, weightKg = 78.0, recordedAtEpochMillis = 100))
        val decisionId = dao.insertDecision(decisionEntity())

        assertEquals(profile, dao.profileNow())
        assertEquals(78.0, dao.latestWeightNow()!!.weightKg, 0.001)
        assertEquals(1, dao.decisionHistoryNow().size)
        assertNotEquals(0L, decisionId)
    }

    @Test
    fun dated_rows_replace_only_the_same_day_or_week() = runTest {
        dao.upsertWeight(WeightMeasurementEntity(epochDay = 20_636, weightKg = 78.0, recordedAtEpochMillis = 100))
        dao.upsertWeight(WeightMeasurementEntity(epochDay = 20_636, weightKg = 77.5, recordedAtEpochMillis = 200))
        dao.upsertDailyNutrition(DailyNutritionEntity(epochDay = 20_636, consumedCalories = 500))
        dao.upsertDailyNutrition(DailyNutritionEntity(epochDay = 20_637, consumedCalories = 700))
        dao.upsertWeeklyCheckIn(checkInEntity(weekStartEpochDay = 20_630, energy = 2))
        dao.upsertWeeklyCheckIn(checkInEntity(weekStartEpochDay = 20_630, energy = 4))

        assertEquals(1, dao.weightHistoryNow().size)
        assertEquals(77.5, dao.latestWeightNow()!!.weightKg, 0.001)
        assertEquals(listOf(500, 700), dao.nutritionRangeNow(20_636, 20_637).map { it.consumedCalories })
        assertEquals(4, dao.latestCheckInNow()!!.energy)
    }

    private fun profileEntity() = PersonalProfileEntity(
        birthDateEpochDay = 9_300,
        metabolicSex = MetabolicSex.MALE,
        heightCm = 175.0,
        currentWeightKg = 78.0,
        targetWeightKg = 72.0,
        activityLevel = ActivityLevel.MODERATE,
        goalPace = GoalPace.GRADUAL,
        personalizationConsent = true,
        cloudAiConsent = false,
        updatedAtEpochMillis = 100,
    )

    private fun checkInEntity(weekStartEpochDay: Long, energy: Int) = WeeklyCheckInEntity(
        weekStartEpochDay = weekStartEpochDay,
        weightKg = 77.5,
        energy = energy,
        hunger = 3,
        recovery = 4,
        sleepQuality = 4,
        note = null,
        createdAtEpochMillis = 100,
    )

    private fun decisionEntity() = AdaptationDecisionEntity(
        kind = AdaptationKind.CALORIE_TARGET,
        mode = AdaptationMode.AUTO_APPLY,
        status = AdaptationStatus.APPLIED,
        reasonVi = "Điều chỉnh nhỏ theo check-in tuần.",
        payloadVersion = 1,
        inputsJson = "{\"version\":1}",
        beforeJson = "{\"version\":1,\"calories\":2200}",
        afterJson = "{\"version\":1,\"calories\":2100}",
        undoJson = "{\"version\":1,\"calories\":2200}",
        createdAtEpochMillis = 100,
        resolvedAtEpochMillis = 100,
    )
}
