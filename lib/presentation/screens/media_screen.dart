import 'dart:io';
import 'package:flutter/material.dart';
import 'package:incubator/core/constants/widget_size_constant.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:incubator/presentation/themes/text_style.dart';
import 'package:get/get.dart';
import '../../core/constants/color_constant.dart';
import '../../core/utils/text_files.dart';
import '../components/snackbar_helper.dart';
import '../controllers/experiment_controller.dart';
import '../controllers/media_controller.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen>
    with TickerProviderStateMixin {
  TextEditingController commentController = TextEditingController();
  final mediaController = Get.find<MediaController>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    commentController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return Scaffold(
      backgroundColor: Color(ColorConstant.screenBackground),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenSize.width * 0.02,
          vertical: ScreenSize.height * 0.01,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: ScreenSize.height * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(ScreenSize.height * 0.02),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(ScreenSize.height * 0.01),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF3498DB,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              ScreenSize.height * 0.01,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Color(0xFF3498DB),
                            size: ScreenSize.height * 0.025,
                          ),
                        ),
                        SizedBox(width: ScreenSize.width * 0.03),
                        Text(
                          TextFiles.media,
                          style: titleMedium.copyWith(
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => GestureDetector(
                      onTap:
                          mediaController.imagePath.value.isEmpty
                              ? () {
                                final isActive =
                                    Get.find<ExperimentController>()
                                        .isExperimentActive
                                        .value;
                                if (isActive) {
                                  Get.toNamed('/camera');
                                } else {
                                  SnackBarHelper.showError(
                                    message: TextFiles.exerciseErrorStart,
                                  );
                                }
                              }
                              : null,
                      child: Container(
                        width: double.infinity,
                        height: ScreenSize.height * 0.2,
                        margin: EdgeInsets.fromLTRB(
                          ScreenSize.height * 0.02,
                          0,
                          ScreenSize.height * 0.02,
                          ScreenSize.height * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color:
                              mediaController.imagePath.value.isEmpty
                                  ? const Color(0xFFF8F9FA)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                mediaController.imagePath.value.isEmpty
                                    ? const Color(0xFFE9ECEF)
                                    : Colors.transparent,
                            width: ScreenSize.width * 0.005,
                            style:
                                mediaController.imagePath.value.isEmpty
                                    ? BorderStyle.solid
                                    : BorderStyle.none,
                          ),
                        ),
                        child:
                            mediaController.imagePath.value.isEmpty
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF3498DB,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: ScreenSize.height * 0.06,
                                        color: const Color(0xFF3498DB),
                                      ),
                                    ),
                                    SizedBox(height: ScreenSize.height * 0.02),
                                    Text(
                                      TextFiles.mediaExplain,
                                      style: titleSmall.copyWith(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                )
                                : Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        ScreenSize.height *
                                            WidgetSizeConstant.borderCircular,
                                      ),
                                      child: Image.file(
                                        File(mediaController.imagePath.value),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    ScreenSize.height *
                                                        WidgetSizeConstant
                                                            .borderRadius,
                                                  ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 48,
                                                  color: Colors.grey[400],
                                                ),
                                                SizedBox(
                                                  height:
                                                      ScreenSize.height * 0.01,
                                                ),
                                                Text(
                                                  TextFiles.photoError,
                                                  style: labelLarge,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: ScreenSize.height * 0.01,
                                      right: ScreenSize.width * 0.015,
                                      child: Container(
                                        padding: EdgeInsets.all(
                                          ScreenSize.height * 0.005,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            ScreenSize.height *
                                                WidgetSizeConstant.borderRadius,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: ScreenSize.height * 0.03,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: ScreenSize.height * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(ScreenSize.height * 0.02),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(ScreenSize.height * 0.01),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF39C12,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              ScreenSize.height * 0.01,
                            ),
                          ),
                          child: Icon(
                            Icons.edit_note,
                            color: const Color(0xFFF39C12),
                            size: ScreenSize.height * 0.025,
                          ),
                        ),
                        SizedBox(width: ScreenSize.width * 0.03),
                        Text(
                          TextFiles.addComments,
                          style: titleMedium.copyWith(
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: ScreenSize.height * 0.15,
                    margin: EdgeInsets.fromLTRB(
                      ScreenSize.height * 0.02,
                      0,
                      ScreenSize.height * 0.02,
                      ScreenSize.height * 0.02,
                    ),
                    padding: EdgeInsets.all(ScreenSize.width * 0.04),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE9ECEF),
                        width: ScreenSize.width * 0.005,
                      ),
                    ),
                    child: Obx(
                      () => TextField(
                        controller: commentController,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        style: labelLarge,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.top,
                        enabled:
                            Get.find<ExperimentController>()
                                .isExperimentActive
                                .value,
                        decoration: InputDecoration.collapsed(
                          hintText:
                              TextFiles.mediaComments ??
                              'Yorumunuzu buraya yazın...',
                          hintStyle: labelLarge.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              height: ScreenSize.height * 0.09,
              padding: EdgeInsets.all(ScreenSize.height * 0.01),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * 0.01,
                        ),
                        border: Border.all(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
                          width: ScreenSize.width * 0.005,
                        ),
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          mediaController.clearMedia();
                          commentController.clear();
                        },
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFE74C3C),
                          size: ScreenSize.height * 0.03,
                        ),
                        label: Text(
                          TextFiles.mediaDeleteBtn ?? 'Temizle',
                          style: titleLarge.copyWith(
                            color: const Color(0xFFE74C3C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          backgroundColor: const Color(
                            0xFFE74C3C,
                          ).withValues(alpha: 0.05),
                          foregroundColor: const Color(0xFFE74C3C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: ScreenSize.height * 0.018,
                            horizontal: ScreenSize.width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenSize.width * 0.04),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF27AE60,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: () {
                          mediaController.setComments(commentController.text);
                          mediaController.saveMedia();
                          commentController.clear();
                        },
                        icon: Icon(
                          Icons.save_alt_rounded,
                          color: Colors.white,
                          size: ScreenSize.height * 0.03,
                        ),
                        label: Text(
                          TextFiles.mediaSaveBtn ?? 'Kaydet',
                          style: titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: ScreenSize.height * 0.018,
                            horizontal: ScreenSize.width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
