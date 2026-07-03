# Gym App Functional Upgrades Master Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add all ten approved functional upgrades while preserving the current visual system, three primary destinations, offline workout rules, completed history, and deterministic preset-program behavior.

**Architecture:** Deliver four independently testable phases: personalization foundations, in-workout flexibility, progress intelligence, and reusable nutrition entries. Pure Kotlin policies make every recommendation deterministic; Room stores durable user choices and audit history; existing screen-level ViewModels expose immutable UI state without introducing new modules or a dependency-injection framework.

**Tech Stack:** Kotlin, Jetpack Compose Material 3, Room, DataStore, coroutines/Flow, kotlinx.serialization, JUnit, AndroidX Room migration tests, Compose UI tests.

---

## Scope and invariants

This plan covers the ten approved functions:

1. Reviewed exercise substitutions.
2. Per-session time-budget variants.
3. End-of-workout difficulty feedback.
4. Deterministic program phases.
5. Deload detection and confirmed application.
6. Reviewed warm-up and cool-down blocks.
7. Schedule change preview before applying.
8. Weekly conclusions derived from local data.
9. Goal completion forecast.
10. Editable nutrition drafts and reusable meal templates.

The following constraints apply to every task:

- Keep the current colors, typography, component style, and navigation structure.
- Do not add accounts, cloud sync, network permissions, random workout generation, medical advice, or exercise weight/repetition logging.
- Core workout planning, substitutions, deload rules, reports, forecasts, and meal templates work without a network connection.
- Existing completed sessions are immutable. Migrations preserve goals, exercise checks, completion history, nutrition totals, check-ins, achievements, and adaptation decisions.
- A workout completes only when every non-omitted exercise is checked.
- User-confirmed changes are atomic and auditable; previews never mutate Room.
- Each numbered task is one bounded commit. Do not combine unrelated tasks in a commit.

## Delivery order

| Phase | Tasks | Working software produced |
|---|---:|---|
| 1. Personalization foundation | 1–5 | Difficulty history, phased programs, and confirmed deloads |
| 2. Session flexibility | 6–10 | Substitutions, time budgets, warm-up/cool-down, and schedule preview |
| 3. Progress intelligence | 11–12 | Weekly conclusions and a transparent goal forecast |
| 4. Nutrition reuse | 13–14 | Editable scan/manual drafts and local meal templates |
| Release verification | 15 | Migration, unit, UI, build, and real-device evidence |

## File ownership map

- `core/feedback`: workout difficulty model and summaries; no Android dependencies.
- `core/program`: phase, deload, time-budget, and schedule policies; pure deterministic Kotlin.
- `core/catalog`: substitution and warm-up/cool-down selection from reviewed catalog data.
- `core/progress`: weekly insight and forecast calculations; pure deterministic Kotlin.
- `core/nutrition`: reusable meal-template domain model.
- `data/local`: Room entities, DAOs, migrations, and atomic mutations.
- `data`: repository interfaces and Room implementations.
- `feature/today`: session actions and feedback UI state.
- `feature/progress`: conclusions and forecast presentation.
- `feature/nutrition`: editable draft and meal-template presentation.
- `feature/settings`: schedule preview and confirmation without a new navigation destination.

---

## Phase 1 — Personalization foundation

### Task 1: Persist workout difficulty feedback

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/feedback/WorkoutFeedback.kt`
- Create: `app/src/main/java/com/example/myapplication/data/local/WorkoutFeedbackEntity.kt`
- Create: `app/src/main/java/com/example/myapplication/data/local/WorkoutFeedbackDao.kt`
- Create: `app/src/main/java/com/example/myapplication/data/WorkoutFeedbackRepository.kt`
- Create: `app/src/main/java/com/example/myapplication/data/RoomWorkoutFeedbackRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/GymDatabase.kt`
- Modify: `app/src/main/java/com/example/myapplication/app/AppContainer.kt`
- Create: `app/schemas/com.example.myapplication.data.local.GymDatabase/5.json`
- Create: `app/src/test/java/com/example/myapplication/core/feedback/WorkoutFeedbackTest.kt`
- Modify: `app/src/androidTest/java/com/example/myapplication/data/GymDatabaseMigrationTest.kt`

- [ ] **Step 1: Write the feedback contract test**

```kotlin
@Test
fun `rating score preserves easy right hard ordering`() {
    assertEquals(-1, WorkoutDifficulty.EASY.score)
    assertEquals(0, WorkoutDifficulty.RIGHT.score)
    assertEquals(1, WorkoutDifficulty.HARD.score)
}
```

- [ ] **Step 2: Run the focused test and verify it fails because the contract does not exist**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.feedback.WorkoutFeedbackTest"`

Expected: `FAILED` with unresolved `WorkoutDifficulty`.

- [ ] **Step 3: Add the domain contract**

```kotlin
enum class WorkoutDifficulty(val score: Int) {
    EASY(-1),
    RIGHT(0),
    HARD(1),
}

data class WorkoutFeedback(
    val sessionId: Long,
    val goalId: Long,
    val completedEpochDay: Long,
    val difficulty: WorkoutDifficulty,
    val recordedAtEpochMillis: Long,
)
```

- [ ] **Step 4: Add Room version 5 and an idempotent migration**

