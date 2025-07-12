import 'package:flutter/foundation.dart';
import 'package:sudoku_app/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  bool _highlightSameNumbers = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoSave = true;
  bool _showTimer = true;
  bool _isLoaded = false;

  // Getters
  bool get highlightSameNumbers => _highlightSameNumbers;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get autoSave => _autoSave;
  bool get showTimer => _showTimer;
  bool get isLoaded => _isLoaded;

  // 初始化設定
  Future<void> loadSettings() async {
    if (_isLoaded) return;
    
    _highlightSameNumbers = await _settingsService.getHighlightSameNumbers();
    _soundEnabled = await _settingsService.getSoundEnabled();
    _vibrationEnabled = await _settingsService.getVibrationEnabled();
    _autoSave = await _settingsService.getAutoSave();
    _showTimer = await _settingsService.getShowTimer();
    _isLoaded = true;
    
    notifyListeners();
  }

  // 設定醒目數字
  Future<void> setHighlightSameNumbers(bool value) async {
    _highlightSameNumbers = value;
    await _settingsService.setHighlightSameNumbers(value);
    notifyListeners();
  }

  // 設定音效
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _settingsService.setSoundEnabled(value);
    notifyListeners();
  }

  // 設定震動
  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _settingsService.setVibrationEnabled(value);
    notifyListeners();
  }

  // 設定自動保存
  Future<void> setAutoSave(bool value) async {
    _autoSave = value;
    await _settingsService.setAutoSave(value);
    notifyListeners();
  }

  // 設定顯示計時器
  Future<void> setShowTimer(bool value) async {
    _showTimer = value;
    await _settingsService.setShowTimer(value);
    notifyListeners();
  }

  // 重置所有設定
  Future<void> resetAllSettings() async {
    await _settingsService.resetAllSettings();
    _highlightSameNumbers = true;
    _soundEnabled = true;
    _vibrationEnabled = true;
    _autoSave = true;
    _showTimer = true;
    notifyListeners();
  }

  // 切換醒目數字
  Future<void> toggleHighlightSameNumbers() async {
    await setHighlightSameNumbers(!_highlightSameNumbers);
  }

  // 切換音效
  Future<void> toggleSoundEnabled() async {
    await setSoundEnabled(!_soundEnabled);
  }

  // 切換震動
  Future<void> toggleVibrationEnabled() async {
    await setVibrationEnabled(!_vibrationEnabled);
  }

  // 切換自動保存
  Future<void> toggleAutoSave() async {
    await setAutoSave(!_autoSave);
  }

  // 切換顯示計時器
  Future<void> toggleShowTimer() async {
    await setShowTimer(!_showTimer);
  }
}
