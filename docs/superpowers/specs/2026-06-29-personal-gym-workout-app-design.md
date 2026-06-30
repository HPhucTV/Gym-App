# Personal Gym Workout App Design

Date: 2026-06-29
Status: Approved in conversation; awaiting review of this written specification

## 1. Product summary

The product is a single-user Android app that assigns a sensible workout each day from a preset program. The user chooses a fitness goal and commitment, follows the displayed workout, checks each exercise, and marks the session complete. The app works fully offline and stores all progress on the device.

The first release deliberately excludes accounts, backend services, cloud sync, AI, body weight or measurements, nutrition, calorie tracking, and set-by-set performance logging.

## 2. Success criteria

The release succeeds when a user can:

1. Create a goal by selecting a fitness direction, experience level, available equipment, sessions per week, duration, and rest-day preference.
2. Receive a reviewed 4-8 week preset program that matches those choices.
3. Open the app and immediately understand today's workout or recovery task.
4. See exercise name, sets, repetitions or duration, rest time, and concise technique guidance.
5. Check each exercise and complete the session only after every exercise is checked.
6. Return after a missed day and continue the same pending workout without losing program order.
7. Review completed sessions, a monthly calendar, goal progress, and a weekly consistency streak.

## 3. Goals and program model

A goal combines:

- fitness direction: muscle gain, fat-loss-oriented conditioning, endurance, or general fitness
- experience level: beginner or intermediate in the first release
- available equipment: bodyweight, dumbbells, resistance bands, or a supported gym set
- weekly commitment: 2-5 sessions per week, restricted to combinations for which a reviewed program exists
- program duration: 4-8 weeks, as defined by the selected template
- rest-day behavior: full recovery or a light mobility/walking task

Programs are curated templates, not random exercise collections. Each template contains an ordered sequence of workout and recovery sessions. A missed workout remains current; subsequent due dates move forward. The template maintains its internal recovery spacing and never silently drops a workout.

## 4. Exercise dataset and curation

