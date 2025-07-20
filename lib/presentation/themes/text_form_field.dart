import 'package:flutter/material.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:incubator/presentation/themes/text_style.dart';

class FormInputDecoration {
  static InputDecoration inputField({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      errorStyle: titleMedium,
      errorMaxLines: 2,
      isDense: true,
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: ScreenSize.height * 0.001),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      hintText: hintText,
      hintStyle: TextStyle(color: Color(0xD9D5D5CC)),
      prefixIcon: Icon(
        icon,
        size: ScreenSize.height * 0.04,
        color: Colors.white,
      ),
    );
  }
}
