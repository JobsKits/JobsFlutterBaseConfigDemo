import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRunners/JobsMaterialRunner.dart';

import 'http_demo_page.dart';

void main() {
  runApp(
    JobsMaterialRunner(
      const HttpDemoPage(),
      title: 'HTTP Methods Demo',
    ),
  );
}