Use [Free Exercise DB](https://github.com/yuhonas/free-exercise-db) as the starting source. It provides more than 800 public-domain/Unlicense exercises in JSON with fields such as difficulty, equipment, primary and secondary muscles, instructions, and images.

Do not import all records. Some source fields are incomplete and a very large catalog would not improve this preset-program product. Create a reviewed subset of approximately 60-100 common exercises, then:

- retain source IDs or document a stable ID mapping
- translate names and concise instructions into Vietnamese
- normalize equipment and muscle values
- add movement pattern and app-specific display metadata
- verify every exercise used by a program
- record source URL, retrieval date, and Unlicense provenance with the imported assets

The dataset supplies exercise content only. Program design remains a separate, reviewed artifact. General program checks should cover all major muscle groups, include recovery, and avoid loading the same primary muscle on consecutive training days when the earlier workout has `restDaysAfter == 0`. Workouts separated by one or more declared recovery days are not consecutive training days for this rule. Programs should follow conservative public guidance such as the [CDC adult activity guidance](https://www.cdc.gov/physical-activity-basics/guidelines/adults.html) and [American Heart Association strength guidance](https://www.heart.org/en/healthy-living/exercise-and-physical-activity/fitness-basics/strength-and-resistance-training-exercise).

This app provides general fitness planning and is not medical advice or an injury-rehabilitation tool.

## 5. User experience

### First launch and goal creation

The first launch opens a short setup flow. Each step asks for one decision and explains how it affects the program. The final review screen shows the selected goal, schedule, equipment, and program length before creation.

If there is no exact reviewed program for the configuration, the app explains which choice must change. It does not generate or substitute a random program.

### Today

Today is the default destination. It shows either:

- the current workout, its focus, estimated duration, exercise checklist, and overall completion action; or
- a recovery day with either a rest message or the selected light activity.

Expanding an exercise reveals concise technique instructions. The primary action remains disabled until all workout exercises are checked. Completing a session records one atomic history event and advances the program.

### Missed workout

Program advancement depends on session completion, not merely the calendar date. If a workout is not completed, the same session remains current the next day and the remaining schedule shifts forward. Completed history is never rewritten.

### Progress

Progress shows:

- completed sessions over total goal sessions
- percentage and progress bar or ring
- monthly calendar with completed dates
- current weekly consistency streak

The streak measures consecutive weeks that meet the goal's weekly session target. It does not require training every day.

### Settings

Settings exposes reminder time, rest-day behavior, and goal replacement. Replacing or deleting an active goal requires confirmation. Completed history remains visible after replacement.

### Navigation

Use three bottom navigation destinations: Today, Progress, and Settings. Goal creation is a first-run flow and a controlled action from Settings, not a permanent fourth destination.

## 6. Visual design

The interface is clean, energetic, and adult rather than heavily gamified.

- dominant background: white `#FFFFFF`
- primary text: dark navy `#14213D`
- completion and progress: green `#22C55E`
- primary actions and active workout accents: orange `#F97316`
- supporting surfaces: light gray `#F3F4F6`
- no gradients
- moderate corner radii, thin borders, and restrained shadows
- bold headings, large progress values, and one-handed touch targets
- accessible contrast and meaning that does not depend on color alone

Use Material 3 components where they fit, but theme them consistently instead of accepting visually inconsistent defaults.

## 7. Technical architecture

Retain the existing Kotlin and Jetpack Compose Android project. The first release has no server and requests no network access for core behavior.

Use one application module with feature-oriented packages. Keep responsibilities separated into:

- onboarding and goal creation
- program catalog and deterministic selection
- today's session and completion
- progress and history calculations
- settings and goal replacement
- local persistence and bundled asset loading

Use screen-level ViewModels exposing immutable UI state. Keep business rules out of Composables. Prefer focused interfaces and concrete implementations over a generic framework or multiple Gradle modules.

### Bundled content

- `exercises_vi.json`: curated and translated exercise catalog
- `programs.json`: reviewed program templates and exercise references

Both files are versioned application assets and validated by automated tests.

### Persistence

Use Room for structured state:

- active and archived goals
- instantiated ordered sessions
- per-exercise check state for the current session
- completed session history

Use DataStore only for small preferences such as reminder time and rest-day behavior. Store exercise checks and session completion transactionally.

### Data flow

1. Goal creation requests an exact template from the program catalog.
2. The selected template is instantiated into ordered local sessions.
3. The Today feature loads the first incomplete session.
4. Exercise ticks update the current local session.
5. Completing all exercises records completion and unlocks the next ordered session.
6. Progress derives from completed history and the active goal target.

## 8. Error handling and data integrity

- Reject missing or malformed bundled data during automated validation.
- Reject duplicate IDs, unknown exercise references, invalid set/rep/rest values, and unsupported program combinations.
- Show a useful no-match state when a reviewed template is unavailable.
- Keep a workout pending after an interruption or missed date.
- Make completion idempotent so repeated taps cannot create duplicate history.
- Confirm goal replacement or deletion and preserve completed history.
- Base ordering on program sequence so timezone or device clock changes cannot skip sessions.
- If local persistence fails, keep the screen recoverable, report that progress was not saved, and allow retry.

Local-only storage is an accepted first-release limitation. Uninstalling or clearing app data removes history.

## 9. Testing strategy

### Unit tests

- exact program selection and unsupported combinations
- session instantiation and ordered advancement
- missed-workout carry-forward
- recovery-session placement
- all-exercises-required completion rule
- idempotent session completion
- progress percentage and total counts
- monthly completion mapping
- weekly consistency streak
- goal replacement with retained history

### Data validation tests

- JSON decoding
- stable unique IDs
- required fields and valid numeric ranges
- all program exercise references resolve
- supported goal/level/equipment/frequency combinations are explicit
- no template violates its declared weekly frequency or recovery structure

### UI and integration tests

- first launch through goal creation
- unsupported configuration feedback
- Today checklist and completion gating
- completed session reflected in Progress
- missed session still shown after the date changes
- goal replacement confirmation and retained history
- screen behavior on supported small and large Android layouts

## 10. Explicit non-goals

The first release does not include:

- user accounts or multiple profiles
- backend or cloud synchronization
- AI chat or AI-generated programs
- random workout generation
- weight, body measurement, or photo tracking
- nutrition, calorie, or water tracking
- manual weight, repetitions, or perceived-effort logs
- social features, leaderboards, subscriptions, or payments
- rehabilitation or medical exercise prescriptions

## 11. Delivery constraints

- Preserve the existing Android project and Gradle setup where practical.
- Use a white-first palette and never introduce gradients.
- Keep the main user journey usable offline after installation.
- Prefer the smallest implementation that satisfies this specification.
- Treat dataset curation and program review as first-class delivery tasks, not incidental seed-data work.
