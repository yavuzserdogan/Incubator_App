import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/core/utils/screen_size.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final RxBool isLoading;

  const ButtonWidget({
    super.key,
    required this.onPressed,
    required this.label,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: ScreenSize.height * 0.07,
        child:
            isLoading.value
                ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      ScreenSize.width * 0.04,
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ScreenSize.width * 0.04,
                      ),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenSize.height * 0.02,
                    ),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(
                      Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  onPressed: onPressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: ScreenSize.width * 0.05),
                      SizedBox(width: ScreenSize.width * 0.02),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: ScreenSize.width * 0.045,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
