import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'dart:async';
import '../安全加载图片/JobsSafeImage.dart';

void main() => runApp(const JobsMaterialRunner(MyButton(), title: 'XXX'));

class JobsAlertDialog extends StatefulWidget {
  final bool autoDismiss;
  final int autoDismissDuration;
  final String title;
  final String subtitle;
  final double titleSubtitleSpacing;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final InlineSpan? titleRichText;
  final InlineSpan? subtitleRichText;
  final bool barrierDismissible;
  final TextAlign titleTextAlign;
  final TextAlign subtitleTextAlign;
  final List<Widget>? actions;
  final List<TextStyle>? actionTextStyles;
  final List<VoidCallback>? actionCallbacks;
  final Color? backgroundColor;
  final EdgeInsets contentPadding;
  final ShapeBorder shape;

  const JobsAlertDialog({
    super.key,
    this.autoDismiss = false,
    this.autoDismissDuration = 2,
    this.title = '',
    this.subtitle = '',
    this.titleSubtitleSpacing = 8.0,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.titleRichText,
    this.subtitleRichText,
    this.barrierDismissible = false,
    this.titleTextAlign = TextAlign.center,
    this.subtitleTextAlign = TextAlign.center,
    this.actions,
    this.actionTextStyles,
    this.actionCallbacks,
    this.backgroundColor,
    this.contentPadding = const EdgeInsets.all(20),
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
  });

  static void show(
    BuildContext context, {
    bool autoDismiss = false,
    int autoDismissDuration = 2,
    String title = '',
    String subtitle = '',
    double titleSubtitleSpacing = 8.0,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    InlineSpan? titleRichText,
    InlineSpan? subtitleRichText,
    bool barrierDismissible = false,
    TextAlign titleTextAlign = TextAlign.center,
    TextAlign subtitleTextAlign = TextAlign.center,
    List<Widget>? actions,
    List<TextStyle>? actionTextStyles,
    List<VoidCallback>? actionCallbacks,
    Color? backgroundColor,
    EdgeInsets contentPadding = const EdgeInsets.all(20),
    ShapeBorder shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
  }) {
    /// 通用弹窗机制，可以接收一个 widget（通常是 AlertDialog）并显示在屏幕正中间。
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return JobsAlertDialog(
          autoDismiss: autoDismiss,
          autoDismissDuration: autoDismissDuration,
          title: title,
          subtitle: subtitle,
          titleSubtitleSpacing: titleSubtitleSpacing,
          titleTextStyle: titleTextStyle,
          subtitleTextStyle: subtitleTextStyle,
          titleRichText: titleRichText,
          subtitleRichText: subtitleRichText,
          barrierDismissible: barrierDismissible,
          titleTextAlign: titleTextAlign,
          subtitleTextAlign: subtitleTextAlign,
          actions: actions,
          actionTextStyles: actionTextStyles,
          actionCallbacks: actionCallbacks,
          backgroundColor: backgroundColor,
          contentPadding: contentPadding,
          shape: shape,
        );
      },
    );
  }

  @override
  State<JobsAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<JobsAlertDialog> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoDismiss) {
      /// 延迟执行异步任务的方法
      Future.delayed(Duration(seconds: widget.autoDismissDuration), () {
        /// mounted 是 State 类的属性。
        /// 它表示当前 State 是否仍然处于 widget 树中。
        /// 如果在 dispose() 之后尝试使用 context，会抛出异常。mounted 能避免这种问题。
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionButtons = [];

    if (widget.actions != null && widget.actions!.isNotEmpty) {
      for (int i = 0; i < widget.actions!.length; i++) {
        actionButtons.add(
          OutlinedButton(
            onPressed: () async {
              if (widget.actionCallbacks != null &&
                  i < widget.actionCallbacks!.length) {
                setState(() => isLoading = true);
                await Future.delayed(const Duration(seconds: 1));
                widget.actionCallbacks![i]();
              } else {
                Navigator.of(context).pop();
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white70),
            ),
            child: DefaultTextStyle(
              style: widget.actionTextStyles != null &&
                      i < widget.actionTextStyles!.length
                  ? widget.actionTextStyles![i]
                  : const TextStyle(),
              child: widget.actions![i],
            ),
          ),
        );
      }
    } else {
      actionButtons = [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
          ),
          child: const Text(
            '取消',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
          ),
          child: const Text('确定'),
        ),
      ];
    }

    return AlertDialog(
      backgroundColor:
          widget.backgroundColor ?? Colors.blueAccent.withOpacity(0.8),
      contentPadding: widget.contentPadding,
      shape: widget.shape,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.titleRichText != null
              ? RichText(text: widget.titleRichText!)
              : Text(
                  widget.title,
                  textAlign: widget.titleTextAlign,
                  style: widget.titleTextStyle ??
                      const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                ),
          SizedBox(height: widget.titleSubtitleSpacing),
          widget.subtitleRichText != null
              ? RichText(text: widget.subtitleRichText!)
              : Text(
                  widget.subtitle,
                  textAlign: widget.subtitleTextAlign,
                  style: widget.subtitleTextStyle ??
                      const TextStyle(fontSize: 16, color: Colors.white70),
                ),
        ],
      ),
      content: isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          : null,
      actions: isLoading ? null : actionButtons,
    );
  }
}

/// 测试入口按钮
/// 热重载（Hot Reload）不能改变 const 类的构造结构或字段列表。
class MyButton extends StatelessWidget {
  final String label;
  const MyButton({super.key, this.label = '测试按钮'});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          JobsAlertDialog.show(
            context,
            titleRichText: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: JobsSafeImage(
                    assetPath: 'assets/Images/flower.png',
                    width: 32,
                    height: 32,
                    fallback: const Icon(Icons.warning),
                  ),
                ),
                const TextSpan(
                  text: ' 温馨提示 ',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Image.network(
                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            subtitleRichText: const TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.info_outline, color: Colors.orange),
                ),
                TextSpan(
                  text: ' 是否继续操作？ ',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(Icons.help, color: Colors.orange),
                ),
              ],
            ),
            autoDismiss: false,
            barrierDismissible: true,
          );
        },
        child: const Text('显示对话框'),
      ),
    );
  }
}
