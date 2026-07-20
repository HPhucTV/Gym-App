import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../../core/model/food_photo_analysis_models.dart';

enum PhotoQualityIssue {
  tooSmall,
  tooDark,
  tooBlurry,
  majorOcclusion,
}

final class PhotoPreparationResult {
  final PreparedUpload? upload;
  final Set<PhotoQualityIssue> issues;

  const PhotoPreparationResult({
    required this.upload,
    required this.issues,
  });

  bool get accepted => upload != null && issues.isEmpty;
}

abstract interface class FoodPhotoPreprocessor {
  Future<PhotoPreparationResult> prepare(Uint8List sourceBytes);
}

/// Deterministic, local image checks before a photo crosses the network boundary.
///
/// These thresholds are app heuristics, not guarantees about food recognition.
final class DeterministicFoodPhotoPreprocessor
    implements FoodPhotoPreprocessor {
  static const int minimumDimensionPixels = 640;
  static const int maximumLongEdgePixels = 1600;
  static const int maximumSourceBytes = 30 * 1024 * 1024;
  static const int analysisLongEdgePixels = 256;
  static const double minimumMeanLuminance = 35;
  static const double minimumLaplacianVariance = 18;
  static const int clippedDarkLuminance = 6;
  static const int clippedLightLuminance = 249;
  static const double maximumContiguousClippedRatio = 0.20;
  static const int jpegQuality = 85;

  @override
  Future<PhotoPreparationResult> prepare(Uint8List sourceBytes) async {
    if (sourceBytes.isEmpty || sourceBytes.length > maximumSourceBytes) {
      return PhotoPreparationResult(
        upload: null,
        issues: const {PhotoQualityIssue.tooSmall},
      );
    }

    try {
      final prepared = await Isolate.run(
        () => _preparePixels(Uint8List.fromList(sourceBytes)),
      );
      if (prepared.issues.isNotEmpty || prepared.jpegBytes == null) {
        return PhotoPreparationResult(
          upload: null,
          issues: Set.unmodifiable(prepared.issues),
        );
      }
      return PhotoPreparationResult(
        upload: PreparedUpload(
          bytes: prepared.jpegBytes!,
          mimeType: 'image/jpeg',
          filename: 'food-analysis.jpg',
        ),
        issues: const {},
      );
    } catch (_) {
      // Malformed or unsupported camera bytes are a local recapture condition.
      return PhotoPreparationResult(
        upload: null,
        issues: const {PhotoQualityIssue.tooSmall},
      );
    }
  }
}

final class _PreparedPixels {
  final Uint8List? jpegBytes;
  final Set<PhotoQualityIssue> issues;

  const _PreparedPixels({
    required this.jpegBytes,
    required this.issues,
  });
}

_PreparedPixels _preparePixels(Uint8List sourceBytes) {
  final decoded = img.decodeImage(sourceBytes);
  if (decoded == null) {
    return const _PreparedPixels(
      jpegBytes: null,
      issues: {PhotoQualityIssue.tooSmall},
    );
  }

  final oriented = img.bakeOrientation(decoded);
  final issues = <PhotoQualityIssue>{};
  if (oriented.width <
          DeterministicFoodPhotoPreprocessor.minimumDimensionPixels ||
      oriented.height <
          DeterministicFoodPhotoPreprocessor.minimumDimensionPixels) {
    issues.add(PhotoQualityIssue.tooSmall);
  }

  final pixels = _freshPixelImage(oriented);
  final analysis = _analysisImage(pixels);
  final luminance = _luminanceValues(analysis);
  final mean =
      luminance.reduce((left, right) => left + right) / luminance.length;
  if (mean < DeterministicFoodPhotoPreprocessor.minimumMeanLuminance) {
    issues.add(PhotoQualityIssue.tooDark);
  }
  if (_laplacianVariance(luminance, analysis.width, analysis.height) <
      DeterministicFoodPhotoPreprocessor.minimumLaplacianVariance) {
    issues.add(PhotoQualityIssue.tooBlurry);
  }
  if (_hasMajorClippedRegion(luminance, analysis.width, analysis.height)) {
    issues.add(PhotoQualityIssue.majorOcclusion);
  }
  if (issues.isNotEmpty) {
    return _PreparedPixels(jpegBytes: null, issues: issues);
  }

  final resized = _resizeForUpload(pixels);
  final sanitized = _freshPixelImage(resized);
  final encoded = Uint8List.fromList(
    img.encodeJpg(
      sanitized,
      quality: DeterministicFoodPhotoPreprocessor.jpegQuality,
      chroma: img.JpegChroma.yuv420,
    ),
  );
  if (encoded.length > PreparedUpload.maxBytes) {
    return const _PreparedPixels(
      jpegBytes: null,
      issues: {PhotoQualityIssue.tooBlurry},
    );
  }
  return _PreparedPixels(jpegBytes: encoded, issues: const {});
}

