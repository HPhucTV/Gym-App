import 'dart:async';
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
  Future<void> _lastOperation = Future<void>.value();
  int _lifecycleGeneration = 0;

  @override
  Future<void> initialize() {
    final requestGeneration = ++_lifecycleGeneration;
    return _enqueue(() async {
      await _disposeController();
      late final List<CameraDescription> cameras;
      try {
        cameras = await availableCameras();
      } on CameraException catch (error) {
        if (_isPermissionError(error.code)) {
          throw const FoodCameraException.permissionDenied();
        }
        throw const FoodCameraException.initializationFailed();
      } catch (_) {
        throw const FoodCameraException.initializationFailed();
      }
      CameraDescription? rearCamera;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          rearCamera = camera;
          break;
        }
      }
      if (rearCamera == null) {
        if (cameras.isEmpty) {
          throw const FoodCameraException.unavailable();
        }
        rearCamera = cameras.first;
      }

      final controller = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      try {
        await controller.initialize();
        await controller.setFlashMode(FlashMode.off);
        if (requestGeneration != _lifecycleGeneration) {
          await controller.dispose();
          return;
        }
        _controller = controller;
      } on CameraException catch (error) {
        await controller.dispose();
        if (_isPermissionError(error.code)) {
          throw const FoodCameraException.permissionDenied();
        }
        throw const FoodCameraException.initializationFailed();
      } catch (_) {
        await controller.dispose();
        rethrow;
      }
    });
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
  Future<Uint8List> takePicture() {
    return _enqueue(() async {
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
    });
  }

  @override
  Future<void> dispose() {
    ++_lifecycleGeneration;
    return _enqueue(_disposeController);
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) async {
    final previous = _lastOperation;
    final gate = Completer<void>();
    _lastOperation = gate.future;
    try {
      await previous;
      return await operation();
    } finally {
      gate.complete();
    }
  }
}

bool _isPermissionError(String code) {
  final normalized = code.toLowerCase();
  return normalized.contains('accessdenied') ||
      normalized.contains('permission') ||
      normalized.contains('restricted') ||
      normalized.contains('notauthorized');
}
