import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _enableImposterHints = true;
  bool _enableLastChanceGuess = false; // False by default
  int _discussionTimerSeconds = 180; // 3 minutes default
  bool _timerWarningAlert = true;
  bool _holdToReveal = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get enableImposterHints => _enableImposterHints;
  bool get enableLastChanceGuess => _enableLastChanceGuess;
  int get discussionTimerSeconds => _discussionTimerSeconds;
  bool get timerWarningAlert => _timerWarningAlert;
  bool get holdToReveal => _holdToReveal;
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

  void setLastChanceGuess(bool enabled) {
    if (_enableLastChanceGuess == enabled) return;
    _enableLastChanceGuess = enabled;
    notifyListeners();
  }

  void setDiscussionTimerSeconds(int seconds) {
    final clamped = seconds.clamp(30, 600);
    if (_discussionTimerSeconds == clamped) return;
    _discussionTimerSeconds = clamped;
    notifyListeners();
  }

  void setTimerWarningAlert(bool enabled) {
    if (_timerWarningAlert == enabled) return;
    _timerWarningAlert = enabled;
    notifyListeners();
  }

  void setHoldToReveal(bool enabled) {
    if (_holdToReveal == enabled) return;
    _holdToReveal = enabled;
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

  void resetToDefaults() {
    _themeMode = ThemeMode.light;
    _enableImposterHints = true;
    _enableLastChanceGuess = false;
    _discussionTimerSeconds = 180;
    _timerWarningAlert = true;
    _holdToReveal = false;
    _soundEnabled = true;
    _vibrationEnabled = true;
    notifyListeners();
  }
}
