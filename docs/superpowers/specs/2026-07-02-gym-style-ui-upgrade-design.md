# Gym-style UI Upgrade Design

## 1. Direction

The approved direction is a strong, disciplined gym aesthetic: bold typography, sturdy information cards, clear progress, and high-contrast actions. It should feel like modern training equipment and gym signage without becoming a dark, aggressive, or game-like interface.

Visual reference: [`docs/design/gym-style-concept.png`](../../design/gym-style-concept.png).

This design applies to the current expanded application, including workout, exercise catalog, progress, nutrition, AI Coach, and settings. It does not remove or redesign the underlying features described in `docs/backend-nutrition-integration.md`.

## 2. Visual principles

- White remains the dominant canvas so long workout lists stay readable.
- Dark navy creates structure through headings, rules, icons, and selected surfaces.
- Orange identifies the primary action and the active destination.
- Green communicates completion together with a check icon or label.
- No gradients, neon effects, photographic gym backgrounds, or excessive shadows.
- Use industrial details sparingly: thin rules, clipped corners, weight-plate geometry, and compact uppercase labels.
- The interface should feel adult and athletic, not militaristic or childish.

## 3. Design system

### Color

- Background: `#FFFFFF`
- Primary ink: `#14213D`
- Primary action: `#F97316`
- Completion: `#22C55E`
- Supporting surface: `#F3F4F6`
- Border: `#E5E7EB`
- Muted text: `#64748B`

Navy surfaces may be used for one high-priority hero card per screen. Large content areas and lists remain white.

### Typography

- Screen and hero headings use a condensed, heavy, uppercase display style.
- Body copy, instructions, nutrition details, and settings use a highly readable system sans-serif.
- Large numbers carry the hierarchy in progress, time, calories, sets, and streaks.
- Avoid using uppercase for paragraphs or technique instructions.

### Shape and depth

- Main cards: 14–18 dp corners.
- Compact exercise rows: 12–14 dp corners.
- Borders: 1 dp neutral gray or navy at low emphasis.
- Shadows are restrained and reserved for floating or selected elements.
- Every interactive control has a minimum 48 dp touch target.

## 4. Screen composition

### Today

1. Bold `HÔM NAY` header with a small geometric gym accent.
2. Navy workout hero card showing session title, completed exercises, and estimated duration.
3. Exercise cards with a stable rhythm: completion control, exercise symbol, name, prescription, and expand action.
4. Completed exercises use green plus a visible check.
5. The orange completion action remains prominent near the bottom and disabled until valid.
6. AI Coach, rest timer, nutrition shortcuts, and calorie-compensation information use supporting cards below the workout hierarchy rather than competing with the hero.

### Exercise catalog

- Use compact filter chips with a strong selected state.
- Exercise rows prioritize name, muscle group, equipment, and difficulty.
- Technique content opens in a full card or sheet with readable numbered steps.
- Avoid decorative exercise imagery that reduces list density or accessibility.

### Progress

- Lead with one large progress value and concise completed/target text.
- Use navy chart structure, orange current emphasis, and green completed states.
- Calendar completion remains a green mark with an accessible check description.
- Charts use the same sturdy card geometry and avoid dashboard clutter.

### Nutrition

- Keep calorie and macro information visually distinct from workout completion.
- Use the gym system’s typography and card geometry, while preserving macro-specific colors as secondary indicators.
- Sweat Payment appears as an orange action card with explicit workout impact, not as a surprise modification.

### Onboarding and settings

- One decision remains visible at a time.
- Selection cards use navy outline, orange selected accent, and an explicit radio indicator.
- Review and destructive confirmation screens use clear hierarchy rather than dramatic decoration.

## 5. Navigation

- Preserve the current information architecture and feature destinations introduced by the user’s latest changes.
- Navigation uses a white surface, navy inactive icons, and orange for the selected destination.
- Labels remain visible; icons alone are insufficient.
- The active item may use a short orange top rule or compact filled marker, never a gradient.

## 6. Motion and feedback

- Use short, purposeful state transitions for checking an exercise, expanding instructions, and changing tabs.
- Avoid bouncing, confetti, continuous pulsing, or decorative motion.
- Saving, AI requests, camera analysis, and completion actions must show explicit progress and recoverable failure states.
- Respect reduced-motion system preferences where applicable.

## 7. Responsive and accessibility rules

- Support small portrait phones, large portrait phones, and landscape without clipped primary actions.
- Cards reflow rather than shrink text below readable sizes.
- Meaning never depends only on color.
- Maintain WCAG-aware contrast, semantic roles, selected/checked states, and useful content descriptions.
- Vietnamese copy must remain legible and avoid overly condensed fonts for diacritics-heavy body text.

## 8. Implementation boundaries

- Upgrade one feature surface at a time, beginning with Today, then Progress, Nutrition, Catalog, Onboarding, and Settings.
- Extract reusable gym-style primitives only after the second real use case appears.
- Preserve current ViewModels, repositories, persistence, backend integration, and user-authored behavior unless a UI test demonstrates an integration defect.
- Do not rewrite the application in a new navigation or dependency-injection architecture for this visual upgrade.
- Do not commit secrets, `server/.env`, `node_modules`, `.vscode`, build outputs, or machine-local configuration.

## 9. Verification

- Compose tests for selected, checked, disabled, expanded, loading, and error semantics.
- Screenshot/manual checks for small portrait, large portrait, and landscape.
- Regression coverage for onboarding → Today → completion → Progress.
- Offline verification for local workout behavior, plus separate online verification for explicitly network-backed nutrition and AI actions.
- `testDebugUnitTest`, `connectedDebugAndroidTest`, `lintDebug`, and `assembleDebug` must remain green after each screen migration.

## 10. Explicit non-goals

- No dark-only theme in this phase.
- No gradient-based visual identity.
- No 3D chrome, glossy bodybuilding imagery, or neon cyberpunk styling.
- No broad business-logic rewrite as part of visual work.
- No automatic staging or modification of the user’s current uncommitted feature work.
