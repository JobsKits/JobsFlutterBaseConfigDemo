// 独立运行：flutter run -t "lib/demos/系统剪贴板与邀请码/NativeClipboard.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/通用点击组件/CommonRipple.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:oktoast/oktoast.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '系统剪贴板与邀请码');

void legacyOriginalMain() => legacyCaptureApp(
  OKToast(
    child: JobsMaterialRunner.builder(
      title: '点击按钮@复制到剪切板',
      builder: (ctx) => buildInviteCode('123456'), // ← 延后到 ScreenUtilInit 之后再构建
    ),
  ),
);

Widget buildInviteCode(String inviteCode) {
  return SizedBox(
    width: 350.w, // 固定宽度
    height: 90.h, // 固定高度
    child: Material(
      // 给 InkWell 提供水波纹载体（不想水波纹可去掉或设为透明）
      color: Colors.transparent,
      child: CommonRipple(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: inviteCode));
          showToast(legacyControlLabelFallback("邀请码:$inviteCode已成功复制到剪切板"));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF00C2C7), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.max, // ✅ 撑满宽度
              mainAxisAlignment: MainAxisAlignment.center, // ✅ 水平居中
              crossAxisAlignment: CrossAxisAlignment.center, // ✅ 垂直居中
              children: [
                LegacyText(
                  "邀请码 ",
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: const Color(0xFF00C2C7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                LegacyText(
                  inviteCode,
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: const Color(0xFF00C2C7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  // 👈 不要用 IconButton，避免与外层 InkWell 冲突
                  Icons.copy,
                  size: 28.sp,
                  color: const Color(0xFF00C2C7),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class NativeClipboard {
  static const MethodChannel _channel = MethodChannel('custom/clipboard');

  static Future<void> setText(String text) async {
    try {
      await _channel.invokeMethod('setClipboard', {'text': text});
    } catch (e) {
      legacyDebugPrint('❌ 原生剪贴板写入失败: $e');
    }
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'NativeClipboard');
