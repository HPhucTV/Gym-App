import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:gym_app/feature/nutrition/photo/food_photo_preprocessor.dart';

void main() {
  final preprocessor = DeterministicFoodPhotoPreprocessor();

  test('rejects a decoded image whose dimensions are below 640 px', () async {
    final result = await preprocessor.prepare(_fixture(500, 500));

    expect(result.upload, isNull);
    expect(result.issues, contains(PhotoQualityIssue.tooSmall));
  });

  test('rejects a very dark image with local recapture guidance', () async {
    final result = await preprocessor.prepare(_fixture(800, 800, color: 12));

    expect(result.upload, isNull);
    expect(result.issues, contains(PhotoQualityIssue.tooDark));
  });

  test('rejects a uniform image as too blurry', () async {
    final result = await preprocessor.prepare(_fixture(800, 800, color: 145));

    expect(result.upload, isNull);
    expect(result.issues, contains(PhotoQualityIssue.tooBlurry));
  });

  test('rejects a contiguous clipped region as a major occlusion', () async {
    final result = await preprocessor.prepare(
      _fixture(800, 800, obstruction: true),
    );

    expect(result.upload, isNull);
    expect(result.issues, contains(PhotoQualityIssue.majorOcclusion));
  });

  test('accepts clear black-on-white label content away from the frame',
      () async {
    final image = _solidImage(900, 800, 120);
    for (var y = 150; y < 550; y++) {
      for (var x = 100; x < 800; x++) {
        image.setPixelRgb(x, y, 0, 0, 0);
      }
    }

    final result = await preprocessor.prepare(_encode(image));

    expect(result.accepted, isTrue);
  });

  test('accepts a clear bright plate against a neutral background', () async {
    final image = _solidImage(900, 800, 100);
    for (var y = 160; y < 640; y++) {
      for (var x = 180; x < 760; x++) {
        image.setPixelRgb(x, y, 255, 255, 255);
      }
    }

    final result = await preprocessor.prepare(_encode(image));

    expect(result.accepted, isTrue);
  });

  test('accepts a legitimate thin dark frame', () async {
    final image = _solidImage(900, 800, 140);
    for (var x = 0; x < 40; x++) {
      for (var y = 0; y < image.height; y++) {
        image.setPixelRgb(x, y, 0, 0, 0);
        image.setPixelRgb(image.width - 1 - x, y, 0, 0, 0);
      }
    }
    final result = await preprocessor.prepare(_encode(image));

    expect(result.accepted, isTrue);
  });

  test('rejects an oversized PNG header before pixel allocation', () async {
    final result = await preprocessor.prepare(_oversizedPngHeader());

    expect(result.upload, isNull);
    expect(result.issues, contains(PhotoQualityIssue.tooSmall));
  });

  test('rejects animated input instead of decoding multiple frames', () async {
    final animated = img.Image(width: 800, height: 800);
    animated.setPixelRgb(0, 0, 120, 120, 120);
    final second = img.Image(width: 800, height: 800);
    second.setPixelRgb(0, 0, 130, 130, 130);
    animated.addFrame(second);

    final result = await preprocessor.prepare(img.encodeGif(animated));

    expect(result.upload, isNull);
    expect(result.issues, contains(PhotoQualityIssue.tooSmall));
  });

  test('accepts a clear lit image as metadata-free JPEG under 5 MB', () async {
    final result =
        await preprocessor.prepare(_fixture(1200, 900, detailed: true));

    expect(result.accepted, isTrue);
    final upload = result.upload!;
    expect(upload.filename, 'food-analysis.jpg');
    expect(upload.mimeType, 'image/jpeg');
    expect(upload.bytes.length, lessThan(5 * 1024 * 1024));
    expect(upload.bytes.take(2), orderedEquals([0xff, 0xd8]));
    final decoded = img.decodeJpg(upload.bytes);
    expect(decoded, isNotNull);
    expect(decoded!.width, 1200);
    expect(decoded.height, 900);
    expect(decoded.exif.isEmpty, isTrue);
    expect(decoded.iccProfile, isNull);
  });

  test('strips input EXIF and does not retain replaceable source bytes',
      () async {
    final sourceImage = img.decodeJpg(_fixture(900, 800, detailed: true))!;
    sourceImage.exif.imageIfd['ImageDescription'] = 'private meal note';
    sourceImage.exif.imageIfd['Orientation'] = 6;
    final source = Uint8List.fromList(img.encodeJpg(sourceImage, quality: 90));
    expect(img.decodeJpg(source)!.exif.isEmpty, isFalse);

    final result = await preprocessor.prepare(source);
    final outputBeforeReplacement = result.upload!.bytes;
    source.fillRange(0, source.length, 0);

    final outputAfterReplacement = result.upload!.bytes;
    expect(outputAfterReplacement, orderedEquals(outputBeforeReplacement));
    expect(img.decodeJpg(outputAfterReplacement)!.exif.isEmpty, isTrue);
    expect(img.decodeJpg(outputAfterReplacement)!.width, 800);
    expect(img.decodeJpg(outputAfterReplacement)!.height, 900);
  });

  test('caps the output long edge at 1600 px', () async {
    final result =
        await preprocessor.prepare(_fixture(2200, 900, detailed: true));

    expect(result.accepted, isTrue);
    final decoded = img.decodeJpg(result.upload!.bytes)!;
    expect(decoded.width, 1600);
    expect(decoded.height, lessThanOrEqualTo(1600));
  });
}

Uint8List _fixture(
  int width,
  int height, {
  int color = 120,
  bool detailed = false,
  bool obstruction = false,
}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final isObstruction = obstruction && x < width ~/ 2 && y < height ~/ 2;
      final value = isObstruction
          ? 255
          : detailed
              ? (60 + ((x * 31 + y * 17) % 170))
              : color;
      image.setPixelRgb(
        x,
        y,
        value,
        isObstruction ? value : (value * 0.9).round(),
        isObstruction ? value : (value * 0.75).round(),
      );
    }
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

img.Image _solidImage(int width, int height, int color) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgb(x, y, color, color, color);
    }
  }
  return image;
}

Uint8List _encode(img.Image image) =>
    Uint8List.fromList(img.encodeJpg(image, quality: 90));

Uint8List _oversizedPngHeader() {
  final bytes = Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0xff,
    0xff,
    0xff,
    0xff,
    0xff,
    0xff,
    0xff,
    0xff,
    8,
    2,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    0,
    0,
    0,
    0,
  ]);
  return bytes;
}
