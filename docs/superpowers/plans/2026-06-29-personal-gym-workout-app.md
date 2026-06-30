# Personal Gym Workout App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an offline Android app that selects a reviewed 4-8 week workout program from a local catalog, presents the current workout, records exercise ticks and session completion, carries missed workouts forward, and shows calendar, goal, and streak progress.

**Architecture:** Keep one Android application module and use feature-oriented packages. Bundled JSON provides the curated exercise catalog and deterministic program templates; Room stores goals, instantiated sessions, checks, and history; DataStore stores small settings. Screen-level ViewModels expose immutable state, while selection, scheduling, completion, and progress rules remain pure or repository-backed and independently testable.

**Tech Stack:** Kotlin 2.2.10, Jetpack Compose/Material 3, Navigation Compose 2.9.8, Lifecycle 2.10.0, Room 2.8.4 with KSP 2.3.9, DataStore 1.2.1, kotlinx.serialization JSON 1.9.0, JUnit 4, Compose UI tests.

**Primary references:** [approved design](../specs/2026-06-29-personal-gym-workout-app-design.md), [project rules](../../../AGENTS.md), [Room setup](https://developer.android.com/training/data-storage/room), [DataStore guidance](https://developer.android.com/topic/libraries/architecture/datastore), [Navigation releases](https://developer.android.com/jetpack/androidx/releases/navigation), [Free Exercise DB](https://github.com/yuhonas/free-exercise-db).

---

## File map

### Build and application entry

- Modify `settings.gradle.kts` — rename the Gradle project to Gym App.
- Modify `build.gradle.kts` — expose KSP and Kotlin serialization plugins.
- Modify `gradle/libs.versions.toml` — pin persistence, navigation, serialization, lifecycle, and test dependencies.
- Modify `app/build.gradle.kts` — apply plugins, enable Java time desugaring, add dependencies, and export Room schemas.
- Modify `app/src/main/AndroidManifest.xml` — register the application and local reminder components.
- Modify `app/src/main/res/values/strings.xml` — Vietnamese UI and notification strings.
- Create `app/src/main/java/com/example/myapplication/GymApplication.kt` — process-level dependency container owner.
- Create `app/src/main/java/com/example/myapplication/app/AppContainer.kt` — manual dependency wiring.
- Create `app/src/main/java/com/example/myapplication/app/GymApp.kt` — root Compose state and navigation.
- Create `app/src/main/java/com/example/myapplication/app/AppDestination.kt` — route constants and bottom navigation metadata.
- Modify `app/src/main/java/com/example/myapplication/MainActivity.kt` — render `GymApp` only.

### Domain, catalog, and scheduling

- Create `app/src/main/java/com/example/myapplication/core/model/GoalModels.kt` — goal, level, equipment profile, and rest-mode types.
- Create `app/src/main/java/com/example/myapplication/core/model/CatalogModels.kt` — exercise and program JSON contracts.
- Create `app/src/main/java/com/example/myapplication/core/catalog/CatalogParser.kt` — strict JSON decoding.
- Create `app/src/main/java/com/example/myapplication/core/catalog/CatalogValidator.kt` — structural and cross-reference validation.
- Create `app/src/main/java/com/example/myapplication/core/catalog/AssetCatalogRepository.kt` — load validated bundled assets once.
- Create `app/src/main/java/com/example/myapplication/core/program/ProgramSelector.kt` — exact deterministic program matching.
- Create `app/src/main/java/com/example/myapplication/core/program/SchedulePlanner.kt` — instantiate due dates from reviewed session spacing.
- Create `app/src/main/java/com/example/myapplication/core/progress/ProgressCalculator.kt` — counts, percentage, month marks, and weekly streaks.
- Create `app/src/main/java/com/example/myapplication/core/today/TodayResolver.kt` — choose workout, recovery, completed, or no-goal state.

### Bundled content

- Create `app/src/main/assets/catalog/exercises_vi.json` — 60-100 reviewed Vietnamese exercise records.
- Create `app/src/main/assets/catalog/programs.json` — six explicit reviewed program templates.
- Create `docs/data/free-exercise-db-provenance.md` — source, license, retrieval date, curation rules, and ID mapping policy.
- Create `docs/data/program-review-checklist.md` — human review evidence for each program.

### Persistence

- Create `app/src/main/java/com/example/myapplication/data/local/GoalEntity.kt` — active and archived goals.
- Create `app/src/main/java/com/example/myapplication/data/local/WorkoutSessionEntity.kt` — instantiated ordered workouts and completion date.
- Create `app/src/main/java/com/example/myapplication/data/local/SessionExerciseEntity.kt` — prescription snapshot and checked state.
- Create `app/src/main/java/com/example/myapplication/data/local/WorkoutDao.kt` — goal/session/check/history queries.
- Create `app/src/main/java/com/example/myapplication/data/local/GymDatabase.kt` — Room database and type converters.
- Create `app/src/main/java/com/example/myapplication/data/WorkoutRepository.kt` — feature-facing persistence contract.
- Create `app/src/main/java/com/example/myapplication/data/RoomWorkoutRepository.kt` — transactional goal creation and completion.
- Create `app/src/main/java/com/example/myapplication/data/SettingsRepository.kt` — DataStore reminder and recovery preferences.

### Features

- Create `feature/onboarding/OnboardingUiState.kt`, `OnboardingViewModel.kt`, `OnboardingScreen.kt` — supported goal setup flow.
- Create `feature/today/TodayUiState.kt`, `TodayViewModel.kt`, `TodayScreen.kt`, `ExerciseCard.kt` — daily task and completion.
- Create `feature/progress/ProgressUiState.kt`, `ProgressViewModel.kt`, `ProgressScreen.kt`, `MonthCalendar.kt` — goal and history views.
- Create `feature/settings/SettingsUiState.kt`, `SettingsViewModel.kt`, `SettingsScreen.kt` — preferences and confirmed goal replacement.
- Create `notification/ReminderScheduler.kt`, `AlarmReminderScheduler.kt`, `WorkoutReminderReceiver.kt`, `BootReceiver.kt` — local daily reminders.

### Theme and tests

- Replace the starter color/theme/type files under `ui/theme` with the approved white, navy, green, orange, and gray system.
- Add pure unit tests under `app/src/test/java/com/example/myapplication` for selection, scheduling, progress, Today resolution, and ViewModels.
- Add asset, Room, and Compose flow tests under `app/src/androidTest/java/com/example/myapplication`.

---

### Task 1: Establish source control and the Android dependency baseline

**Files:**
- Modify: `.gitignore`
- Modify: `settings.gradle.kts`
- Modify: `build.gradle.kts`
- Modify: `gradle/libs.versions.toml`
- Modify: `app/build.gradle.kts`
- Modify: `app/src/main/res/values/strings.xml`
- Modify: `AGENTS.md`

- [ ] **Step 1: Verify the untouched starter project**

Run:

```powershell
.\gradlew.bat testDebugUnitTest
.\gradlew.bat assembleDebug
```

Expected: both commands end with `BUILD SUCCESSFUL`. If they do not, record the baseline failure before changing dependencies.

- [ ] **Step 2: Initialize Git and preserve machine-local files**

Run:

```powershell
git init
git branch -M main
```

Ensure `.gitignore` contains these exact additional entries:

```gitignore
/app/build/
/.kotlin/
```

Do not add `local.properties`.

- [ ] **Step 3: Add pinned versions and aliases**

Add these entries to `gradle/libs.versions.toml` without replacing existing Compose BOM aliases:

```toml
[versions]
coreKtx = "1.18.0" # Latest stable Core line compatible with compile SDK 36.1.
activityCompose = "1.12.4" # Latest stable Activity 1.12 patch; Activity 1.12 compiles with API 36.
lifecycleRuntimeKtx = "2.10.0" # Lifecycle 2.11 Compose artifacts require compile SDK 37.
ksp = "2.3.9"
room = "2.8.4"
navigation = "2.9.8"
datastore = "1.2.1"
serializationJson = "1.9.0"
coroutines = "1.10.2"
desugarJdkLibs = "2.1.5"

[libraries]
androidx-lifecycle-runtime-compose = { group = "androidx.lifecycle", name = "lifecycle-runtime-compose", version.ref = "lifecycleRuntimeKtx" }
androidx-lifecycle-viewmodel-compose = { group = "androidx.lifecycle", name = "lifecycle-viewmodel-compose", version.ref = "lifecycleRuntimeKtx" }
androidx-navigation-compose = { group = "androidx.navigation", name = "navigation-compose", version.ref = "navigation" }
androidx-room-runtime = { group = "androidx.room", name = "room-runtime", version.ref = "room" }
androidx-room-ktx = { group = "androidx.room", name = "room-ktx", version.ref = "room" }
androidx-room-compiler = { group = "androidx.room", name = "room-compiler", version.ref = "room" }
androidx-room-testing = { group = "androidx.room", name = "room-testing", version.ref = "room" }
androidx-datastore-preferences = { group = "androidx.datastore", name = "datastore-preferences", version.ref = "datastore" }
kotlinx-serialization-json = { group = "org.jetbrains.kotlinx", name = "kotlinx-serialization-json", version.ref = "serializationJson" }
kotlinx-coroutines-test = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-test", version.ref = "coroutines" }
desugar-jdk-libs = { group = "com.android.tools", name = "desugar_jdk_libs", version.ref = "desugarJdkLibs" }

[plugins]
ksp = { id = "com.google.devtools.ksp", version.ref = "ksp" }
kotlin-serialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
```

- [ ] **Step 4: Apply plugins and dependencies**

Add both plugin aliases with `apply false` in root `build.gradle.kts`. Apply both in `app/build.gradle.kts`, enable core library desugaring, configure Room schema output, and add these dependencies:

```kotlin
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.ksp)
}

android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

ksp {
    arg("room.schemaLocation", "$projectDir/schemas")
}

dependencies {
    coreLibraryDesugaring(libs.desugar.jdk.libs)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.androidx.room.runtime)
    implementation(libs.androidx.room.ktx)
    ksp(libs.androidx.room.compiler)
    implementation(libs.androidx.datastore.preferences)
    implementation(libs.kotlinx.serialization.json)
    testImplementation(libs.kotlinx.coroutines.test)
    androidTestImplementation(libs.androidx.room.testing)
}
```

- [ ] **Step 5: Rename the starter and correct the data rule wording**

Set `rootProject.name = "Gym App"`, set `<string name="app_name">Gym App</string>`, and update the workout rule in `AGENTS.md` to distinguish catalog metadata from prescriptions:

```markdown
- Every catalog exercise must have a stable ID, equipment, difficulty, movement pattern, primary muscle group, and instructions.
- Every exercise reference inside a program session must add sets, repetitions or duration, and rest time.
```

- [ ] **Step 6: Verify dependency resolution and commit**

Run:

```powershell
.\gradlew.bat testDebugUnitTest
.\gradlew.bat assembleDebug
git add .gitignore AGENTS.md settings.gradle.kts build.gradle.kts gradle/libs.versions.toml app/build.gradle.kts app/src/main/res/values/strings.xml docs
git commit -m "chore: establish gym app project baseline"
```

Expected: both Gradle commands pass and the first commit is created without `local.properties`.

---

### Task 2: Define catalog contracts and exact program selection

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/model/GoalModels.kt`
- Create: `app/src/main/java/com/example/myapplication/core/model/CatalogModels.kt`
- Create: `app/src/main/java/com/example/myapplication/core/program/ProgramSelector.kt`
- Test: `app/src/test/java/com/example/myapplication/core/program/ProgramSelectorTest.kt`

- [ ] **Step 1: Write the failing selector tests**

Cover exact match, unsupported configuration, and duplicate configuration rejection:

```kotlin
class ProgramSelectorTest {
    private val config = GoalConfig(
        goal = FitnessGoal.GENERAL_FITNESS,
        level = ExperienceLevel.BEGINNER,
        equipmentProfile = EquipmentProfile.BODYWEIGHT_ONLY,
        sessionsPerWeek = 3,
        durationWeeks = 4,
        restDayMode = RestDayMode.FULL_REST,
    )

    private fun program(id: String) = ProgramTemplate(
        id = id,
        goal = config.goal,
        level = config.level,
        equipmentProfile = config.equipmentProfile,
        sessionsPerWeek = config.sessionsPerWeek,
        durationWeeks = config.durationWeeks,
        workouts = emptyList(),
    )

    @Test fun `returns the only exact reviewed program`() {
        val expected = program("general-beginner-bodyweight-3x-4w")
        assertEquals(ProgramSelectionResult.Found(expected), ProgramSelector.select(config, listOf(expected)))
    }

    @Test fun `returns unsupported when no exact program exists`() {
        assertEquals(ProgramSelectionResult.Unsupported, ProgramSelector.select(config, emptyList()))
    }

    @Test fun `rejects duplicate exact configurations`() {
        assertThrows(IllegalArgumentException::class.java) {
            ProgramSelector.select(config, listOf(program("one"), program("two")))
        }
    }
}
```

Import `org.junit.Assert.assertEquals` and `org.junit.Assert.assertThrows`; no mocking library is required.

- [ ] **Step 2: Run the test and confirm the red state**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.program.ProgramSelectorTest"
```

Expected: compilation fails because the domain models and selector do not exist.

- [ ] **Step 3: Add serializable domain contracts**

Implement these names and shapes; prescriptions belong to a workout, not the exercise catalog:

```kotlin
@Serializable enum class FitnessGoal { MUSCLE_GAIN, FAT_LOSS_CONDITIONING, ENDURANCE, GENERAL_FITNESS }
@Serializable enum class ExperienceLevel { BEGINNER, INTERMEDIATE }
@Serializable enum class EquipmentProfile { BODYWEIGHT_ONLY, DUMBBELLS, RESISTANCE_BANDS, FULL_GYM }
@Serializable enum class RestDayMode { FULL_REST, LIGHT_RECOVERY }
@Serializable enum class Equipment { BODYWEIGHT, DUMBBELL, BAND, BARBELL, BENCH, CABLE, MACHINE, CARDIO_MACHINE }
@Serializable enum class MuscleGroup { CHEST, BACK, SHOULDERS, BICEPS, TRICEPS, CORE, QUADS, HAMSTRINGS, GLUTES, CALVES, FULL_BODY, CARDIO, MOBILITY }
@Serializable enum class MovementPattern { SQUAT, HINGE, LUNGE, HORIZONTAL_PUSH, VERTICAL_PUSH, HORIZONTAL_PULL, VERTICAL_PULL, CARRY, CORE, LOCOMOTION, MOBILITY }

data class GoalConfig(
    val goal: FitnessGoal,
    val level: ExperienceLevel,
    val equipmentProfile: EquipmentProfile,
    val sessionsPerWeek: Int,
    val durationWeeks: Int,
    val restDayMode: RestDayMode,
)

@Serializable data class ExerciseDefinition(
    val id: String,
    val sourceId: String,
    val nameVi: String,
    val level: ExperienceLevel,
    val equipment: List<Equipment>,
    val movementPattern: MovementPattern,
    val primaryMuscle: MuscleGroup,
    val secondaryMuscles: List<MuscleGroup> = emptyList(),
    val instructionsVi: List<String>,
)

@Serializable data class ExercisePrescription(
    val exerciseId: String,
    val sets: Int,
    val repsMin: Int? = null,
    val repsMax: Int? = null,
    val durationSeconds: Int? = null,
    val restSeconds: Int,
)

@Serializable data class WorkoutTemplate(
    val sequence: Int,
    val week: Int,
    val titleVi: String,
    val focusVi: String,
    val estimatedMinutes: Int,
    val restDaysAfter: Int,
    val exercises: List<ExercisePrescription>,
)

@Serializable data class ProgramTemplate(
    val id: String,
    val goal: FitnessGoal,
    val level: ExperienceLevel,
    val equipmentProfile: EquipmentProfile,
    val sessionsPerWeek: Int,
    val durationWeeks: Int,
    val workouts: List<WorkoutTemplate>,
)
```

- [ ] **Step 4: Implement exact selection**

```kotlin
sealed interface ProgramSelectionResult {
    data class Found(val program: ProgramTemplate) : ProgramSelectionResult
    data object Unsupported : ProgramSelectionResult
}

object ProgramSelector {
    fun select(config: GoalConfig, programs: List<ProgramTemplate>): ProgramSelectionResult {
        val matches = programs.filter {
            it.goal == config.goal &&
                it.level == config.level &&
                it.equipmentProfile == config.equipmentProfile &&
                it.sessionsPerWeek == config.sessionsPerWeek &&
                it.durationWeeks == config.durationWeeks
        }
        require(matches.size <= 1) { "Duplicate programs for $config" }
        return matches.singleOrNull()?.let(ProgramSelectionResult::Found)
            ?: ProgramSelectionResult.Unsupported
    }
}
```

- [ ] **Step 5: Run tests and commit**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.program.ProgramSelectorTest"
git add app/src/main/java/com/example/myapplication/core app/src/test/java/com/example/myapplication/core
git commit -m "feat: define workout catalog contracts"
```

Expected: all three selector tests pass.

---

### Task 3: Curate and validate the Vietnamese exercise catalog

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/catalog/CatalogParser.kt`
- Create: `app/src/main/java/com/example/myapplication/core/catalog/CatalogValidator.kt`
- Create: `app/src/main/java/com/example/myapplication/core/catalog/AssetCatalogRepository.kt`
- Create: `app/src/main/assets/catalog/exercises_vi.json`
- Create: `docs/data/free-exercise-db-provenance.md`
- Test: `app/src/test/java/com/example/myapplication/core/catalog/CatalogParserTest.kt`
- Test: `app/src/androidTest/java/com/example/myapplication/core/catalog/BundledExerciseCatalogTest.kt`

- [ ] **Step 1: Write parser and bundled-catalog tests first**

The pure parser test must reject unknown enum values and missing fields. The instrumented test must enforce the release catalog contract:

```kotlin
@Test fun bundledExerciseCatalogIsReviewedAndComplete() {
    val json = InstrumentationRegistry.getInstrumentation().targetContext.assets
        .open("catalog/exercises_vi.json").bufferedReader().use { it.readText() }
    val exercises = CatalogParser.parseExercises(json)
    val issues = CatalogValidator.validateExercises(exercises)

    assertTrue("Expected 60-100 exercises, got ${exercises.size}", exercises.size in 60..100)
    assertEquals(emptyList<String>(), issues)
    assertTrue(exercises.all { it.instructionsVi.size in 2..5 })
}
```

- [ ] **Step 2: Run the focused tests and confirm failure**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.catalog.CatalogParserTest"
```

Expected: compilation fails because parser and validator types are absent.

- [ ] **Step 3: Implement strict parsing and validation**

Use one configured `Json` instance and return concrete issue messages:

```kotlin
object CatalogParser {
    private val json = Json { ignoreUnknownKeys = false; explicitNulls = false }
    fun parseExercises(raw: String): List<ExerciseDefinition> = json.decodeFromString(raw)
    fun parsePrograms(raw: String): List<ProgramTemplate> = json.decodeFromString(raw)
}

object CatalogValidator {
    fun validateExercises(items: List<ExerciseDefinition>): List<String> = buildList {
        items.groupBy { it.id }.filterValues { it.size > 1 }.keys.forEach { add("duplicate exercise id: $it") }
        items.forEach { exercise ->
            if (!exercise.id.matches(Regex("[a-z0-9_]+"))) add("invalid exercise id: ${exercise.id}")
            if (exercise.sourceId.isBlank()) add("missing sourceId: ${exercise.id}")
            if (exercise.nameVi.isBlank()) add("missing Vietnamese name: ${exercise.id}")
            if (exercise.instructionsVi.size !in 2..5 || exercise.instructionsVi.any(String::isBlank)) {
                add("invalid instructions: ${exercise.id}")
            }
            if (exercise.equipment.isEmpty()) add("missing equipment: ${exercise.id}")
        }
    }
}
```

`AssetCatalogRepository` must read both asset files once with `lazy`, parse them, run validation, and throw `IllegalStateException(issues.joinToString())` when bundled content is invalid.

- [ ] **Step 4: Curate exactly these 64 app IDs**

Use Free Exercise DB records as instruction sources where a matching record exists and map that source ID. For project-authored walking, low-impact, or mobility records without a source match, use a `sourceId` prefixed with `project:` and document it in provenance. Write concise Vietnamese instructions and include these app IDs so the first program set has balanced coverage:

```text
bodyweight_squat, goblet_squat, barbell_back_squat, leg_press,
reverse_lunge, walking_lunge, split_squat, step_up,
bodyweight_good_morning, dumbbell_romanian_deadlift, barbell_romanian_deadlift, conventional_deadlift,
glute_bridge, single_leg_glute_bridge, hip_thrust, leg_curl, leg_extension, standing_calf_raise,
incline_push_up, knee_push_up, push_up, dumbbell_bench_press, barbell_bench_press,
incline_dumbbell_press, machine_chest_press, cable_fly,
dumbbell_overhead_press, barbell_overhead_press, dumbbell_lateral_raise,
triceps_pushdown, overhead_triceps_extension,
prone_y_raise, reverse_snow_angel, superman_hold, inverted_row,
one_arm_dumbbell_row, barbell_bent_over_row, seated_cable_row, lat_pulldown,
assisted_pull_up, pull_up, face_pull, reverse_fly, back_extension,
dumbbell_biceps_curl, hammer_curl,
plank, side_plank, dead_bug, bird_dog, mountain_climber, bicycle_crunch,
hanging_knee_raise, pallof_press,
brisk_walk, high_knees, jumping_jack, low_impact_jumping_jack, jump_rope,
stationary_bike, treadmill_walk, treadmill_run, rowing_machine, elliptical
```

Every object must follow this canonical shape; do not copy English prose into the Vietnamese fields:

```json
{
  "id": "goblet_squat",
  "sourceId": "Goblet_Squat",
  "nameVi": "Goblet Squat",
  "level": "BEGINNER",
  "equipment": ["DUMBBELL"],
  "movementPattern": "SQUAT",
  "primaryMuscle": "QUADS",
  "secondaryMuscles": ["GLUTES", "CORE"],
  "instructionsVi": [
    "Giữ một quả tạ sát trước ngực, hai chân rộng ngang vai.",
    "Hạ hông xuống trong khi giữ ngực mở và đầu gối cùng hướng với mũi chân.",
    "Đẩy bàn chân xuống sàn để đứng lên, không khóa gối đột ngột."
  ]
}
```

- [ ] **Step 5: Record provenance**

`docs/data/free-exercise-db-provenance.md` must state the repository URL, Unlicense/public-domain status, retrieval date `2026-06-29`, that only 64 records were curated, that Vietnamese text is a project translation, and that images are intentionally not bundled in release one.

- [ ] **Step 6: Run validation on an emulator and commit**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.catalog.CatalogParserTest"
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.core.catalog.BundledExerciseCatalogTest
git add app/src/main/java/com/example/myapplication/core/catalog app/src/main/assets/catalog/exercises_vi.json app/src/test app/src/androidTest docs/data/free-exercise-db-provenance.md
git commit -m "feat: add curated Vietnamese exercise catalog"
```

Expected: parser and bundled-catalog tests pass; the instrumented test reports 64 exercises and no validation issues.

---

### Task 4: Author and validate six reviewed program templates

**Files:**
- Create: `app/src/main/assets/catalog/programs.json`
- Create: `docs/data/program-review-checklist.md`
- Modify: `app/src/main/java/com/example/myapplication/core/catalog/CatalogValidator.kt`
- Test: `app/src/androidTest/java/com/example/myapplication/core/catalog/BundledProgramCatalogTest.kt`

- [ ] **Step 1: Write the failing program validation test**

```kotlin
@Test fun bundledProgramsAreCompleteAndCrossReferenced() {
    val assets = InstrumentationRegistry.getInstrumentation().targetContext.assets
    val exercises = CatalogParser.parseExercises(assets.open("catalog/exercises_vi.json").bufferedReader().readText())
    val programs = CatalogParser.parsePrograms(assets.open("catalog/programs.json").bufferedReader().readText())
    val issues = CatalogValidator.validatePrograms(programs, exercises.associateBy { it.id })

    assertEquals(6, programs.size)
    assertEquals(emptyList<String>(), issues)
    assertEquals(FitnessGoal.entries.toSet(), programs.map { it.goal }.toSet())
}
```

- [ ] **Step 2: Run it and confirm the missing-asset failure**

Run:

```powershell
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.core.catalog.BundledProgramCatalogTest
```

Expected: FAIL because `catalog/programs.json` does not exist.

- [ ] **Step 3: Extend program validation with explicit rules**

`validatePrograms` must report duplicate IDs and duplicate match keys, require `workouts.size == sessionsPerWeek * durationWeeks`, require contiguous sequence values starting at zero, require `week in 1..durationWeeks`, require each week to contain `sessionsPerWeek` workouts, require `estimatedMinutes in 10..90`, require `restDaysAfter in 0..3`, resolve every exercise ID, require `sets in 1..6`, `restSeconds in 15..300`, and require exactly one prescription mode:

```kotlin
val repMode = prescription.repsMin?.let { min ->
    min in 1..50 && prescription.repsMax?.let { max -> max in min..100 } == true
} == true
val timeMode = prescription.durationSeconds?.let { it in 10..3600 } == true
if (!(repMode xor timeMode)) issues += "${program.id}: invalid prescription at workout ${workout.sequence}"
```

Also assert that each seven-day weekly block is represented by `sessionsPerWeek + sum(restDaysAfter) == 7`.

- [ ] **Step 4: Author this exact supported-program matrix**

```text
general-beginner-bodyweight-3x-4w  GENERAL_FITNESS       BEGINNER     BODYWEIGHT_ONLY  3  4
conditioning-beginner-bodyweight-4x-4w FAT_LOSS_CONDITIONING BEGINNER BODYWEIGHT_ONLY  4  4
endurance-beginner-bodyweight-3x-4w ENDURANCE             BEGINNER     BODYWEIGHT_ONLY  3  4
muscle-beginner-dumbbells-3x-4w    MUSCLE_GAIN           BEGINNER     DUMBBELLS        3  4
general-intermediate-gym-4x-8w     GENERAL_FITNESS       INTERMEDIATE FULL_GYM         4  8
muscle-intermediate-gym-4x-8w      MUSCLE_GAIN           INTERMEDIATE FULL_GYM         4  8
```

Use these reviewed structures and expand every week into explicit `WorkoutTemplate` records:

- General beginner: three alternating full-body sessions; rest pattern `1,1,2`; weeks 1-2 use 2 sets and weeks 3-4 use 3 sets.
- Conditioning beginner: low-impact cardio/core, lower-body circuit, upper-body circuit, mixed conditioning; rest pattern `0,1,0,2`; replace jumping with low-impact jumping jacks in weeks 1-2.
- Endurance beginner: brisk-walk intervals, low-impact conditioning, longer steady walk; rest pattern `1,1,2`; increase timed intervals by no more than 10 percent per week.
- Muscle beginner dumbbells: full-body A/B/C using squat or lunge, hinge, push, pull, shoulders or arms, and core; rest pattern `1,1,2`; weeks 1-2 use 2 sets and weeks 3-4 use 3 sets.
- Both intermediate gym programs: upper/lower/upper/lower; rest pattern `0,1,0,2`; eight weeks split into two four-week phases, with the second phase changing at most two accessory exercises per workout.

Every workout must start with compound movements, place isolation/core work later, and avoid loading the same primary muscle on consecutive workouts.

- [ ] **Step 5: Complete the human review record**

Create one checklist row per program with reviewer columns for goal fit, exercise availability, muscle balance, consecutive-muscle check, weekly volume, rest spacing, beginner appropriateness, Vietnamese instructions, and final approval. Mark a row approved only after all automated checks pass and a human reads every workout.

- [ ] **Step 6: Run catalog tests and commit**

Run:

```powershell
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.core.catalog.BundledProgramCatalogTest
git add app/src/main/assets/catalog/programs.json app/src/main/java/com/example/myapplication/core/catalog/CatalogValidator.kt app/src/androidTest docs/data/program-review-checklist.md
git commit -m "feat: add reviewed preset workout programs"
```

Expected: six programs pass all structural, reference, and schedule checks.

---

### Task 5: Implement schedule, Today resolution, and progress calculations

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/program/SchedulePlanner.kt`
- Create: `app/src/main/java/com/example/myapplication/core/today/TodayResolver.kt`
- Create: `app/src/main/java/com/example/myapplication/core/progress/ProgressCalculator.kt`
- Test: `app/src/test/java/com/example/myapplication/core/program/SchedulePlannerTest.kt`
- Test: `app/src/test/java/com/example/myapplication/core/today/TodayResolverTest.kt`
- Test: `app/src/test/java/com/example/myapplication/core/progress/ProgressCalculatorTest.kt`

- [ ] **Step 1: Write failing scheduling tests**

Assert that a 3-session week with rest pattern `1,1,2` produces due days `0,2,4`, that completing the first workout one day late shifts every remaining due day by one, and that an incomplete overdue workout is returned instead of a recovery state.

```kotlin
@Test fun `three day plan preserves reviewed spacing`() {
    val dueDays = SchedulePlanner.dueEpochDays(startEpochDay = 100, restDaysAfter = listOf(1, 1, 2))
    assertEquals(listOf(100L, 102L, 104L), dueDays)
}
```

- [ ] **Step 2: Write failing progress tests**

Cover zero division, percentage, month grouping, and weekly commitment streak:

```kotlin
@Test fun `streak counts consecutive completed target weeks`() {
    val monday = LocalDate.of(2026, 6, 8).toEpochDay()
    val completed = listOf(monday, monday + 2, monday + 4, monday + 7, monday + 9, monday + 11)
    assertEquals(
        2,
        ProgressCalculator.weeklyStreak(completed, targetPerWeek = 3, currentEpochDay = monday + 13),
    )
}
```

- [ ] **Step 3: Run tests to verify the red state**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.*"
```

Expected: compilation fails for the three missing services.

- [ ] **Step 4: Implement pure services**

`SchedulePlanner` must advance each due day by `1 + restDaysAfter`. `TodayResolver` must use the earliest incomplete workout and return `Workout` when `dueEpochDay <= today`, `Recovery` otherwise, `GoalComplete` when none remain, and `NoGoal` when no active goal exists. `ProgressCalculator.percentage` must return zero for a zero target and otherwise clamp `completed * 100 / total` to `0..100`.

Use `java.time.LocalDate` and `WeekFields.ISO` for month and streak grouping; store only `epochDay` at persistence boundaries.

- [ ] **Step 5: Run tests and commit**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.*"
git add app/src/main/java/com/example/myapplication/core app/src/test/java/com/example/myapplication/core
git commit -m "feat: add workout scheduling and progress rules"
```

Expected: all pure domain tests pass without Android runtime dependencies.

---

### Task 6: Add Room persistence and transactional workout completion

**Files:**
- Create: `app/src/main/java/com/example/myapplication/data/local/GoalEntity.kt`
- Create: `app/src/main/java/com/example/myapplication/data/local/WorkoutSessionEntity.kt`
- Create: `app/src/main/java/com/example/myapplication/data/local/SessionExerciseEntity.kt`
- Create: `app/src/main/java/com/example/myapplication/data/local/WorkoutDao.kt`
- Create: `app/src/main/java/com/example/myapplication/data/local/GymDatabase.kt`
- Create: `app/src/main/java/com/example/myapplication/core/model/WorkoutModels.kt`
- Create: `app/src/main/java/com/example/myapplication/data/WorkoutRepository.kt`
- Create: `app/src/main/java/com/example/myapplication/data/RoomWorkoutRepository.kt`
- Test: `app/src/androidTest/java/com/example/myapplication/data/RoomWorkoutRepositoryTest.kt`

- [ ] **Step 1: Write failing in-memory Room tests**

Cover goal creation, archived history, incomplete exercise blocking, idempotent completion, and missed-session shifting. The key acceptance test is:

```kotlin
@Test fun lateCompletionShiftsRemainingSessionsAndDoesNotDuplicateHistory() = runTest {
    repository.createGoal(config, program, startEpochDay = 100)
    val firstSession = dao.currentIncompleteSessionNow()
    dao.sessionExercisesNow(firstSession.id).forEach { exercise ->
        repository.setExerciseChecked(firstSession.id, exercise.orderIndex, checked = true)
    }

    assertEquals(CompleteWorkoutResult.Completed, repository.completeWorkout(firstSession.id, 101))
    assertEquals(CompleteWorkoutResult.AlreadyCompleted, repository.completeWorkout(firstSession.id, 101))
    assertEquals(103L, dao.currentIncompleteSessionNow().dueEpochDay)
    assertEquals(1, dao.completedSessionCountNow())
}
```

- [ ] **Step 2: Run the test and confirm failure**

Run:

```powershell
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.data.RoomWorkoutRepositoryTest
```

Expected: compilation fails because Room entities and repository do not exist.

- [ ] **Step 3: Create normalized entities and DAO queries**

Use these keys and invariants:

```kotlin
@Entity(tableName = "goals")
data class GoalEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val programId: String,
    val goal: FitnessGoal,
    val level: ExperienceLevel,
    val equipmentProfile: EquipmentProfile,
    val sessionsPerWeek: Int,
    val durationWeeks: Int,
    val restDayMode: RestDayMode,
    val createdEpochDay: Long,
    val archived: Boolean = false,
)

