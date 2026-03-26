import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() {
  runApp(
    const JobsMaterialRunner(
      Center(child: Text('Hello JobsRunners')),
      title: 'jobs_runners demo',
    ),
  );
}
