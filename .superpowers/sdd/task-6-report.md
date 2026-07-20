# Task 6 Report: Private Food Photo Capture

## Outcome

Implemented the Flutter food-photo boundary without connecting it to food
recognition or nutrition calculation:

- official rear-camera capture behind a widget-testable gateway;
- audio disabled and flash forced off;
- camera lifecycle release/reinitialization and disposal;
- best-effort deletion of the camera plugin's temporary capture file after its
  bytes are read;
- background image decoding and analysis with `Isolate.run`;
- EXIF orientation baking followed by a fresh pixel copy, resize, and JPEG
  re-encoding with no EXIF, ICC profile, or source-byte reference retained;
- bounded local quality guidance for small, dark, blurry, or substantially
  obstructed frames;
- a capture screen that distinguishes the primary meal/label photo from a
  requested side/close-up, prevents double capture, and returns only a
  `PreparedUpload`;
- Vietnamese iOS camera-purpose copy for food and nutrition-label photos.

No storage, location, or microphone permission was added. Android still has
only its existing `CAMERA` and `INTERNET` permissions for this workflow.

## TDD evidence

The first focused preprocessing run failed because
`food_photo_preprocessor.dart` and its API did not exist. The first widget-test
run likewise failed because the gateway and capture screen did not exist.

Final focused command:

```powershell
flutter test test/feature/nutrition/photo/food_photo_preprocessor_test.dart test/feature/nutrition/photo/food_capture_screen_test.dart
```

Result: 12 passed, 0 failed.

Full Flutter test command:

```powershell
flutter test
```

Result: 246 passed, 0 failed.

Scoped analyzer:

```powershell
flutter analyze lib/feature/nutrition/photo test/feature/nutrition/photo
```

Result: no issues.

Full analyzer completed with 175 pre-existing warnings/info outside the Task 6
files. No Task 6 analyzer finding was reported.

Android debug build:

```powershell
flutter build apk --debug
```

Result: built `build/app/outputs/flutter-apk/app-debug.apk`. The build emitted
the repository's existing future Kotlin Gradle Plugin migration warning for
`device_info_plus` and `mobile_scanner`; it did not report a Task 6 compile
error.

## Dependencies and platform constraints

`flutter pub add camera image` resolved:

- `camera 0.12.0+2`;
- `image 4.8.0`.

The package solver selected `image 4.8.0` for the current dependency graph even
though pub.dev lists a newer release. No SDK constraint, Android min SDK, iOS
deployment target, or native build configuration was raised. The app remains
Android min SDK 24 and iOS deployment target 15.

## Official sources consulted

- Flutter camera cookbook:
  https://docs.flutter.dev/cookbook/plugins/picture-using-camera
- Official `camera` package page:
  https://pub.dev/packages/camera
- Official `camera` Dart API:
  https://pub.dev/documentation/camera/latest/camera/
- Official `image` package page:
  https://pub.dev/packages/image
- Official `image` package changelog:
  https://pub.dev/packages/image/changelog

The camera implementation follows the documented `availableCameras`,
`CameraController.initialize`, `CameraPreview`, `takePicture`, and `dispose`
flow. The package requires the app to own lifecycle changes, so the screen
releases the gateway on inactive/paused/hidden/detached and initializes it again
on resume.

## App heuristics and limitations

The following values are deterministic app heuristics, not thresholds from the
Flutter, camera, or image APIs:

- minimum decoded width and height: 640 px;
- analysis copy long edge: 256 px;
- minimum mean luminance: 35 on a 0-255 scale;
- minimum Laplacian variance: 18;
- clipped luminance: at most 6 or at least 249;
- minimum border-attached clipped component: 12 percent of the analysis frame,
  with corner/band geometry checks;
- output long edge: at most 1600 px;
- JPEG quality: 85 with 4:2:0 chroma, then bounded quality retries at
  75/65/55 while stepping the long edge through 1440/1280/1024 only if needed;
- defensive source-byte cap: 30 MB.

These values are verified only by deterministic synthetic fixtures in this
task. They have not been calibrated against a physical-device Vietnamese food
photo dataset and may need later evaluation-driven tuning. The occlusion check
only detects a large connected near-black/near-white obstruction; it does not
decide whether foods overlap or identify dishes. Malformed, unsupported, empty,
or defensively oversized input is converted to local recapture guidance rather
than exposed as a crash.

Physical camera behavior was not verified because no real-device camera run was
part of this task.

## Review follow-up

The first implementation review found that the Android camera plugin's merged
manifest added audio and legacy external-storage permissions. The app manifest
now declares `tools:node="remove"` rules for `RECORD_AUDIO` and
`WRITE_EXTERNAL_STORAGE`; `flutter/tool/verify_camera_manifest.ps1` checks both
the source manifest and, with `-RequireMerged`, the debug merged manifest after
an APK build. A repeatable Flutter test covers the source-manifest rules.

Preprocessing now sniffs only JPEG, PNG, and WebP signatures and asks the
`image 4.8.0` decoder for header metadata before allocating decoded pixels. It
rejects dimensions above 12,000 px, more than 20 million total pixels, and
multi-frame inputs. Transparent pixels are composited onto an explicit white
background before quality checks and JPEG encoding.

The clipped-region heuristic keeps dark and light classes separate and only
considers a sufficiently large border-attached component with framing-like
geometry. Interior black label content and bright plate content are accepted;
thin dark framing is accepted; a large corner obstruction remains rejected.
These remain app heuristics and are not food-recognition claims.

Camera lifecycle operations are serialized in the gateway. Each initialize
request owns its controller until it completes, stale requests dispose only
their own controller, and screen lifecycle callbacks no longer issue a
stale-controller disposal after a newer initialization. Widget tests cover
close during initialization and capture, no late navigation, generic
initialization failure guidance, and single-dispose behavior.

Follow-up verification after the manifest fix:

```powershell
flutter build apk --debug
powershell -NoProfile -File .\tool\verify_camera_manifest.ps1 -RequireMerged
```

The APK build completed successfully. The verification script inspected
`build/app/intermediates/merged_manifest/debug/processDebugMainManifest/AndroidManifest.xml`
and the equivalent `merged_manifests` output; both contain `CAMERA` and
`INTERNET` but neither `RECORD_AUDIO` nor `WRITE_EXTERNAL_STORAGE`.

Final review verification:

- focused photo, capture-screen, and manifest tests: 22 passed;
- complete Flutter test suite: 256 passed;
- scoped photo-feature analysis: no issues;
- complete Flutter analysis: 175 pre-existing findings outside Task 6, with no
  Task 6 finding;
- final debug APK build: successful;
- post-build merged-manifest permission verification: successful.