@Entity(
    tableName = "workout_sessions",
    foreignKeys = [ForeignKey(entity = GoalEntity::class, parentColumns = ["id"], childColumns = ["goalId"], onDelete = ForeignKey.CASCADE)],
    indices = [Index(value = ["goalId", "sequenceIndex"], unique = true)],
)
data class WorkoutSessionEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val goalId: Long,
    val sequenceIndex: Int,
    val titleVi: String,
    val focusVi: String,
    val estimatedMinutes: Int,
    val dueEpochDay: Long,
    val completedEpochDay: Long? = null,
)

@Entity(
    tableName = "session_exercises",
    primaryKeys = ["sessionId", "orderIndex"],
    foreignKeys = [ForeignKey(entity = WorkoutSessionEntity::class, parentColumns = ["id"], childColumns = ["sessionId"], onDelete = ForeignKey.CASCADE)],
)
data class SessionExerciseEntity(
    val sessionId: Long,
    val orderIndex: Int,
    val exerciseId: String,
    val sets: Int,
    val repsMin: Int?,
    val repsMax: Int?,
    val durationSeconds: Int?,
    val restSeconds: Int,
    val checked: Boolean = false,
)
```

Add DAO methods for observing the active goal, earliest incomplete session with its exercises, all completed sessions across active and archived goals, setting one check by `(sessionId, orderIndex)`, counting unchecked rows, completing a session only when `completedEpochDay IS NULL`, archiving active goals, and shifting only incomplete sessions with a greater sequence.

- [ ] **Step 4: Implement repository transactions**

Define the repository contract and result names once, then use them unchanged in ViewModels:

```kotlin
interface WorkoutRepository {
    fun observeActiveGoal(): Flow<ActiveGoal?>
    fun observeCurrentWorkout(): Flow<WorkoutSession?>
    fun observeCompletedWorkouts(): Flow<List<CompletedWorkout>>
    suspend fun createGoal(config: GoalConfig, program: ProgramTemplate, startEpochDay: Long)
    suspend fun setExerciseChecked(sessionId: Long, orderIndex: Int, checked: Boolean)
    suspend fun completeWorkout(sessionId: Long, completedEpochDay: Long): CompleteWorkoutResult
    suspend fun archiveActiveGoal()
}

