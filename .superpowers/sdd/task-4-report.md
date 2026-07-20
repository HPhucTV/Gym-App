# Task 4 Report: Typed Flutter Photo-Analysis Client

## Outcome

Added the typed Flutter boundary for the photo-food workflow:

- strict immutable Dart models for review, confirmation, portion, label, range, and ready-result payloads;
- canonical wire enums with typed rejection of unknown values;
- Dio multipart calls for primary and secondary images using the exact backend fields and routes;
- JSON confirmation calls scoped to the requested analysis ID;
- canonical nested API-error parsing and timeout fallback;
- tracked cancellation tokens that are removed in `finally` and cleared by `cancelPending()`.

The existing `analyze`, `scanBarcode`, and `registerBarcode` methods remain on
`FoodAnalysisClient` and retain their nullable/bool compatibility behavior. The
injected endpoint provider now supplies the backend base URL; the client derives
both the new photo routes and the legacy `/api/analyze-food` route from it.

No camera, UI, or Drift work was included.

## Red-Green Evidence

Initial focused red:

```text
flutter test test/data/remote/food_analysis_client_test.dart
FAIL: food_photo_analysis_models.dart did not exist and FoodAnalysisClient had
no startPhotoAnalysis/addSecondaryPhoto/confirmAnalysis/cancelPending methods.
```

Additional strict-boundary reds:

```text
unknown portion.kind enum -> FoodPortionKind did not exist
2026-02-30T10:15:00.000Z -> malformed calendar date was initially accepted
```

Focused green:

```text
flutter test test/data/remote/food_analysis_client_test.dart
PASS: 14 tests, 0 failures
```

## Verification

```text
dart format lib/core/model/food_photo_analysis_models.dart \
  lib/data/remote/food_analysis_client.dart \
  lib/data/providers/remote_providers.dart \
  test/data/remote/food_analysis_client_test.dart
PASS

flutter test test/data/remote/food_analysis_client_test.dart
PASS: 14 tests, 0 failures

flutter test test/feature/nutrition/nutrition_view_model_test.dart
PASS: 3 tests, 0 failures

dart analyze <each Task 4 Dart file>
PASS: no issues found in all four files

git diff --check
PASS: no whitespace errors
```

Full `flutter analyze` completed but returned exit 1 for 175 existing repository
warnings/info diagnostics (unused fields/imports, deprecated APIs, lint style,
and debug prints). It reported no diagnostic in a Task 4 file. These unrelated
baseline findings were not modified.

## Contract and Boundary Review

- Every canonical enum value in the global contract has a Dart parser; unknown
  values throw `FoodAnalysisFormatException`.
- Review parsing enforces the `imageType` discriminator:
  `MEAL` requires components, `NUTRITION_LABEL` requires label facts, and
  `UNKNOWN` requires null observations plus `UNRECOGNIZED`.
- Analysis IDs are required to be non-empty (the backend session store does
  not impose a length maximum); observation/component IDs remain bounded by
  their canonical Zod schemas.
- `expiresAt` must be a timezone-qualified ISO timestamp with a valid calendar
  date.
- Confidence is finite and within 0–1. Nutrients are finite and non-negative.
  Estimate ranges enforce `min <= mid <= max`.
- Photo methods never return null. Canonical nested HTTP errors become
  `FoodAnalysisApiException`; timeouts and malformed HTTP errors fail closed as
  `ANALYSIS_UNAVAILABLE`, while intentional cancellation is a distinct typed
  `FoodAnalysisCancelledException`.
- Active photo tokens are added before a request and removed in `finally`.
  `cancelPending()` cancels a snapshot and clears the tracked set.
- Multipart fields are exactly `primaryImage` and `secondaryImage`; confirmation
  JSON is sent to `/api/food-analyses/{analysisId}/confirmations`.

## Concerns

- The repository-wide analyzer baseline remains non-clean, as described above.
- Legacy barcode calls still use their existing `BackendConfig` lookup directly;
  this is intentional compatibility until the separately planned barcode
  cleanup.
- No generated files were edited and `build_runner` was not needed because the
  new strict models intentionally use hand-written parsers.

## Post-Review Fixes

The Task 4 review found cancellation ambiguity and several boundary-validation
gaps. They were fixed in a separate follow-up commit:

- Added `FoodAnalysisCancelledException`. Intentional Dio cancellation is no
  longer reported as `ANALYSIS_UNAVAILABLE`; concurrent pending photo requests
  are all cancelled, removed from tracking, and remain distinguishable from
  network outages.
- Replaced permissive JSON maps with exact-key parsing at every response-object
  boundary. Required nullable fields must be present, unknown fields fail
  closed, and review/ready discriminator combinations mirror the backend.
- Mirrored the backend Zod bounds for component counts and text, portions,
  confidence, uncertainty codes, nutrients, label serving/net values, and
  `missingFields` consistency.
- Replaced assertion-only portion, nutrient, range, and confirmation invariants
  with typed runtime validation. Invalid local confirmation construction now
  throws `FoodAnalysisFormatException` before serialization or transport.
- Made `PreparedUpload` snapshot caller bytes, expose copies, enforce the 5 MB
  and supported-format boundary, and preserve the original bytes through
  multipart serialization even if caller-owned buffers are mutated.
- Bounded API error detail keys, collections, nesting, and strings; discarded
  unsupported/non-finite values; and deep-froze the sanitized result.
- Replaced the legacy tear-off compilation check with adapter-backed behavior
  tests for URLs, parsing, request bodies, nullable/bool returns, 404 handling,
  and legacy error behavior.

Review red evidence:

```text
flutter test test/data/remote/food_analysis_client_test.dart
FAIL: FoodAnalysisCancelledException did not exist

flutter test ... --plain-name \
  "requires label READY results to have no meal uncertainty codes"
FAIL: malformed label READY payload was accepted

flutter test ... --plain-name \
  "does not invent limits absent from backend session responses"
FAIL: client rejected a 201-character analysis ID before the unbounded
backend session-store contract was mirrored
```

Post-review verification:

```text
flutter test test/data/remote/food_analysis_client_test.dart \
  test/feature/nutrition/nutrition_view_model_test.dart
PASS: 34 tests, 0 failures

dart analyze <each Task 4 Dart file>
PASS: no issues found in all four files

flutter analyze
BASELINE: 175 existing repository warnings/info, unchanged from the original
Task 4 run; no diagnostic references a Task 4 file

git diff --check
PASS: no whitespace errors
```

No generated file or later-task camera/UI/Drift surface was changed. The
repository-wide analyzer baseline remains the only known verification concern.

The backend detects MIME from image bytes and does not use the multipart
filename. The Flutter upload value intentionally performs an earlier safety
preflight: it accepts the three image MIME values emitted by the app camera
pipeline and caps filenames at 255 characters. This is stricter metadata
validation only; it does not change the backend's 5 MB byte limit or image
signature rules.
