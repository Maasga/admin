import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeEnum { light, dark }

class ThemeModeNotifier extends Notifier<ThemeModeEnum> {
  static const String _prefKey = 'theme_mode';

  @override
  ThemeModeEnum build() {
    _loadThemeMode();
    return ThemeModeEnum.light;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_prefKey);
    if (savedMode != null) {
      state = savedMode == 'dark' ? ThemeModeEnum.dark : ThemeModeEnum.light;
    }
  }

  Future<void> setThemeMode(ThemeModeEnum mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeModeEnum.light
        ? ThemeModeEnum.dark
        : ThemeModeEnum.light;
    await setThemeMode(newMode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeModeEnum>(
  ThemeModeNotifier.new,
);

final themeModeProviderWrapper = Provider<ThemeMode>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode == ThemeModeEnum.dark ? ThemeMode.dark : ThemeMode.light;
});