sealed interface CompleteWorkoutResult {
    data object Completed : CompleteWorkoutResult
    data object BlockedByUncheckedExercises : CompleteWorkoutResult
    data object AlreadyCompleted : CompleteWorkoutResult
}
```

`WorkoutModels.kt` defines `ActiveGoal(id, config, totalWorkouts)`, `WorkoutSession(id, goalId, sequenceIndex, titleVi, focusVi, estimatedMinutes, dueEpochDay, exercises)`, `WorkoutExercise(orderIndex, exerciseId, prescription, checked)`, and `CompletedWorkout(goalId, completedEpochDay)`.

Use `RoomDatabase.withTransaction`. `createGoal` must archive any active goal, insert the new goal, call `SchedulePlanner`, snapshot all workout prescriptions into Room, and preserve older completed rows. `completeWorkout(sessionId, completedEpochDay)` must:

1. return `BlockedByUncheckedExercises` when unchecked count is nonzero;
2. return `AlreadyCompleted` when the conditional update affects zero rows;
3. write the completion epoch day;
4. calculate `delay = maxOf(0, completedEpochDay - dueEpochDay)`;
5. shift every later incomplete session by `delay` in the same transaction.

- [ ] **Step 5: Run Room tests, export schema, and commit**

Run:

```powershell
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.data.RoomWorkoutRepositoryTest
.\gradlew.bat assembleDebug
git add app/src/main/java/com/example/myapplication/data app/src/androidTest app/schemas
git commit -m "feat: persist goals and workout completion"
```

Expected: Room tests pass and schema version 1 is exported under `app/schemas`.

---

### Task 7: Build the white-first theme, application container, and navigation shell

**Files:**
- Create: `app/src/main/java/com/example/myapplication/GymApplication.kt`
- Create: `app/src/main/java/com/example/myapplication/app/AppContainer.kt`
- Create: `app/src/main/java/com/example/myapplication/app/AppDestination.kt`
- Create: `app/src/main/java/com/example/myapplication/app/GymApp.kt`
- Modify: `app/src/main/java/com/example/myapplication/MainActivity.kt`
- Modify: `app/src/main/AndroidManifest.xml`
- Modify: `app/src/main/java/com/example/myapplication/ui/theme/Color.kt`
- Modify: `app/src/main/java/com/example/myapplication/ui/theme/Theme.kt`
- Modify: `app/src/main/java/com/example/myapplication/ui/theme/Type.kt`
- Test: `app/src/androidTest/java/com/example/myapplication/app/GymAppNavigationTest.kt`

- [ ] **Step 1: Write the failing navigation shell test**

Set fake root state with an active goal, render `GymApp`, assert the three labels `Hôm nay`, `Tiến độ`, and `Cài đặt`, click each, and assert a destination heading changes. A no-goal root state must show `Tạo mục tiêu` and no bottom bar.

- [ ] **Step 2: Run the test and confirm failure**

Run:

```powershell
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.app.GymAppNavigationTest
```

Expected: compilation fails because `GymApp` does not exist.

- [ ] **Step 3: Replace the starter theme**

Define these exact colors and a light-only scheme; remove dynamic and gradient behavior:

```kotlin
val White = Color(0xFFFFFFFF)
val Navy = Color(0xFF14213D)
val SuccessGreen = Color(0xFF22C55E)
val EnergyOrange = Color(0xFFF97316)
val SurfaceGray = Color(0xFFF3F4F6)
val BorderGray = Color(0xFFE5E7EB)
val MutedText = Color(0xFF64748B)

