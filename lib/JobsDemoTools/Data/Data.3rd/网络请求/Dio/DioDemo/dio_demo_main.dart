import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

import 'dio_demo_page.dart';

void main() =>
    runApp(JobsMaterialRunner(const DioDemoPage(), title: 'HTTP Methods Demo'));
