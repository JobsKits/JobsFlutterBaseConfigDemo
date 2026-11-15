import 'package:get/get.dart';

/// 逻辑
class CounterController extends GetxController {
  final count = 0.obs;
  void increment() => count.value++;
}
