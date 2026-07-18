import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/data/remote/backend_config.dart';

void main() {
  test('server URL is trimmed normalized and restricted to HTTP protocols', () {
    expect(BackendConfig.normalizeServerUrl("  https://coach.example.com/  "), "https://coach.example.com");
    expect(BackendConfig.normalizeServerUrl("http://192.168.1.8:3000"), "http://192.168.1.8:3000");
    expect(BackendConfig.normalizeServerUrl("192.168.1.7:3000"), "http://192.168.1.7:3000");
    expect(BackendConfig.normalizeServerUrl("localhost:3000"), "http://localhost:3000");
    expect(BackendConfig.normalizeServerUrl("ftp://coach.example.com"), null);
    expect(BackendConfig.normalizeServerUrl("not a url"), null);
    expect(BackendConfig.normalizeServerUrl("  "), null);
  });

  test('custom URL overrides default backend regardless of device type', () {
    BackendConfig.customServerUrl = "https://coach.example.com/";
    BackendConfig.setEmulatorForTest(false);
    expect(BackendConfig.baseUrl, "https://coach.example.com");

    BackendConfig.customServerUrl = "http://192.168.1.5:3000";
    BackendConfig.setEmulatorForTest(true);
    expect(BackendConfig.baseUrl, "http://192.168.1.5:3000");
  });

  test('null custom URL falls back to provided default', () {
    BackendConfig.customServerUrl = null;
    
    // Test physical device fallback
    BackendConfig.setEmulatorForTest(false);
    expect(BackendConfig.baseUrl, BackendConfig.physicalBackendUrl);

    // Test emulator fallback
    BackendConfig.setEmulatorForTest(true);
    // Since we're running tests on a standard environment (typically desktop/headless JVM),
    // Platform.isAndroid is false, so it should fall back to emulatorBackendUrlIos
    expect(BackendConfig.baseUrl, BackendConfig.emulatorBackendUrlIos);
  });
}
