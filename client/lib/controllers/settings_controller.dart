import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _naturalScrolling = false;
  bool _hapticsEnabled = true;
  double _trackpadSensitivity = 2.0;
  ThemeMode _themeMode = ThemeMode.system;

  bool get naturalScrolling => _naturalScrolling;
  bool get hapticsEnabled => _hapticsEnabled;
  double get trackpadSensitivity => _trackpadSensitivity;
  ThemeMode get themeMode => _themeMode;

  /// Only changes the in-memory variable for displaying to the screen
  set trackpadSensitivity(double value) {
    _trackpadSensitivity = value;
    notifyListeners();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _naturalScrolling = _prefs.getBool('naturalScrolling') ?? false;
    _hapticsEnabled = _prefs.getBool('hapticsEnabled') ?? true;
    _trackpadSensitivity = _prefs.getDouble('trackpadSensitivity') ?? 2.0;

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

  Future<void> persistTrackpadSensitivity(double sensitivity) async {
    _trackpadSensitivity = sensitivity;
    await _prefs.setDouble('trackpadSensitivity', sensitivity);
    notifyListeners();
    debugPrint('Trackpad sensitivity updated to: $sensitivity');
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString('themeMode', mode.name);
    notifyListeners();
    debugPrint('Theme mode changed to $mode');
  }
}
