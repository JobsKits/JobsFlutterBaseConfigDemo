import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/本地数据存取/sp_util.dart';

/// 自动切换主题、跟随系统
class ThemeService {
  static final ThemeService instance = ThemeService._();
  ThemeService._();

  static const _themeKey = 'theme_mode';
  ThemeMode themeMode = ThemeMode.system;

  final ThemeData lightTheme = ThemeData.light(useMaterial3: true);
  final ThemeData darkTheme = ThemeData.dark(useMaterial3: true);

  Future<void> init() async {
    final index = SpUtil.getInt(_themeKey);
    if (index != null) {
      themeMode = ThemeMode.values[index];
    }
  }

  void updateTheme(ThemeMode mode) {
    themeMode = mode;
    SpUtil.setInt(_themeKey, mode.index);
  }
}
