import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/本地数据存取/sp_util.dart';
import 'package:vibration/vibration.dart';

class AppManager {
  RxBool isVibrationEnabled = true.obs; // 是否开启震动
  bool isUpdatingBaseUrl = false; // 是否正在更新baseUrl
  bool isFront = true; // App是否处于前台

  AppManager._privateConstructor() {
    _initialize();
  }

  void _initialize() async {
    bool? enabled = SpUtil.getBool('VibrationEnabled');
    if (enabled == null) {
      await SpUtil.setBool('VibrationEnabled', true);
      isVibrationEnabled.value = true;
    } else {
      isVibrationEnabled.value = enabled;
    }
  }

  static final AppManager instance = AppManager._privateConstructor();

  void vibrationChanged(bool value) {
    isVibrationEnabled.value = value;
    SpUtil.setBool('VibrationEnabled', value);
  }

  void tapVibrate() {
    if (isVibrationEnabled.value) {
      // print('震动');
      Vibration.vibrate(duration: 30, amplitude: 80);
    }
  }

  Future<bool> checkNetwork() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    // print('connectivityResult: ${connectivityResult}');
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  Future<void> updateBaseUrl() async {
    if (isUpdatingBaseUrl) return;
    bool hasNetwork = await AppManager.instance.checkNetwork();
    if (!hasNetwork) {
      EasyLoading.show(
        status: '网络未连接，请检查您的网络设置'.tr,
        maskType: EasyLoadingMaskType.black,
      );
      return;
    }

    isUpdatingBaseUrl = true;
    // print('选中域名: ${ns.baseURL}');
    isUpdatingBaseUrl = false;
  }

  // 注册登录保护
  Future<String> getToken1() async {
    // ignore: unused_local_variable
    String optionCode = '';
    if (Platform.isIOS) {
      optionCode = 'YIDUN_BUSINESS_ID_REGISTER_IOS'.tr;
    } else if (Platform.isAndroid) {
      optionCode = 'YIDUN_BUSINESS_ID_REGISTER_ANDROID'.tr;
    }
    return '';
  }
}
