import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ClipboardUtil {
  /// 复制内容
  static void copy(String? text) {
    Clipboard.setData(ClipboardData(text: text ?? ''));
    EasyLoading.showSuccess('复制成功');
  }

  /// 获取内容
  static Future<String> paste() async {
    var clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData?.text ?? '';
  }
}
