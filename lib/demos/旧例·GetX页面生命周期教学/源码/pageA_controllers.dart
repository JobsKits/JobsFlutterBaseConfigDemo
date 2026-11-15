import 'package:get/get.dart';

class PageAControllers extends GetxController {
  final ok = true.obs;
  void reverse() {
    ok.value = !ok.value;
  }

  String changeText() {
    return "qqq";
  }
}