```sql
CREATE TABLE IF NOT EXISTS `workout_feedback` (
    `sessionId` INTEGER NOT NULL,
    `goalId` INTEGER NOT NULL,
    `completedEpochDay` INTEGER NOT NULL,
    `difficulty` TEXT NOT NULL,
    `recordedAtEpochMillis` INTEGER NOT NULL,
    PRIMARY KEY(`sessionId`),
    FOREIGN KEY(`sessionId`) REFERENCES `workout_sessions`(`id`) ON UPDATE NO ACTION ON DELETE CASCADE
)
```

Add `WorkoutFeedbackEntity::class`, `abstract fun workoutFeedbackDao()`, `MIGRATION_4_5`, and register the migration in `AppContainer`. The DAO exposes `observeForGoal(goalId)`, `feedbackForSessionNow(sessionId)`, and `upsert(entity)`.

- [ ] **Step 5: Add the focused repository contract**

```kotlin
interface WorkoutFeedbackRepository {
    fun observeForGoal(goalId: Long): Flow<List<WorkoutFeedback>>
    suspend fun save(
        sessionId: Long,
        goalId: Long,
        completedEpochDay: Long,
        difficulty: WorkoutDifficulty,
    )
}
```

`RoomWorkoutFeedbackRepository.save` rejects a session that is missing or incomplete and replaces an existing rating for the same completed session.

- [ ] **Step 6: Verify migration preservation and repository behavior**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.feedback.*"`

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Expected: both commands end with `BUILD SUCCESSFUL`; migration tests assert all pre-v5 row counts are unchanged and the new table is empty.

- [ ] **Step 7: Commit the bounded persistence change**

```powershell
git add app/src/main/java/com/example/myapplication/core/feedback app/src/main/java/com/example/myapplication/data app/src/main/java/com/example/myapplication/app/AppContainer.kt app/schemas app/src/test app/src/androidTest
git commit -m "feat: persist workout difficulty feedback"
```

### Task 2: Capture feedback after a completed workout

**Files:**
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayUiState.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayScreen.kt`
- Modify: `app/src/main/java/com/example/myapplication/app/GymApp.kt`
- Modify: `app/src/test/java/com/example/myapplication/feature/today/TodayViewModelTest.kt`
- Modify: `app/src/androidTest/java/com/example/myapplication/feature/today/TodayScreenTest.kt`

- [ ] **Step 1: Write failing ViewModel tests**

Cover these exact cases: completion exposes a pending feedback request with the completed session ID; choosing `EASY`, `RIGHT`, or `HARD` saves once; dismissing records nothing; a repository error keeps the sheet open and exposes a Vietnamese retry message.

```kotlin
viewModel.completeWorkout()
advanceUntilIdle()
viewModel.submitDifficulty(WorkoutDifficulty.HARD)
advanceUntilIdle()
assertEquals(WorkoutDifficulty.HARD, feedbackRepository.saved.single().difficulty)
```

- [ ] **Step 2: Run the tests and verify the new action is unresolved**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.today.TodayViewModelTest"`

Expected: `FAILED` because `submitDifficulty` and feedback state do not exist.

- [ ] **Step 3: Add immutable feedback UI state**

```kotlin
data class PendingWorkoutFeedback(
    val sessionId: Long,
    val goalId: Long,
    val completedEpochDay: Long,
    val saving: Boolean = false,
    val error: String? = null,
)
```

Keep this state in `TodayViewModel` separately from the next resolved workout so advancing the schedule does not lose the completed session ID.

- [ ] **Step 4: Add the existing-style feedback sheet**

The completion dialog receives three text actions: `Quá nhẹ`, `Vừa sức`, and `Quá nặng`, plus `Để sau`. Reuse current surfaces, colors, typography, spacing, and button components; do not introduce a new theme or route.

- [ ] **Step 5: Run focused ViewModel and Compose compilation checks**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.today.TodayViewModelTest"`

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Expected: `BUILD SUCCESSFUL` twice.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/feature/today app/src/main/java/com/example/myapplication/app/GymApp.kt app/src/test/java/com/example/myapplication/feature/today app/src/androidTest/java/com/example/myapplication/feature/today
git commit -m "feat: collect post-workout difficulty"
```

### Task 3: Add deterministic program phases

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/program/ProgramPhasePlanner.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/program/AdaptiveProgramPlanner.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/model/WorkoutModels.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayUiState.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayScreen.kt`
- Create: `app/src/test/java/com/example/myapplication/core/program/ProgramPhasePlannerTest.kt`
- Modify: `app/src/test/java/com/example/myapplication/core/program/AdaptiveProgramPlannerTest.kt`

- [ ] **Step 1: Write phase-boundary tests**

```kotlin
@Test
fun `eight week plan uses foundation build consolidate and deload phases`() {
    val phases = (1..8).map { ProgramPhasePlanner.phaseFor(it, 8) }
    assertEquals(
        listOf(FOUNDATION, FOUNDATION, BUILD, BUILD, BUILD, CONSOLIDATE, CONSOLIDATE, DELOAD),
        phases,
    )
}
```

Also cover 1–3 week plans, where the last week is `DELOAD` only when total duration is at least four weeks.

- [ ] **Step 2: Add the pure phase policy**

