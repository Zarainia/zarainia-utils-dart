import 'package:shared_preferences/shared_preferences.dart';

extension ZarainiaSharedPreferencesExtension on SharedPreferences {
  Future<bool> setNullableString(String key, String? value) {
    if (value == null)
      return remove(key);
    else
      return setString(key, value);
  }

  Future<bool> setNullableDouble(String key, double? value) {
    if (value == null)
      return remove(key);
    else
      return setDouble(key, value);
  }
}
