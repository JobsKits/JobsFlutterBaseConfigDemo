import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:async';

import 'package:flutter/material.dart';

class PopConfirmWrapper extends StatelessWidget {
  final Widget child;
  final String confirmMessage;

  const PopConfirmWrapper({
    super.key,
    required this.child,
    this.confirmMessage = '你确定要离开此页面吗？',
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Future.microtask(() async {
            if (!context.mounted) return;
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const LegacyText('确认返回？'),
                content: LegacyText(confirmMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const LegacyText('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const LegacyText('确定'),
                  ),
                ],
              ),
            );

            if (shouldPop == true && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      },
      child: child,
    );
  }
}