```kotlin
enum class ProgramPhase { FOUNDATION, BUILD, CONSOLIDATE, DELOAD }

object ProgramPhasePlanner {
    fun phaseFor(week: Int, durationWeeks: Int): ProgramPhase {
        require(week in 1..durationWeeks)
        if (durationWeeks >= 4 && week == durationWeeks) return ProgramPhase.DELOAD
        val progress = week.toDouble() / durationWeeks
        return when {
            progress <= 0.25 -> ProgramPhase.FOUNDATION
            progress <= 0.70 -> ProgramPhase.BUILD
            else -> ProgramPhase.CONSOLIDATE
        }
    }
}
```

- [ ] **Step 3: Apply bounded phase changes when snapshotting a new goal**

`AdaptiveProgramPlanner` keeps exercise order and reviewed prescriptions. `FOUNDATION` and `CONSOLIDATE` preserve the asset values, `BUILD` adds at most one set to prescriptions already containing two or more sets, and `DELOAD` uses `maxOf(1, floor(sets * 0.7).toInt())`. Duration prescriptions and rest seconds remain unchanged.

- [ ] **Step 4: Expose the inferred phase in Today without changing persistence**

Add `phase: ProgramPhase` to `TodayUiState.Workout`, inferred from `sequenceIndex`, `sessionsPerWeek`, and `durationWeeks`. Existing active goals receive a label immediately; only newly created goals receive phase-adjusted snapshot prescriptions, so completed and pending legacy rows are not silently rewritten during upgrade.

- [ ] **Step 5: Verify deterministic output**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.program.ProgramPhasePlannerTest" --tests "com.example.myapplication.core.program.AdaptiveProgramPlannerTest"`

Expected: identical inputs produce identical workout snapshots and `BUILD SUCCESSFUL`.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/core/program app/src/main/java/com/example/myapplication/core/model/WorkoutModels.kt app/src/main/java/com/example/myapplication/feature/today app/src/test/java/com/example/myapplication/core/program
git commit -m "feat: phase preset workout programs"
```

### Task 4: Detect deload need from feedback and recovery

**Files:**
- Modify: `app/src/main/java/com/example/myapplication/core/adaptation/AdaptationModels.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/adaptation/WeeklySnapshot.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/adaptation/AdaptationEngine.kt`
- Modify: `app/src/test/java/com/example/myapplication/core/adaptation/AdaptationEngineTest.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/recommendations/RecommendationScreen.kt`

- [ ] **Step 1: Write failing deload rule tests**

The engine proposes one `DELOAD_WEEK` only when either three of the latest four completed sessions are `HARD`, or two consecutive low-recovery check-ins coexist with at least two `HARD` ratings. It does not propose when fewer than three ratings exist, the current phase is already `DELOAD`, or a workout decision was created within seven days.

```kotlin
assertEquals(
    AdaptationKind.DELOAD_WEEK,
    engine.evaluate(snapshotWith(lastDifficulties = listOf(HARD, HARD, RIGHT, HARD))).single().kind,
)
```

- [ ] **Step 2: Extend the snapshot and decision kind**

```kotlin
data class WorkoutDifficultySample(
    val completedEpochDay: Long,
    val difficulty: WorkoutDifficulty,
)
```

Add `lastDifficulties: List<WorkoutDifficultySample>` and `currentProgramPhase: ProgramPhase` to `WeeklySnapshot`, plus `DELOAD_WEEK` to `AdaptationKind`. The decision mode is always `REQUIRES_CONFIRMATION`.

- [ ] **Step 3: Emit an auditable payload**

```json
{"pendingSessions":3,"volumeScalePercent":70}
```

The before and undo payloads use `volumeScalePercent:100`. The Vietnamese reason states which threshold fired and never claims injury diagnosis.

- [ ] **Step 4: Update recommendation labels and exhaustive `when` branches**

Map `DELOAD_WEEK` to `Tuần giảm tải`; do not auto-accept or hide the reason.

- [ ] **Step 5: Run the engine and recommendation tests**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.adaptation.AdaptationEngineTest" --tests "com.example.myapplication.feature.recommendations.RecommendationViewModelTest"`

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/core/adaptation app/src/main/java/com/example/myapplication/feature/recommendations app/src/test/java/com/example/myapplication/core/adaptation app/src/test/java/com/example/myapplication/feature/recommendations
git commit -m "feat: detect deload recommendations"
```

### Task 5: Apply and undo a confirmed deload atomically

**Files:**
- Modify: `app/src/main/java/com/example/myapplication/data/local/WorkoutSessionEntity.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/WorkoutDao.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/GymDatabase.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/RoomAdaptationRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/RoomWorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/app/AppContainer.kt`
- Create: `app/schemas/com.example.myapplication.data.local.GymDatabase/6.json`
- Modify: `app/src/androidTest/java/com/example/myapplication/data/GymDatabaseMigrationTest.kt`
- Modify: `app/src/androidTest/java/com/example/myapplication/data/RoomAdaptationRepositoryTest.kt`

- [ ] **Step 1: Add failing atomicity tests**

Verify accepting a deload sets `volumeScalePercent = 70` on at most the next `sessionsPerWeek` incomplete sessions, leaves completed sessions unchanged, records `APPLIED` in the same transaction, and undo restores exactly those rows to `100`. A stale decision changes nothing.

- [ ] **Step 2: Add Room migration 5→6**

```sql
ALTER TABLE `workout_sessions`
ADD COLUMN `volumeScalePercent` INTEGER NOT NULL DEFAULT 100
```

Register `MIGRATION_5_6` and assert every existing row receives `100`.

- [ ] **Step 3: Apply scale at the domain mapping boundary**

```kotlin
private fun scaledSets(sets: Int, percent: Int): Int =
    maxOf(1, kotlin.math.floor(sets * percent / 100.0).toInt())
