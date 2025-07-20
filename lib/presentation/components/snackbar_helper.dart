import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/core/utils/screen_size.dart';

import '../../core/utils/text_files.dart';

class SnackBarHelper {
  static void showInfo({
    required String message,
    Color backgroundColor = Colors.black45,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
  }) {
    Get.snackbar(
      TextFiles.info,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(Icons.info_outline, color: iconColor),
      snackPosition: SnackPosition.TOP,
      borderRadius: ScreenSize.width * 0.03,
      margin: EdgeInsets.all(ScreenSize.height * 0.01),
      duration: Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      overlayBlur: 3,
    );
  }

  static void showError({
    required String message,
    Color backgroundColor = Colors.black45,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
  }) {
    Get.snackbar(
      TextFiles.error,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(Icons.warning_outlined, color: iconColor),
      snackPosition: SnackPosition.TOP,
      borderRadius: ScreenSize.width * 0.03,
      margin: EdgeInsets.all(ScreenSize.height * 0.01),
      duration: Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      overlayBlur: 3,
    );
  }
}
