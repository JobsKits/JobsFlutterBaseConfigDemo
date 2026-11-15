import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demos/旧例·HTML富文本表格/源码/BonusHtmlTableView.dart'
    as source;

void main() => launchLegacyStandalone(
  source.legacyOriginalMain,
  title: 'BonusHtmlTableView',
);

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: source.legacyOriginalMain,
  title: 'BonusHtmlTableView',
);
