import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class BackendConfig {
  static String? customServerUrl;
  static bool _isEmulator = false;
  static bool _isInitialized = false;

  static const String emulatorBackendUrlAndroid = 'http://10.0.2.2:3000';
  static const String emulatorBackendUrlIos = 'http://localhost:3000';
  static const String physicalBackendUrl = 'https://gym-app-w7sz.onrender.com';

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isEmulator = await _detectEmulator();
    _isInitialized = true;
  }

  // Cho phép thiết lập trực tiếp trong unit tests
  @visibleForTesting
  static void setEmulatorForTest(bool isEmulator) {
    _isEmulator = isEmulator;
    _isInitialized = true;
  }

  static String? get baseUrl {
    if (customServerUrl != null) {
      final normalized = normalizeServerUrl(customServerUrl);
      if (normalized != null) return normalized;
    }
    if (_isEmulator) {
      if (kIsWeb) return emulatorBackendUrlIos;
      if (Platform.isAndroid) return emulatorBackendUrlAndroid;
      return emulatorBackendUrlIos;
    }
    return physicalBackendUrl;
  }

  static Future<bool> _detectEmulator() async {
    if (kIsWeb) return false;
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return !iosInfo.isPhysicalDevice;
      }
    } catch (_) {
      // Fallback
    }
    return false;
  }

  static String? normalizeServerUrl(String? value) {
    if (value == null) return null;
    var trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.isEmpty || trimmed.contains(' ')) return null;

    final hasScheme = trimmed.contains('://');
    final candidate = hasScheme ? trimmed : 'http://$trimmed';

    try {
      final uri = Uri.parse(candidate);
      if (uri.scheme != 'http' && uri.scheme != 'https') return null;
      if (uri.host.isEmpty || uri.host.contains(' ') || uri.userInfo.isNotEmpty || uri.query.isNotEmpty || uri.fragment.isNotEmpty) {
        return null;
      }
      return candidate;
    } catch (_) {
      return null;
    }
  }
}