private val GymLightColors = lightColorScheme(
    primary = EnergyOrange,
    onPrimary = White,
    secondary = SuccessGreen,
    onSecondary = Navy,
    background = White,
    onBackground = Navy,
    surface = White,
    onSurface = Navy,
    surfaceVariant = SurfaceGray,
    onSurfaceVariant = MutedText,
    outline = BorderGray,
)
```

Rename the theme Composable to `GymAppTheme` and use bold title typography with default system fonts.

- [ ] **Step 4: Wire dependencies without a DI framework**

`GymApplication` owns one `AppContainer`. In this task, `AppContainer` constructs only `GymDatabase`, `AssetCatalogRepository`, and `RoomWorkoutRepository`; Task 11 extends it with `SettingsRepository` and `AlarmReminderScheduler`. Set `android:name=".GymApplication"` in the manifest.

- [ ] **Step 5: Implement the root shell**

Use Navigation Compose with string routes `onboarding`, `today`, `progress`, and `settings`. Show `NavigationBar` only for the last three. Until Tasks 8-11 replace route content, render small internal placeholder Composables containing the destination heading so Task 7 compiles and its navigation test is meaningful. `MainActivity` must contain only edge-to-edge setup and:

```kotlin
setContent {
    GymAppTheme {
        GymApp(container = (application as GymApplication).container)
    }
}
```

- [ ] **Step 6: Run UI test and commit**

Run:

```powershell
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.app.GymAppNavigationTest
git add app/src/main
git commit -m "feat: add gym app theme and navigation shell"
```

Expected: the no-goal and active-goal navigation states both pass.

---

### Task 8: Implement goal onboarding and supported-combination guidance

**Files:**
- Create: `app/src/main/java/com/example/myapplication/feature/onboarding/OnboardingUiState.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/onboarding/OnboardingViewModel.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/onboarding/OnboardingScreen.kt`
- Test: `app/src/test/java/com/example/myapplication/feature/onboarding/OnboardingViewModelTest.kt`
- Test: `app/src/androidTest/java/com/example/myapplication/feature/onboarding/OnboardingScreenTest.kt`

- [ ] **Step 1: Write failing ViewModel tests**

Cover advancing through goal, level, equipment, commitment, rest behavior, and review; prevent unsupported creation; and verify exact program creation calls the repository once.

```kotlin
@Test fun `unsupported combination explains which choices are available`() = runTest {
    val repository = FakeWorkoutRepository()
    val viewModel = OnboardingViewModel(programs, repository, clock)
    viewModel.selectGoal(FitnessGoal.MUSCLE_GAIN)
    viewModel.selectLevel(ExperienceLevel.BEGINNER)
    viewModel.selectEquipment(EquipmentProfile.BODYWEIGHT_ONLY)
    viewModel.selectCommitment(3, 4)
    viewModel.createGoal()

    assertTrue(viewModel.state.value is OnboardingUiState.Unsupported)
    assertEquals(0, repository.createGoalCalls)
}
```

Use a hand-written `FakeWorkoutRepository` with a `createGoalCalls` counter; do not add MockK for this plan.

- [ ] **Step 2: Run tests to confirm failure**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.onboarding.OnboardingViewModelTest"
```