```

Room retains original exercise prescriptions. `RoomWorkoutRepository` returns scaled sets only when mapping an incomplete session, which makes undo lossless.

- [ ] **Step 4: Add DAO mutations with explicit session IDs**

The repository resolves the exact upcoming session IDs before mutation, validates that every row is still incomplete and belongs to the active goal, then updates the scale and decision status in one `database.withTransaction` block.

- [ ] **Step 5: Run migration and repository compilation**

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.adaptation.*"`

Expected: `BUILD SUCCESSFUL` twice.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/data app/src/main/java/com/example/myapplication/app/AppContainer.kt app/schemas app/src/androidTest app/src/test
git commit -m "feat: apply confirmed deload weeks"
```

---

## Phase 2 — Session flexibility

### Task 6: Rank reviewed exercise substitutions

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/catalog/ExerciseSubstitutionEngine.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/catalog/CatalogValidator.kt`
- Modify: `app/src/main/assets/catalog/exercises_vi.json`
- Create: `app/src/test/java/com/example/myapplication/core/catalog/ExerciseSubstitutionEngineTest.kt`
- Modify: `app/src/test/java/com/example/myapplication/core/catalog/CatalogValidatorTest.kt`

- [ ] **Step 1: Write failing ranking and validation tests**

Require every reviewed exercise to have zero or more explicit `substituteIds`; reject missing IDs, self references, duplicate IDs, incompatible primary muscles, and incompatible movement patterns. Ranking prefers the user's equipment profile and equal experience level, then sorts by Vietnamese name for stable output.

```kotlin
assertEquals(
    listOf("incline_push_up", "dumbbell_floor_press"),
    engine.candidates("push_up", DUMBBELLS).map { it.id },
)
```

- [ ] **Step 2: Extend the catalog model**

```kotlin
@Serializable
data class ExerciseDefinition(
    // existing fields remain unchanged
    val substituteIds: List<String> = emptyList(),
)
```

- [ ] **Step 3: Implement deterministic candidate filtering**

```kotlin
class ExerciseSubstitutionEngine(exercises: List<ExerciseDefinition>) {
    private val byId = exercises.associateBy { it.id }

    fun candidates(exerciseId: String, profile: EquipmentProfile): List<ExerciseDefinition> {
        val source = byId[exerciseId] ?: return emptyList()
        return source.substituteIds.mapNotNull(byId::get)
            .filter { it.primaryMuscle == source.primaryMuscle }
            .filter { it.movementPattern == source.movementPattern }
            .filter { it.supports(profile) }
            .sortedWith(compareBy<ExerciseDefinition> { it.level != source.level }.thenBy { it.nameVi })
    }
}
```

Define `supports(profile)` in the same file with explicit allowed equipment sets for all four `EquipmentProfile` values.

- [ ] **Step 4: Add reviewed reciprocal substitutions to the asset**

Only connect exercises already present in `exercises_vi.json`. Every relationship receives a manual review in `docs/data/program-review-checklist.md`; do not infer or write IDs at runtime.

- [ ] **Step 5: Run catalog tests**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.catalog.*"`

Expected: schema, cross-reference, compatibility, and determinism tests pass.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/core/catalog app/src/main/java/com/example/myapplication/core/model/CatalogModels.kt app/src/main/assets/catalog/exercises_vi.json app/src/test/java/com/example/myapplication/core/catalog docs/data/program-review-checklist.md
git commit -m "feat: define reviewed exercise substitutions"
```

### Task 7: Persist and expose an exercise substitution

**Files:**
- Modify: `app/src/main/java/com/example/myapplication/data/local/SessionExerciseEntity.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/WorkoutDao.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/GymDatabase.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/WorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/RoomWorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/model/WorkoutModels.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayUiState.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/ExerciseCard.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayScreen.kt`
- Modify: `app/src/main/java/com/example/myapplication/app/GymApp.kt`
- Create: `app/schemas/com.example.myapplication.data.local.GymDatabase/7.json`
- Modify: `app/src/androidTest/java/com/example/myapplication/data/GymDatabaseMigrationTest.kt`
- Modify: `app/src/androidTest/java/com/example/myapplication/data/RoomWorkoutRepositoryTest.kt`
- Modify: `app/src/test/java/com/example/myapplication/feature/today/TodayViewModelTest.kt`

- [ ] **Step 1: Write failing repository guards**

Replacement succeeds only for the current incomplete session, an unchecked row, and a candidate returned by `ExerciseSubstitutionEngine`. It preserves sets/reps/duration/rest/order, stores the first original ID, and allows restoring that original ID. Invalid, stale, checked, or completed mutations change zero rows.

- [ ] **Step 2: Add migration 6→7**

```sql
ALTER TABLE `session_exercises`
ADD COLUMN `originalExerciseId` TEXT
```

- [ ] **Step 3: Extend the repository contract**

```kotlin
suspend fun substituteExercise(
    sessionId: Long,
    orderIndex: Int,
    replacementExerciseId: String,
): ExerciseSubstitutionResult