img.Image _freshPixelImage(img.Image source) {
  final fresh = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 3,
  );
  for (final pixel in source) {
    fresh.setPixelRgb(pixel.x, pixel.y, pixel.r, pixel.g, pixel.b);
  }
  return fresh;
}

img.Image _analysisImage(img.Image source) {
  final longEdge = math.max(source.width, source.height);
  if (longEdge <= DeterministicFoodPhotoPreprocessor.analysisLongEdgePixels) {
    return source;
  }
  final scale =
      DeterministicFoodPhotoPreprocessor.analysisLongEdgePixels / longEdge;
  return img.copyResize(
    source,
    width: math.max(1, (source.width * scale).round()),
    height: math.max(1, (source.height * scale).round()),
    interpolation: img.Interpolation.average,
  );
}

img.Image _resizeForUpload(img.Image source) {
  final longEdge = math.max(source.width, source.height);
  if (longEdge <= DeterministicFoodPhotoPreprocessor.maximumLongEdgePixels) {
    return source;
  }
  final scale =
      DeterministicFoodPhotoPreprocessor.maximumLongEdgePixels / longEdge;
  return img.copyResize(
    source,
    width: math.max(1, (source.width * scale).round()),
    height: math.max(1, (source.height * scale).round()),
    interpolation: img.Interpolation.linear,
  );
}

List<double> _luminanceValues(img.Image image) {
  final values = List<double>.filled(image.width * image.height, 0);
  var index = 0;
  for (final pixel in image) {
    values[index++] =
        (0.2126 * pixel.r) + (0.7152 * pixel.g) + (0.0722 * pixel.b);
  }
  return values;
}

double _laplacianVariance(List<double> values, int width, int height) {
  if (width < 3 || height < 3) return 0;
  var sum = 0.0;
  var sumSquares = 0.0;
  var count = 0;
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      final index = y * width + x;
      final laplacian = (4 * values[index]) -
          values[index - 1] -
          values[index + 1] -
          values[index - width] -
          values[index + width];
      sum += laplacian;
      sumSquares += laplacian * laplacian;
      count++;
    }
  }
  final mean = sum / count;
  return (sumSquares / count) - (mean * mean);
}

bool _hasMajorClippedRegion(List<double> values, int width, int height) {
  final total = values.length;
  final clipped = List<bool>.generate(
    total,
    (index) =>
        values[index] <=
            DeterministicFoodPhotoPreprocessor.clippedDarkLuminance ||
        values[index] >=
            DeterministicFoodPhotoPreprocessor.clippedLightLuminance,
    growable: false,
  );
  final visited = Uint8List(total);
  final queue = List<int>.filled(total, 0);
  final required =
      (total * DeterministicFoodPhotoPreprocessor.maximumContiguousClippedRatio)
          .ceil();

  for (var start = 0; start < total; start++) {
    if (!clipped[start] || visited[start] != 0) continue;
    var head = 0;
    var tail = 0;
    var componentSize = 0;
    queue[tail++] = start;
    visited[start] = 1;
    while (head < tail) {
      final index = queue[head++];
      componentSize++;
      if (componentSize >= required) return true;
      final x = index % width;
      final y = index ~/ width;
      if (x > 0) {
        tail = _enqueue(index - 1, clipped, visited, queue, tail);
      }
      if (x + 1 < width) {
        tail = _enqueue(index + 1, clipped, visited, queue, tail);
      }
      if (y > 0) {
        tail = _enqueue(index - width, clipped, visited, queue, tail);
      }
      if (y + 1 < height) {
        tail = _enqueue(index + width, clipped, visited, queue, tail);
      }
    }
  }
  return false;
}

int _enqueue(
  int index,
  List<bool> clipped,
  Uint8List visited,
  List<int> queue,
  int tail,
) {
  if (!clipped[index] || visited[index] != 0) return tail;
  visited[index] = 1;
  queue[tail] = index;
  return tail + 1;
}
