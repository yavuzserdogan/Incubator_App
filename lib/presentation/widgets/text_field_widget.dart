import 'package:flutter/material.dart';
import '../../core/utils/screen_size.dart';
import '../themes/text_style.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ScreenSize.width * 0.04),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: ScreenSize.width * 0.001,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        textInputAction: TextInputAction.done,
        textAlignVertical: TextAlignVertical.center,
        style: titleSmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: titleSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(
              left: ScreenSize.width * 0.05,
              right: ScreenSize.width * 0.03,
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.7),
              size: ScreenSize.width * 0.055,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenSize.width * 0.04,
            vertical: ScreenSize.height * 0.02,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
