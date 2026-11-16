import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

class PageBView extends GetView {
  const PageBView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Page B')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LegacyText('Welcome to Page B'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const LegacyText('Back to Page A'),
            ),
          ],
        ),
      ),
    );
  }
}