Expected: compilation fails for missing onboarding classes.

- [ ] **Step 3: Implement immutable onboarding state**

Use one `OnboardingDraft` and a sealed step enum. Derive available options from the six loaded programs after each choice so the UI does not present impossible later selections. Keep a final defensive `ProgramSelector.select` check and show supported alternatives if no match exists.

- [ ] **Step 4: Implement the one-decision-per-screen Compose flow**

Use white surfaces, navy text, orange selected actions, clear back navigation, and a final review card. The create button calls the ViewModel once and becomes disabled while saving. No account, weight, measurement, nutrition, or AI fields may appear.

- [ ] **Step 5: Run unit and UI tests and commit**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.onboarding.*"
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.feature.onboarding.OnboardingScreenTest
git add app/src/main/java/com/example/myapplication/feature/onboarding app/src/test app/src/androidTest
git commit -m "feat: add goal creation flow"
```

Expected: supported creation, unsupported guidance, and review-screen behavior pass.

---

### Task 9: Implement Today's workout checklist and atomic completion

**Files:**
- Create: `app/src/main/java/com/example/myapplication/feature/today/TodayUiState.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/today/TodayViewModel.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/today/TodayScreen.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/today/ExerciseCard.kt`
- Test: `app/src/test/java/com/example/myapplication/feature/today/TodayViewModelTest.kt`
- Test: `app/src/androidTest/java/com/example/myapplication/feature/today/TodayScreenTest.kt`

- [ ] **Step 1: Write failing ViewModel tests**

Test workout, full-rest, light-recovery, goal-complete, and error states. Verify the completion command is blocked until all exercises are checked and that a repository failure restores an enabled retry action.

- [ ] **Step 2: Run tests and confirm failure**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.today.TodayViewModelTest"
```

