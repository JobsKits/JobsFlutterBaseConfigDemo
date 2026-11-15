import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static AppLocalizations? _instance;
  static AppLocalizations get instance => _instance ??= AppLocalizations();

  static const List<String> supportedLocales = ['zh', 'en', 'ja'];

  String get hello {
    switch (Intl.getCurrentLocale()) {
      case 'zh':
        return '你好';
      case 'ja':
        return 'こんにちは';
      case 'en':
      default:
        return 'Hello';
    }
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final previous = Intl.defaultLocale;
    legacyOnDispose(() => Intl.defaultLocale = previous);
    Intl.defaultLocale = locale.languageCode;
    return AppLocalizations.instance;
  }

  @override
  // AppLocalizationsDelegate 不需要在 Locale 改变时重新加载本地化资源。
  // 这通常用于静态资源的本地化，因为它们在应用生命周期内不需要改变。
  // 如果有动态内容或需要重新加载资源，可以根据需要将其设置为 true。
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

List<PopupMenuItem<Locale>> getLocaleMenuItems() {
  return AppLocalizations.supportedLocales.map((String code) {
    return PopupMenuItem<Locale>(
      value: Locale(code),
      child: LegacyText(code.toUpperCase()),
    );
  }).toList();
}
