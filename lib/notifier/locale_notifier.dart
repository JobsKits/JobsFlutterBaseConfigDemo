import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/本地数据存取/sp_util.dart';

/// Provider 语言切换通知器
class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('zh');
  Locale get locale => _locale;

  LocaleNotifier() {
    _load();
  }

  void _load() {
    final langCode = SpUtil.getString('app_language');
    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  void updateLocale(Locale locale) {
    _locale = locale;
    SpUtil.setString('app_language', locale.languageCode);
    notifyListeners();
  }
}
