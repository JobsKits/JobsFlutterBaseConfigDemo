import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

import 'http_demo_page.dart';

void main() {
  runApp(
    JobsMaterialRunner(
      const HttpDemoPage(),
      title: 'HTTP Methods Demo',
    ),
  );
}
