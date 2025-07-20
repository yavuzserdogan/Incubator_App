import 'package:flutter/material.dart';
import '../../core/constants/widget_size_constant.dart';
import '../../core/utils/screen_size.dart';

class RegisterButtonStyles {
  static ButtonStyle elevatedButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenSize.width * 0.15,
        vertical: ScreenSize.height * 0.01,
      ),
      backgroundColor: const Color(0xFF1B56FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ScreenSize.height * WidgetSizeConstant.borderCircular,
        ),
      ),
      elevation: 5,
    );
  }
}
