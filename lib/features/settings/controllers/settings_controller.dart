import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _enableImposterHints = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get enableImposterHints => _enableImposterHints;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setImposterHints(bool enabled) {
    if (_enableImposterHints == enabled) return;
    _enableImposterHints = enabled;
    notifyListeners();
  }

  void setSound(bool enabled) {
    if (_soundEnabled == enabled) return;
    _soundEnabled = enabled;
    notifyListeners();
  }

  void setVibration(bool enabled) {
    if (_vibrationEnabled == enabled) return;
    _vibrationEnabled = enabled;
    notifyListeners();
  }
}
