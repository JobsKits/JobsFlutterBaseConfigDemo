import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRunners/JobsMaterialRunner.dart';

import 'dio_demo_page.dart';

void main() =>
    runApp(JobsMaterialRunner(const DioDemoPage(), title: 'HTTP Methods Demo'));