Expected: compilation fails for missing Today feature types.

- [ ] **Step 3: Implement Today state and ViewModel**

Expose immutable `Loading`, `Workout`, `Recovery`, `GoalComplete`, and `Error` states. Join each persisted `exerciseId` with `AssetCatalogRepository` to obtain the Vietnamese name and instructions; treat a missing catalog ID as `Error` instead of showing a blank row. In `Workout`, include stable session ID, title, focus, estimated minutes, exercise rows, checked count, and `canComplete = exercises.isNotEmpty() && exercises.all { it.checked }`. Completion must call `repository.completeWorkout(state.sessionId, clock.todayEpochDay())`.

- [ ] **Step 4: Implement the checklist screen**

Each card displays Vietnamese name, sets with rep range or duration, rest seconds, checkbox, and expandable 2-5 step technique instructions. Use the green color plus a check icon for completion so meaning does not depend on color. Keep the orange `Hoàn thành buổi tập` button disabled until every row is checked.

- [ ] **Step 5: Run tests and commit**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.today.*"
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.feature.today.TodayScreenTest
git add app/src/main/java/com/example/myapplication/feature/today app/src/test app/src/androidTest
git commit -m "feat: add daily workout checklist"
```

Expected: completion gating, recovery variants, expansion, retry, and success tests pass.

---

### Task 10: Implement goal, calendar, and weekly streak progress

**Files:**
- Create: `app/src/main/java/com/example/myapplication/feature/progress/ProgressUiState.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/progress/ProgressViewModel.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/progress/ProgressScreen.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/progress/MonthCalendar.kt`
- Test: `app/src/test/java/com/example/myapplication/feature/progress/ProgressViewModelTest.kt`
- Test: `app/src/androidTest/java/com/example/myapplication/feature/progress/ProgressScreenTest.kt`

- [ ] **Step 1: Write failing progress feature tests**

Provide 7 completed sessions out of 12 across two ISO weeks and assert `58%`, `7/12 buổi`, a two-week streak, and the exact seven marked epoch days. Add empty-history and archived-goal cases.

- [ ] **Step 2: Run tests and confirm failure**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.progress.ProgressViewModelTest"
```