sealed interface ExerciseSubstitutionResult {
    data object Applied : ExerciseSubstitutionResult
    data object InvalidCandidate : ExerciseSubstitutionResult
    data object StaleSession : ExerciseSubstitutionResult
    data object AlreadyChecked : ExerciseSubstitutionResult
}
```

- [ ] **Step 4: Add Today actions without a new destination**

An unchecked `ExerciseCard` exposes `Thay bài`. A modal lists at most three reviewed candidates with equipment and instructions. On success the existing list updates from Room. When there is no valid candidate, display `Không có bài thay thế phù hợp với thiết bị hiện tại.`

- [ ] **Step 5: Run repository, ViewModel, and Compose compilation tests**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.today.TodayViewModelTest"`

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Expected: `BUILD SUCCESSFUL` twice.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication app/schemas app/src/test app/src/androidTest
git commit -m "feat: replace current workout exercises"
```

### Task 8: Apply a shorter time budget without losing the original workout

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/program/SessionTimeBudgetPlanner.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/SessionExerciseEntity.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/WorkoutSessionEntity.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/WorkoutDao.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/GymDatabase.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/WorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/RoomWorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayUiState.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayScreen.kt`
- Create: `app/schemas/com.example.myapplication.data.local.GymDatabase/8.json`
- Create: `app/src/test/java/com/example/myapplication/core/program/SessionTimeBudgetPlannerTest.kt`
- Modify: `app/src/androidTest/java/com/example/myapplication/data/RoomWorkoutRepositoryTest.kt`

- [ ] **Step 1: Write failing planner tests**

Budgets are `15`, `30`, `45`, or the original duration. The planner always keeps the first compound exercise, preserves order, never reorders or randomly samples, and monotonically adds rows as the budget grows.

```kotlin
assertTrue(planner.select(exercises, 15).activeOrderIndices.isNotEmpty())
assertTrue(
    planner.select(exercises, 15).activeOrderIndices
        .all { it in planner.select(exercises, 30).activeOrderIndices },
)
```

- [ ] **Step 2: Add migration 7→8**

```sql
ALTER TABLE `session_exercises`
ADD COLUMN `omittedByTimeBudget` INTEGER NOT NULL DEFAULT 0;
ALTER TABLE `workout_sessions`
ADD COLUMN `selectedTimeBudgetMinutes` INTEGER;
```

- [ ] **Step 3: Implement the pure estimate and selection policy**

Use the same estimate formula as `AdaptiveProgramPlanner`: active seconds are duration or `sets * repsMidpoint * 4`, plus rest between sets. Keep the largest ordered prefix within the selected budget and at least one exercise.

- [ ] **Step 4: Apply the variant atomically**

```kotlin
suspend fun applyTimeBudget(sessionId: Long, minutes: Int?): TimeBudgetResult
```

The transaction rejects completed sessions and sessions with any checked exercise, sets the selected budget, and marks excluded rows. Passing `null` restores every row. `countUnchecked` and completion validation count only `omittedByTimeBudget = 0`.

- [ ] **Step 5: Add Today selection and omission summary**

Before the first check, show `15 phút`, `30 phút`, `45 phút`, and `Đầy đủ`. After any exercise is checked, lock the choice. Omitted rows are summarized as `N bài phụ được lược bớt` and are not presented as completed.

- [ ] **Step 6: Verify completion safety**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.program.SessionTimeBudgetPlannerTest" --tests "com.example.myapplication.feature.today.TodayViewModelTest"`

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Expected: completion remains blocked when any active row is unchecked and succeeds when all active rows are checked.

- [ ] **Step 7: Commit**

```powershell
git add app/src/main/java/com/example/myapplication app/schemas app/src/test app/src/androidTest
git commit -m "feat: support shorter workout variants"
```

### Task 9: Add reviewed warm-up and cool-down blocks

**Files:**
- Create: `app/src/main/assets/catalog/movement_blocks_vi.json`
- Create: `app/src/main/java/com/example/myapplication/core/model/MovementBlockModels.kt`
- Create: `app/src/main/java/com/example/myapplication/core/catalog/MovementBlockPlanner.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/catalog/AssetCatalogRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/catalog/CatalogValidator.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayUiState.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/today/TodayScreen.kt`
- Create: `app/src/test/java/com/example/myapplication/core/catalog/MovementBlockPlannerTest.kt`
- Modify: `app/src/androidTest/java/com/example/myapplication/core/catalog/AssetCatalogRepositoryTest.kt`

- [ ] **Step 1: Define and test the asset contract**

```kotlin
@Serializable
data class MovementBlock(
    val id: String,
    val kind: MovementBlockKind,
    val movementPatterns: Set<MovementPattern>,
    val titleVi: String,
    val stepsVi: List<String>,
    val estimatedMinutes: Int,
)

enum class MovementBlockKind { WARM_UP, COOL_DOWN }
```

Validation requires stable unique IDs, Vietnamese title, 2–6 nonblank steps, 2–10 minutes, and at least one supported movement pattern.

- [ ] **Step 2: Add reviewed content**

Create blocks for squat/lunge, hinge, push, pull, locomotion/cardio, core, and mobility. Copy must describe general preparation or cool-down only and must not prescribe injury rehabilitation.

- [ ] **Step 3: Implement deterministic selection**

Select the block with the greatest count of distinct active workout movement patterns; break ties by block ID. An empty workout returns the general mobility block.

