import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _naturalScrolling = false;
  bool _hapticsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get naturalScrolling => _naturalScrolling;
  bool get hapticsEnabled => _hapticsEnabled;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _naturalScrolling = _prefs.getBool('naturalScrolling') ?? false;
    _hapticsEnabled = _prefs.getBool('hapticsEnabled') ?? true;

    final savedTheme = _prefs.getString('themeMode');
    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
      case 'dark':
        _themeMode = ThemeMode.dark;
      case 'system':
        _themeMode = ThemeMode.system;
      default:
        _themeMode = ThemeMode.dark;
    }

    notifyListeners();
  }

  Future<void> toggleNaturalScrolling(bool value) async {
    _naturalScrolling = value;
    await _prefs.setBool('naturalScrolling', value);
    notifyListeners();
    debugPrint('Natural scrolling toggled to $value');
  }

  Future<void> toggleHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    await _prefs.setBool('hapticsEnabled', value);
    notifyListeners();
    debugPrint('Haptic feedback toggled to $value');
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString('themeMode', mode.name);
    notifyListeners();
    debugPrint('Theme mode changed to $mode');
  }
}
