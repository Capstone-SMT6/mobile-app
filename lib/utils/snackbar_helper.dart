import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar({
  required String title,
  required String message,
  required Color backgroundColor,
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    borderRadius: 0,
    margin: EdgeInsets.zero,
    snackStyle: SnackStyle.GROUNDED,
    backgroundColor: backgroundColor,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}