- [ ] **Step 4: Expose collapsible sections in Today**

Show warm-up before active exercises and cool-down after them. These steps are advisory and do not participate in exercise-check or session-completion rules.

- [ ] **Step 5: Run asset and planner tests**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.catalog.MovementBlockPlannerTest"`

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Expected: `BUILD SUCCESSFUL` twice.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/assets/catalog app/src/main/java/com/example/myapplication/core app/src/main/java/com/example/myapplication/feature/today app/src/test app/src/androidTest
git commit -m "feat: add workout preparation blocks"
```

### Task 10: Preview and confirm schedule changes

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/program/ScheduleRescheduler.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/WorkoutDao.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/WorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/RoomWorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/settings/SettingsUiState.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/settings/SettingsViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/settings/SettingsScreen.kt`
- Create: `app/src/test/java/com/example/myapplication/core/program/ScheduleReschedulerTest.kt`
- Modify: `app/src/test/java/com/example/myapplication/feature/settings/SettingsViewModelTest.kt`
- Modify: `app/src/androidTest/java/com/example/myapplication/feature/settings/SettingsScreenTest.kt`

- [ ] **Step 1: Write pure preview tests**

Cover moving the current pending session earlier, later, over a week boundary, onto an unselected weekday, and onto a date that would create consecutive demanding sessions. The preview preserves sequence order and never changes completed rows.

```kotlin
data class ScheduleChangePreview(
    val changes: List<SessionDateChange>,
    val warningsVi: List<String>,
)

data class SessionDateChange(
    val sessionId: Long,
    val oldEpochDay: Long,
    val newEpochDay: Long,
)
```

- [ ] **Step 2: Implement preview without persistence**

`ScheduleRescheduler.preview` anchors the selected session on the requested date, then places later sessions on the next selected training weekdays. Warn, but do not block, when the selected date is not a normal training weekday. Reject dates earlier than today and date arithmetic overflow.

- [ ] **Step 3: Add repository preview and apply methods**

```kotlin
suspend fun previewScheduleChange(sessionId: Long, newEpochDay: Long): ScheduleChangePreview
suspend fun applyScheduleChange(preview: ScheduleChangePreview): ScheduleChangeResult
```

`applyScheduleChange` re-reads every old due date and aborts as stale if one differs. Otherwise it updates all preview rows in one Room transaction.

- [ ] **Step 4: Add Settings flow**

Add `Điều chỉnh lịch sắp tới` under current workout settings. The user selects a date, reviews old→new dates and warnings, then confirms. Closing the dialog or navigating back performs no writes.

- [ ] **Step 5: Verify core and ViewModel behavior**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.program.ScheduleReschedulerTest" --tests "com.example.myapplication.feature.settings.SettingsViewModelTest"`

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Expected: `BUILD SUCCESSFUL` twice.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/core/program app/src/main/java/com/example/myapplication/data app/src/main/java/com/example/myapplication/feature/settings app/src/test app/src/androidTest
git commit -m "feat: preview workout schedule changes"
```

---

## Phase 3 — Progress intelligence

### Task 11: Generate deterministic weekly conclusions

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/progress/WeeklyInsightEngine.kt`
- Modify: `app/src/main/java/com/example/myapplication/core/model/WorkoutModels.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/WorkoutDao.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/WorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/RoomWorkoutRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/progress/ProgressUiState.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/progress/ProgressViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/progress/ProgressScreen.kt`
- Create: `app/src/test/java/com/example/myapplication/core/progress/WeeklyInsightEngineTest.kt`
- Modify: `app/src/test/java/com/example/myapplication/feature/progress/ProgressViewModelTest.kt`

- [ ] **Step 1: Add a history contract that distinguishes due and completed dates**

```kotlin
data class WorkoutHistoryEntry(
    val sessionId: Long,
    val goalId: Long,
    val sequenceIndex: Int,
    val dueEpochDay: Long,
    val completedEpochDay: Long?,
    val estimatedMinutes: Int,
)
```

Expose `observeWorkoutHistory()` from `WorkoutRepository`. The DAO query includes completed and pending rows without mutating them.

- [ ] **Step 2: Write insight priority tests**

The engine considers the last four complete weeks and returns at most three non-duplicated conclusions in this priority: adherence change, most reliable weekday, difficulty trend, time-budget usage, and schedule drift. Fewer than two weeks of evidence returns an empty list instead of guessing.

```kotlin
sealed interface WeeklyInsight {
    val messageVi: String
    data class AdherenceTrend(override val messageVi: String) : WeeklyInsight
    data class ReliableWeekday(override val messageVi: String) : WeeklyInsight
    data class DifficultyTrend(override val messageVi: String) : WeeklyInsight
    data class TimeBudgetPattern(override val messageVi: String) : WeeklyInsight
    data class ScheduleDrift(override val messageVi: String) : WeeklyInsight
}
```

- [ ] **Step 3: Implement deterministic evidence thresholds**

Require at least four comparable sessions for difficulty or time-budget claims, at least three scheduled occurrences for a weekday claim, and a difference of at least 15 percentage points for adherence trend. Include the supporting count in every message.

- [ ] **Step 4: Add insights to existing Progress content**

`ProgressViewModel` combines active goal, workout history, and feedback. `ProgressScreen` adds a `Nhận xét tuần` section below current summary cards. No network or AI explanation is involved.

