import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

abstract interface class FoodCameraGateway {
  Future<void> initialize();
  Widget buildPreview();
  Future<Uint8List> takePicture();
  Future<void> dispose();
}

enum FoodCameraFailure {
  permissionDenied,
  unavailable,
  initializationFailed,
  captureFailed,
}

final class FoodCameraException implements Exception {
  final FoodCameraFailure failure;

  const FoodCameraException.permissionDenied()
      : failure = FoodCameraFailure.permissionDenied;

  const FoodCameraException.unavailable()
      : failure = FoodCameraFailure.unavailable;

  const FoodCameraException.initializationFailed()
      : failure = FoodCameraFailure.initializationFailed;

  const FoodCameraException.captureFailed()
      : failure = FoodCameraFailure.captureFailed;
}

final class CameraPluginFoodGateway implements FoodCameraGateway {
  CameraController? _controller;

  @override
  Future<void> initialize() async {
    await dispose();
    try {
      final cameras = await availableCameras();
      CameraDescription? rearCamera;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          rearCamera = camera;
          break;
        }
      }
      if (rearCamera == null) {
        throw const FoodCameraException.unavailable();
      }

      final controller = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _controller = controller;
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
    } on FoodCameraException {
      rethrow;
    } on CameraException catch (error) {
      await dispose();
      if (_isPermissionError(error.code)) {
        throw const FoodCameraException.permissionDenied();
      }
      throw const FoodCameraException.initializationFailed();
    } catch (_) {
      await dispose();
      throw const FoodCameraException.initializationFailed();
    }
  }

  @override
  Widget buildPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return CameraPreview(controller);
  }

  @override
  Future<Uint8List> takePicture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      throw const FoodCameraException.captureFailed();
    }

    XFile? capture;
    try {
      await controller.setFlashMode(FlashMode.off);
      capture = await controller.takePicture();
      return await capture.readAsBytes();
    } on CameraException catch (error) {
      if (_isPermissionError(error.code)) {
        throw const FoodCameraException.permissionDenied();
      }
      throw const FoodCameraException.captureFailed();
    } catch (_) {
      throw const FoodCameraException.captureFailed();
    } finally {
      final path = capture?.path;
      if (path != null && path.isNotEmpty) {
        try {
          final file = File(path);
          if (await file.exists()) await file.delete();
        } catch (_) {
          // Best-effort removal from the plugin's temporary capture location.
        }
      }
    }
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}

bool _isPermissionError(String code) {
  final normalized = code.toLowerCase();
  return normalized.contains('accessdenied') ||
      normalized.contains('permission');
}
