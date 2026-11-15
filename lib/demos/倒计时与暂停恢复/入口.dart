import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/倒计时与暂停恢复/源码/CountdownBtn.dart'
    as old;

void main() => runApp(
  JobsDemoApp(
    title: '倒计时与暂停恢复',
    home: Builder(builder: buildLegacyDemo),
  ),
);

Widget buildLegacyDemo(BuildContext context) => Scaffold(
  appBar: AppBar(title: const LegacyText('倒计时与暂停恢复')),
  body: SafeArea(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          old.CountdownBtn(
            textFront: '倒计时 ',
            textBack: '',
            isVertical: true,
            duration: 60,
            autoStart: true,
            textStyle: Theme.of(context).textTheme.titleLarge!,
            timeStep: 1,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          const SizedBox(height: 24),
          old.CountdownBtn(
            textFront: '反向计时 ',
            textBack: '',
            isVertical: true,
            duration: 60,
            autoStart: true,
            textStyle: Theme.of(context).textTheme.titleLarge!,
            timeStep: -1,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ],
      ),
    ),
  ),
);