- [ ] **Step 5: Run focused tests**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.progress.WeeklyInsightEngineTest" --tests "com.example.myapplication.feature.progress.ProgressViewModelTest"`

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/core/progress app/src/main/java/com/example/myapplication/core/model/WorkoutModels.kt app/src/main/java/com/example/myapplication/data app/src/main/java/com/example/myapplication/feature/progress app/src/test
git commit -m "feat: explain weekly workout patterns"
```

### Task 12: Forecast goal completion transparently

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/progress/GoalForecastCalculator.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/progress/ProgressUiState.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/progress/ProgressViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/progress/ProgressScreen.kt`
- Create: `app/src/test/java/com/example/myapplication/core/progress/GoalForecastCalculatorTest.kt`
- Modify: `app/src/test/java/com/example/myapplication/feature/progress/ProgressViewModelTest.kt`

- [ ] **Step 1: Write forecast boundary tests**

Cover no completed sessions, less than two elapsed weeks, on-track, at-risk, past the planned end, 100% completion, zero/invalid totals, and `Long` date overflow.

```kotlin
sealed interface GoalForecast {
    data object InsufficientData : GoalForecast
    data class OnTrack(val projectedEpochDay: Long) : GoalForecast
    data class AtRisk(val projectedEpochDay: Long, val sessionsBehind: Int) : GoalForecast
    data object Complete : GoalForecast
}
```

- [ ] **Step 2: Implement a conservative local forecast**

Use completed sessions divided by elapsed full weeks, capped at the configured sessions per week. Require two elapsed weeks and at least two completions. Project remaining sessions from that rate. Mark `AtRisk` when the projection exceeds the planned final due date by more than seven days.

- [ ] **Step 3: Present inputs with the result**

The Progress card shows status, projected completion date, and `Dựa trên X buổi trong Y tuần`. It states that this is a schedule estimate, not a body-weight, medical, or physique prediction.

- [ ] **Step 4: Run focused tests**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.progress.GoalForecastCalculatorTest" --tests "com.example.myapplication.feature.progress.ProgressViewModelTest"`

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 5: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/core/progress app/src/main/java/com/example/myapplication/feature/progress app/src/test/java/com/example/myapplication
git commit -m "feat: forecast workout goal completion"
```

---

## Phase 4 — Nutrition reuse

### Task 13: Persist local meal templates

**Files:**
- Create: `app/src/main/java/com/example/myapplication/core/nutrition/MealTemplate.kt`
- Create: `app/src/main/java/com/example/myapplication/data/local/MealTemplateEntity.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/PersonalizationDao.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/local/GymDatabase.kt`
- Modify: `app/src/main/java/com/example/myapplication/data/NutritionRepository.kt`
- Modify: `app/src/main/java/com/example/myapplication/app/AppContainer.kt`
- Create: `app/schemas/com.example.myapplication.data.local.GymDatabase/9.json`
- Modify: `app/src/test/java/com/example/myapplication/data/NutritionRepositoryTest.kt`
- Modify: `app/src/androidTest/java/com/example/myapplication/data/GymDatabaseMigrationTest.kt`

- [ ] **Step 1: Write validation and repository tests**

Names are trimmed, 1–60 characters, and compared case-insensitively for uniqueness. Nutrients are non-negative and calories are greater than zero. Saving the same ID updates; applying a template adds exactly one nutrient total to the selected day; deleting never changes historical daily totals.

```kotlin
data class MealTemplate(
    val id: Long,
    val nameVi: String,
    val nutrients: Nutrients,
    val updatedAtEpochMillis: Long,
)
```

- [ ] **Step 2: Add migration 8→9**

```sql
CREATE TABLE IF NOT EXISTS `meal_templates` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    `nameVi` TEXT NOT NULL COLLATE NOCASE,
    `calories` INTEGER NOT NULL,
    `proteinGrams` INTEGER NOT NULL,
    `carbsGrams` INTEGER NOT NULL,
    `fatGrams` INTEGER NOT NULL,
    `updatedAtEpochMillis` INTEGER NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS `index_meal_templates_nameVi`
ON `meal_templates` (`nameVi`);
```

- [ ] **Step 3: Extend `NutritionRepository`**

```kotlin
fun observeMealTemplates(): Flow<List<MealTemplate>>
suspend fun saveMealTemplate(id: Long?, nameVi: String, nutrients: Nutrients): Long
suspend fun deleteMealTemplate(id: Long)
suspend fun applyMealTemplate(id: Long, epochDay: Long)
```

`applyMealTemplate` reads the template and upserts the daily total in one Room transaction using `EntrySource.TEMPLATE`.

- [ ] **Step 4: Verify migration preservation**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.data.NutritionRepositoryTest"`

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Expected: v8 data remains unchanged, the template table starts empty, and both commands succeed.