Expected: compilation fails for missing progress feature types.

- [ ] **Step 3: Implement ProgressViewModel**

Combine the active goal and the all-history completed-workout flow, call only `ProgressCalculator` for derived values, and expose the selected month plus previous/next month actions. Calculate percentage and `completed/total` from rows whose `goalId` matches the active goal; populate the calendar from all completed rows so archived-goal history remains visible. Completed workout dates, not exercise ticks or recovery days, drive all progress.

- [ ] **Step 4: Implement the progress screen**

Show a large numeric percentage, a determinate progress indicator, completed/total text, weekly streak, and a seven-column calendar. Mark completed days with a green filled circle and a check semantic description. Keep the screen useful with zero history.

- [ ] **Step 5: Run tests and commit**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.progress.*"
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.feature.progress.ProgressScreenTest
git add app/src/main/java/com/example/myapplication/feature/progress app/src/test app/src/androidTest
git commit -m "feat: add workout progress dashboard"
```

Expected: summary, empty, month navigation, and semantic calendar tests pass.

---

### Task 11: Add settings, confirmed goal replacement or deletion, and local reminders

**Files:**
- Create: `app/src/main/java/com/example/myapplication/data/SettingsRepository.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/settings/SettingsUiState.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/settings/SettingsViewModel.kt`
- Create: `app/src/main/java/com/example/myapplication/feature/settings/SettingsScreen.kt`
- Create: `app/src/main/java/com/example/myapplication/notification/ReminderScheduler.kt`
- Create: `app/src/main/java/com/example/myapplication/notification/AlarmReminderScheduler.kt`
- Create: `app/src/main/java/com/example/myapplication/notification/WorkoutReminderReceiver.kt`
- Create: `app/src/main/java/com/example/myapplication/notification/BootReceiver.kt`
- Modify: `app/src/main/AndroidManifest.xml`
- Modify: `app/src/main/res/values/strings.xml`
- Modify: `app/src/main/java/com/example/myapplication/app/AppContainer.kt`
- Test: `app/src/test/java/com/example/myapplication/feature/settings/SettingsViewModelTest.kt`
- Test: `app/src/androidTest/java/com/example/myapplication/feature/settings/SettingsScreenTest.kt`

- [ ] **Step 1: Write failing settings tests**

Assert that changing rest mode persists, reminder scheduling receives the selected local time, goal replacement is impossible before confirmation, and confirming replacement archives the current goal while retaining completed sessions. Add a separate deletion test proving that cancel leaves the goal active and confirm calls `archiveActiveGoal()` while history remains queryable.

- [ ] **Step 2: Run tests and confirm failure**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.settings.SettingsViewModelTest"
```

