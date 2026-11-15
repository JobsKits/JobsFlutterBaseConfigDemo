import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';

class NetworkError {
  String tag;
  String key;
  String info;
  String info2; // 上报域名请求失败原因
  String level;
  String origin;
  int cmd;
  int code;
  bool logout;
  bool update;
  String time;

  NetworkError({
    this.tag = '',
    this.key = '',
    this.info = '',
    this.info2 = '',
    this.level = '',
    this.origin = '',
    this.cmd = 0,
    this.code = -1,
    this.logout = false,
    this.update = false,
  }) : time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()) {
    // final tenantStore = useTenantStore();
    if (info.contains('invalid_token')) {
      info = '亲，麻烦重新登录哦';
    } else if (info.contains('Request failed with status code 500')) {
      info = '网络不给力，请检查网络(500)';
    } else if (info.contains('Request failed with status code 502')) {
      info = '网络不给力，请检查网络(502)';
    } else if (info.contains('Error 503 Service Unavailable')) {
      info = '网络不给力，请检查网络(503)';
    } else if (info.contains('Request failed with status code 504')) {
      info = '网络不给力，请检查网络(504)';
    } else if (info.contains('timeout of 20000ms')) {
      info = '请求超时，请检查网络';
    } else if (info.contains('Error 400 Bad Request')) {
      info = '网络不给力，请重新尝试';
    } else if (info.contains('Network Error')) {
      info = '网络错误，请检查网络';
    } else {
      // print('err.info: $info');
      if (info.contains('访问限制')) {
        // tenantStore.setIPLimitStatus(true);
      }
      if (info.contains('系统维护中') ||
          ([371130, 370433].contains(cmd) &&
              (info.contains('数据为空') || info.contains('请求没有返回任何数据')))) {
        // tenantStore.setRepairStatus(true);
        // Get.offNamed(Routes.MAINTENANCE);
      }
    }
    // this.info = mb_t(this.info);
  }

  @override
  String toString() {
    // return mb_t(info);
    return info;
  }

  Map<String, dynamic> parseJson(String? msg) {
    if (msg == null || msg.isEmpty) {
      return {};
    }

    try {
      return json.decode(msg);
    } catch (e) {
      // 处理解析错误，可以记录日志或返回一个默认值
      debugPrint('解析 JSON 时出错: $e');
      return {};
    }
  }

  // 提示错误
  void toastError() {
    if (info != "") {
      if (info.contains('{')) {
        var infoMap = parseJson(info);
        if (infoMap['msg'] != null) {
          EasyLoading.showError("${infoMap['msg']}");
        } else {
          EasyLoading.showError(info);
        }
      } else {
        EasyLoading.showError(info);
      }
    }
  }

  void log() {
    // print('{code: $code, tag: $tag, info: $info, cmd_id: $cmd, time: $time}');
    toastError();
  }
}