- [ ] **Step 5: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/core/nutrition app/src/main/java/com/example/myapplication/data app/src/main/java/com/example/myapplication/app/AppContainer.kt app/schemas app/src/test app/src/androidTest
git commit -m "feat: persist reusable meal templates"
```

### Task 14: Edit nutrition drafts and reuse meal templates

**Files:**
- Modify: `app/src/main/java/com/example/myapplication/core/nutrition/NutritionDay.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/nutrition/NutritionViewModel.kt`
- Modify: `app/src/main/java/com/example/myapplication/feature/nutrition/NutritionScreen.kt`
- Modify: `app/src/main/java/com/example/myapplication/app/GymApp.kt`
- Modify: `app/src/test/java/com/example/myapplication/feature/nutrition/NutritionViewModelTest.kt`
- Create: `app/src/androidTest/java/com/example/myapplication/feature/nutrition/NutritionScreenTest.kt`

- [ ] **Step 1: Write failing draft tests**

Cover converting a scan result into an editable draft, changing each numeric field, locale-safe integer parsing, rejecting blank name/negative nutrients/zero calories, accepting without saving, accepting and saving as template, applying a template once, and deleting only after confirmation.

```kotlin
data class EditableNutritionDraft(
    val nameVi: String,
    val caloriesText: String,
    val proteinText: String,
    val carbsText: String,
    val fatText: String,
    val saveAsTemplate: Boolean = false,
    val errors: Map<String, String> = emptyMap(),
)
```

- [ ] **Step 2: Separate scan transport data from editable state**

`scanFood` still requires explicit cloud-AI consent and configured backend. A successful result populates `EditableNutritionDraft`; edits and templates are local. `acceptDraft` parses and validates once, then calls `addNutrients`; when selected, it calls `saveMealTemplate` after nutrients are successfully recorded.

- [ ] **Step 3: Add manual entry and template actions to the current Nutrition screen**

Use the current card and dialog styles. Add `Nhập thủ công`, an editable scan-result dialog, and a `Bữa ăn đã lưu` list with `Thêm`, `Sửa tên`, and confirmed `Xóa`. No new bottom-navigation item is created.

- [ ] **Step 4: Prevent duplicate submissions**

Use a `savingDraft` flag; disable actions until the repository call completes. On failure keep the draft and show a Vietnamese error. On success clear only the draft, not the day's history.

- [ ] **Step 5: Run ViewModel and Compose checks**

Run: `./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.feature.nutrition.NutritionViewModelTest"`

Run: `./gradlew.bat compileDebugAndroidTestKotlin`

Expected: `BUILD SUCCESSFUL` twice.

- [ ] **Step 6: Commit**

```powershell
git add app/src/main/java/com/example/myapplication/core/nutrition app/src/main/java/com/example/myapplication/feature/nutrition app/src/main/java/com/example/myapplication/app/GymApp.kt app/src/test app/src/androidTest
git commit -m "feat: edit and reuse nutrition entries"
```

---

## Release verification

### Task 15: Verify all upgrades and update product documentation

**Files:**
- Modify: `docs/verification/adaptive-personalization-checklist.md`
- Modify: `docs/verification/manual-android-checklist.md`
- Modify: `walkthrough.md`
- Modify: `docs/data/program-review-checklist.md`

- [ ] **Step 1: Run each phase's focused JVM suite**

```powershell
./gradlew.bat testDebugUnitTest --tests "com.example.myapplication.core.feedback.*" --tests "com.example.myapplication.core.program.*" --tests "com.example.myapplication.core.catalog.*" --tests "com.example.myapplication.core.progress.*" --tests "com.example.myapplication.feature.today.*" --tests "com.example.myapplication.feature.progress.*" --tests "com.example.myapplication.feature.nutrition.*"
```

Expected: `BUILD SUCCESSFUL` with no failed tests.

- [ ] **Step 2: Run the full local suite and builds**

```powershell
./gradlew.bat test
./gradlew.bat lintDebug
./gradlew.bat compileDebugAndroidTestKotlin
./gradlew.bat assembleDebug
```

Expected: all four commands end with `BUILD SUCCESSFUL`.

- [ ] **Step 3: Run migration and Compose tests on an online device**

Resolve the SDK path from `local.properties` when `adb` is not on `PATH`, then run:

```powershell
./gradlew.bat connectedDebugAndroidTest
```

Expected: migration tests cover versions `1→9`, the onboarding-to-completion flow passes, and all device tests report zero failures. If no device is online, record this check as pending and do not claim connected verification.

- [ ] **Step 4: Perform the manual safety matrix**

Verify airplane-mode behavior for all features; process-death recovery during time-budget and substitution changes; rotation during every dialog; completed-history preservation; stale schedule-preview rejection; deload accept/undo; duplicate feedback prevention; meal-template validation; dark/light theme readability; and one-handed touch targets.

- [ ] **Step 5: Update documentation with observed behavior**

Document exact thresholds, migration versions, offline behavior, user confirmation points, and known limits. Record that warm-up/cool-down content is general fitness guidance and that the forecast predicts schedule completion only.

- [ ] **Step 6: Check repository hygiene**

```powershell
git diff --check
git status --short
```

Expected: no whitespace errors; no `build/`, `.gradle/`, secrets, machine-local configuration, or `local.properties` is staged.

- [ ] **Step 7: Commit verification documentation**

```powershell
git add docs/verification docs/data/program-review-checklist.md walkthrough.md
git commit -m "docs: verify functional upgrade release"
```

## Execution checkpoints

Stop after Tasks 5, 10, 12, and 14 to run the full applicable test suite and inspect `git diff --stat`. Do not start the next phase while the previous phase has failing tests, an unverified migration, or unrelated working-tree changes. Preserve one bounded task per commit so an individual upgrade can be reverted without losing later completed history or schema guarantees.