Expected: compilation fails for missing settings and reminder contracts.

- [ ] **Step 3: Implement DataStore preferences**

Create one top-level `Context.dataStore` named `gym_settings`. Store `reminder_enabled`, `reminder_hour`, `reminder_minute`, and the rest-day enum name. Expose typed `Flow<Settings>` and update methods that preserve unrelated keys.

- [ ] **Step 4: Implement inexact daily alarms without network access**

Define:

```kotlin
interface ReminderScheduler {
    fun schedule(hour: Int, minute: Int)
    fun cancel()
}
```

`AlarmReminderScheduler` calculates the next future local occurrence and calls `AlarmManager.setAndAllowWhileIdle`. `WorkoutReminderReceiver` posts a notification to channel `workout_reminders` and schedules the next occurrence. `BootReceiver` restores the alarm only when reminders are enabled.

Add manifest permissions `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED`; keep the workout receiver non-exported and export the boot receiver only for system broadcasts. Request notification permission only after the user enables reminders on Android 13+.

- [ ] **Step 5: Implement settings UI and confirmation**

Show current goal summary, rest-day mode, reminder toggle/time, `Đổi mục tiêu`, `Xóa mục tiêu hiện tại`, and no unrelated settings. `Đổi mục tiêu` opens a confirmation dialog explaining that completed history remains; confirmation navigates to onboarding in replacement mode. `Xóa mục tiêu hiện tại` uses a separate destructive confirmation, calls `archiveActiveGoal()`, preserves completed history, and returns the root flow to onboarding.

- [ ] **Step 6: Run tests and commit**

Run:

```powershell
.\gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.settings.*"
.\gradlew.bat connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.myapplication.feature.settings.SettingsScreenTest
git add app/src/main app/src/test app/src/androidTest
git commit -m "feat: add settings and workout reminders"
```

Expected: preference, permission, reminder, replacement, deletion-cancel, deletion-confirm, and retained-history tests pass.

---

### Task 12: Verify the complete offline journey and release candidate

**Files:**
- Create: `app/src/androidTest/java/com/example/myapplication/GymAppEndToEndTest.kt`
- Create: `docs/verification/manual-android-checklist.md`
- Modify: `app/src/main/res/values/strings.xml`
- Modify: any files with accessibility or integration defects found by this task

- [ ] **Step 1: Write the end-to-end test before fixing integration gaps**

The test must clear app data, create `GENERAL_FITNESS / BEGINNER / BODYWEIGHT_ONLY / 3 sessions / 4 weeks`, open Today, expand instructions, tick every exercise, complete the session, open Progress, and assert `1/12 buổi` plus the completed date. Relaunch and assert the next workout or recovery state survives process recreation.

- [ ] **Step 2: Run the full suite and capture failures**

Run:

```powershell
.\gradlew.bat testDebugUnitTest
.\gradlew.bat connectedDebugAndroidTest
```

Expected before integration fixes: the new end-to-end test may fail at the first disconnected route or missing string; all earlier focused tests remain green.

- [ ] **Step 3: Fix only evidence-backed integration and accessibility defects**

Add content descriptions to icon-only controls, ensure at least 48dp touch targets, preserve state across rotation, replace any hard-coded user-facing strings with Vietnamese resources, and ensure no screen uses gradients or dynamic colors. Do not add new product features.

- [ ] **Step 4: Complete the manual device matrix**

Record pass/fail and device details in `docs/verification/manual-android-checklist.md` for:

```text
Small phone portrait: onboarding, Today scrolling, expanded instructions
Large phone portrait: all three destinations, calendar alignment
Landscape: Today and Progress without clipped primary actions
Android 13+: notification permission accepted and denied
Offline mode: first launch, goal creation, completion, relaunch
Clock moved forward one day: missed workout remains current
Goal replacement: old completed date remains visible
Goal deletion: confirmation is required and old completed date remains visible
App data cleared: onboarding returns as documented
```

- [ ] **Step 5: Run final verification**

Run:

```powershell
.\gradlew.bat testDebugUnitTest
.\gradlew.bat connectedDebugAndroidTest
.\gradlew.bat lintDebug
.\gradlew.bat assembleDebug
```

Expected: all commands end with `BUILD SUCCESSFUL`, no unresolved catalog references exist, and the debug APK is produced at `app/build/outputs/apk/debug/app-debug.apk`.

- [ ] **Step 6: Commit the verified release candidate**

Run:

```powershell
git add app docs/verification
git commit -m "test: verify offline workout journey"
git status --short
```

Expected: the commit succeeds and `git status --short` is empty.

---

## Implementation order and release checkpoints

1. Tasks 1-2 produce a compilable foundation and stable contracts.
2. Tasks 3-4 form the content checkpoint: reviewed data exists before UI work relies on it.
3. Tasks 5-6 form the behavior checkpoint: scheduling and persistence work without the final UI.
4. Tasks 7-10 form the user-journey checkpoint: create goal, train, and view progress.
5. Task 11 adds optional local reminders and safe goal replacement or deletion.
6. Task 12 is the release gate; do not claim completion before all automated and manual checks pass.
