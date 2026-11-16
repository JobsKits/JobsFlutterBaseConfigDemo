import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class FormController extends GetxController {
  final firstTextController = TextEditingController();
  final secondTextController = TextEditingController();
  var isButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    firstTextController.addListener(_validateForm);
    secondTextController.addListener(_validateForm);
  }

  void _validateForm() {
    isButtonEnabled.value =
        firstTextController.text.isNotEmpty &&
        secondTextController.text.isNotEmpty;
  }

  void onButtonPressed() {
    if (isButtonEnabled.value) {
      Vibration.vibrate();
      Get.snackbar('Success', 'Button Pressed and Phone Vibrated!');
    }
  }
}
