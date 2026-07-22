import 'package:shared_preferences/shared_preferences.dart';

abstract interface class FoodPhotoConsentRepository {
  Future<bool> hasConsent();

  Future<void> setConsent(bool consent);
}

final class SharedPrefsFoodPhotoConsentRepository
    implements FoodPhotoConsentRepository {
  static const String preferenceKey = 'food_photo_upload_ai_consent_v1';

  final SharedPreferences _preferences;

  const SharedPrefsFoodPhotoConsentRepository(this._preferences);

  @override
  Future<bool> hasConsent() async =>
      _preferences.getBool(preferenceKey) ?? false;

  @override
  Future<void> setConsent(bool consent) async {
    final stored = await _preferences.setBool(preferenceKey, consent);
    if (!stored) {
      throw StateError('Could not persist food-photo consent.');
    }
  }
}
