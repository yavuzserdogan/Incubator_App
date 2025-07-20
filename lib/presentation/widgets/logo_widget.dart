import 'package:flutter/material.dart';

import '../../core/utils/screen_size.dart';

class LogoWidget extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> scaleAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final String textInfo;

  const LogoWidget({
    super.key,
    required this.animationController,
    required this.scaleAnimation,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.textInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -slideAnimation.value.dy),
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Column(
                children: [
                  // Logo container
                  Container(
                    width: ScreenSize.width * 0.25,
                    height: ScreenSize.width * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        ScreenSize.width * 0.06,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.science_outlined,
                      size: ScreenSize.width * 0.12,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: ScreenSize.height * 0.03),

                  // Welcome text
                  Text(
                    textInfo,
                    style: TextStyle(
                      fontSize: ScreenSize.width * 0.035,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ScreenSize.height * 0.01),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
