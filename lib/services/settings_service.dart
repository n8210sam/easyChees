import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _highlightSameNumbersKey = 'highlight_same_numbers';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _autoSaveKey = 'auto_save';
  static const String _showTimerKey = 'show_timer';

  // 醒目數字設定
  Future<bool> getHighlightSameNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_highlightSameNumbersKey) ?? true; // 預設開啟
  }

  Future<void> setHighlightSameNumbers(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highlightSameNumbersKey, value);
  }

  // 音效設定
  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  // 震動設定
  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, value);
  }

  // 自動保存設定
  Future<bool> getAutoSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSaveKey) ?? true;
  }

  Future<void> setAutoSave(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveKey, value);
  }

  // 顯示計時器設定
  Future<bool> getShowTimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showTimerKey) ?? true;
  }

  Future<void> setShowTimer(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTimerKey, value);
  }

  // 重置所有設定
  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_highlightSameNumbersKey);
    await prefs.remove(_soundEnabledKey);
    await prefs.remove(_vibrationEnabledKey);
    await prefs.remove(_autoSaveKey);
    await prefs.remove(_showTimerKey);
  }

  // 獲取所有設定
  Future<Map<String, bool>> getAllSettings() async {
    return {
      'highlightSameNumbers': await getHighlightSameNumbers(),
      'soundEnabled': await getSoundEnabled(),
      'vibrationEnabled': await getVibrationEnabled(),
      'autoSave': await getAutoSave(),
      'showTimer': await getShowTimer(),
    };
  }
}
