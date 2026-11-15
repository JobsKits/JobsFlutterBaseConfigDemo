import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

List<PopupMenuEntry<Locale>> getLocaleMenuItems() {
  return const <PopupMenuEntry<Locale>>[
    PopupMenuItem<Locale>(value: Locale('zh', ''), child: LegacyText('中文')),
    PopupMenuItem<Locale>(
      value: Locale('en', ''),
      child: LegacyText('English'),
    ),
    PopupMenuItem<Locale>(value: Locale('ja', ''), child: LegacyText('日本語')),
  ];
}
