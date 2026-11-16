import 'package:get/get.dart';

/// 自动注册或获取 Controller（立即创建并返回）
/// 用法：
/// final MyController c = JobsFind(MyController());
T JobsFind<T extends GetxController>(T instance, {bool permanent = true}) {
  if (Get.isRegistered<T>()) {
    return Get.find<T>();
  } else {
    return Get.put<T>(instance, permanent: permanent);
  }
}
