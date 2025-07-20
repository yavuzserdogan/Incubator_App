import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/core/utils/screen_size.dart';

class FooterSectionWidget extends StatelessWidget {
  final String navigationRoute;
  final String textButtonName;

  const FooterSectionWidget({
    super.key,
    required this.navigationRoute, required this.textButtonName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: ScreenSize.height * 0.02),
        TextButton(
          onPressed: () => Get.toNamed(navigationRoute),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenSize.width * 0.06,
              vertical: ScreenSize.height * 0.015,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                textButtonName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: ScreenSize.width * 0.04,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(width: ScreenSize.width * 0.02),
              Icon(
                Icons.login_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: ScreenSize.width * 0.045,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
