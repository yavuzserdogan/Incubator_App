import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:incubator/presentation/themes/text_style.dart';
import '../../core/constants/widget_size_constant.dart';
import '../controllers/experiment_controller.dart';
import '../controllers/media_controller.dart';
import 'package:incubator/domain/entities/exercises_entity.dart';
import 'package:incubator/domain/entities/media_entity.dart';

class ExperimentDetailsScreen extends StatefulWidget {
  const ExperimentDetailsScreen({super.key});

  @override
  State<ExperimentDetailsScreen> createState() =>
      _ExperimentDetailsScreenState();
}

class _ExperimentDetailsScreenState extends State<ExperimentDetailsScreen> {
  final ExperimentController experimentController =
      Get.find<ExperimentController>();
  late final MediaController mediaController;
  String? exerciseId;
  Exercises? experiment;
  List<Media> mediaList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mediaController = Get.find<MediaController>();
    final args = Get.arguments;

    if (args == null || args is! String) {
      print('ExperimentDetailsScreen - Invalid arguments: $args');
      errorMessage = "Gerekli parametre eksik";
      Get.back();
      return;
    }

    exerciseId = args;
    print('ExperimentDetailsScreen - Set exerciseId to: $exerciseId');
    mediaController.setCurrentExerciseId(exerciseId!);
    _loadData();
  }

  Future<void> _loadData() async {
    if (exerciseId == null) {
      print('ExperimentDetailsScreen - exerciseId is null');
      errorMessage = "Deney ID'si bulunamadı";
      setState(() {});
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      setState(() {});
      experiment = await experimentController.getExerciseById(exerciseId!);

      if (experiment == null) {
        errorMessage = "Deney bulunamadı";
        setState(() {});
        return;
      }

      await mediaController.fetchLocalMedias();
    } catch (e) {
      print('ExperimentDetailsScreen - Error loading data: $e');
      errorMessage = "Veriler yüklenirken bir hata oluştu: $e";
    } finally {
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  String formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    SizedBox smallWidth = SizedBox(width: ScreenSize.width * 0.03);
    SizedBox smallHeight = SizedBox(height: ScreenSize.height * 0.015);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          'Deney Detayları',
          style: headlineMedium.copyWith(
            color: const Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(ScreenSize.height * 0.004),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ScreenSize.height * WidgetSizeConstant.borderCircular,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: ScreenSize.height * WidgetSizeConstant.iconSize,
              color: Color(0xFF2C3E50),
            ),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(ScreenSize.height * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * WidgetSizeConstant.borderCircular,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3498DB),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: ScreenSize.height * 0.02),
                    Text(
                      'Veriler yükleniyor...',
                      style: titleLarge.copyWith(
                        color: const Color(0xFF7F8C8D),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
              : errorMessage != null
              ? Center(
                child: Container(
                  margin: EdgeInsets.all(ScreenSize.height * 0.02),
                  padding: EdgeInsets.all(ScreenSize.height * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ScreenSize.height * WidgetSizeConstant.borderCircular,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: ScreenSize.height * WidgetSizeConstant.iconSize,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                      SizedBox(height: ScreenSize.height * 0.05),
                      Text(
                        errorMessage!,
                        style: titleLarge.copyWith(
                          color: const Color(0xFF2C3E50),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Geri Dön',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(ScreenSize.height * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ScreenSize.height * 0.01),
                      margin: EdgeInsets.only(bottom: ScreenSize.height * 0.02),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                        ),
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * WidgetSizeConstant.borderCircular,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3498DB,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                  ScreenSize.height * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                    ScreenSize.height *
                                        WidgetSizeConstant.borderCircular,
                                  ),
                                ),
                                child: Icon(
                                  Icons.science,
                                  color: Colors.white,
                                  size:
                                      ScreenSize.height *
                                      WidgetSizeConstant.iconSize,
                                ),
                              ),
                              SizedBox(width: ScreenSize.width * 0.03),
                              Expanded(
                                child: Text(
                                  experiment?.title ?? 'Deney',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Experiment Info Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ScreenSize.height * 0.01),
                      margin: EdgeInsets.only(bottom: ScreenSize.height * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * WidgetSizeConstant.borderCircular,
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
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                  ScreenSize.height * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF27AE60,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    ScreenSize.height *
                                        WidgetSizeConstant.borderCircular,
                                  ),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF27AE60),
                                  size:
                                      ScreenSize.height *
                                      WidgetSizeConstant.smallIconSize,
                                ),
                              ),
                              smallWidth,
                              Text(
                                'Deney Bilgileri',
                                style: titleLarge.copyWith(
                                  color: const Color(0xFF2C3E50),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          smallHeight,
                          _buildInfoRow(
                            Icons.title,
                            'Başlık',
                            experiment!.title,
                          ),
                          smallHeight,
                          _buildInfoRow(
                            Icons.play_circle_outline,
                            'Başlangıç',
                            formatDate(experiment!.startDateTime),
                          ),
                          smallHeight,
                          _buildInfoRow(
                            Icons.stop_circle_outlined,
                            'Bitiş',
                            experiment!.endDateTime.isEmpty
                                ? "Devam ediyor"
                                : formatDate(experiment!.endDateTime),
                            isOngoing: experiment!.endDateTime.isEmpty,
                          ),
                        ],
                      ),
                    ),

                    // Media Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ScreenSize.height * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * WidgetSizeConstant.borderCircular,
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
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(
                                  ScreenSize.height * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF9B59B6,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    ScreenSize.height *
                                        WidgetSizeConstant.borderCircular,
                                  ),
                                ),
                                child: Icon(
                                  Icons.photo_library_outlined,
                                  color: Color(0xFF9B59B6),
                                  size: ScreenSize.height * 0.025,
                                ),
                              ),
                              smallWidth,
                              Text(
                                'Medya ve Yorumlar',
                                style: titleLarge.copyWith(
                                  color: const Color(0xFF2C3E50),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenSize.height * 0.02),
                          Obx(
                            () =>
                                mediaController.mediaList.isEmpty
                                    ? Container(
                                      padding: EdgeInsets.all(
                                        ScreenSize.height * 0.05,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(
                                          ScreenSize.height *
                                              WidgetSizeConstant.borderCircular,
                                        ),
                                        border: Border.all(
                                          color: Color(0xFFE9ECEF),
                                          width: ScreenSize.width * 0.005,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.photo_library_outlined,
                                            size: ScreenSize.height * 0.05,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(
                                            height: ScreenSize.height * 0.01,
                                          ),
                                          Text(
                                            'Henüz medya eklenmemiş',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : Column(
                                      children:
                                          mediaController.mediaList
                                              .map(
                                                (media) =>
                                                    _buildMediaCard(media),
                                              )
                                              .toList(),
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isOngoing = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(ScreenSize.height * 0.008),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
          ),
          child: Icon(
            icon,
            size: ScreenSize.height * 0.02,
            color: const Color(0xFF3498DB),
          ),
        ),
        SizedBox(width: ScreenSize.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: ScreenSize.height * 0.001),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: titleLarge.copyWith(
                        color: const Color(0xFF2C3E50),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isOngoing)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenSize.width * 0.03,
                        vertical: ScreenSize.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * WidgetSizeConstant.borderCircular,
                        ),
                      ),
                      child: const Text(
                        'Aktif',
                        style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaCard(Media media) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.height * 0.01),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (media.filePath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderCircular,
                ),
                topRight: Radius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderCircular,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: ScreenSize.height * 0.25,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: Image.file(
                  File(media.filePath),
                  width: double.infinity,
                  height: ScreenSize.height * 0.1,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: ScreenSize.height * 0.1,
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size:
                                ScreenSize.height * WidgetSizeConstant.iconSize,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: ScreenSize.height * 0.01),
                          Text(
                            'Görsel yüklenemedi',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(ScreenSize.height * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ScreenSize.height * 0.01),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF39C12).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.comment_outlined,
                        size: ScreenSize.height * 0.025,
                        color: Color(0xFFF39C12),
                      ),
                    ),
                    SizedBox(width: ScreenSize.width * 0.02),
                    const Text(
                      'Yorum',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenSize.height * 0.01),
                Text(
                  media.comments.isEmpty ? 'Yorum eklenmemiş' : media.comments,
                  style: titleSmall.copyWith(
                    color:
                        media.comments.isEmpty
                            ? const Color(0xFFBDC3C7)
                            : const Color(0xFF2C3E50),
                    fontSize: 14,
                    fontStyle: media.comments.isEmpty ? FontStyle.italic : null,
                  ),
                ),
                 SizedBox(height: ScreenSize.height*0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: ScreenSize.height*0.05,
                      width: ScreenSize.width*0.1,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {
                          mediaController.editMedia(
                            media.mediaId,
                            media.comments,
                          );
                        },
                        icon:  Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF3498DB),
                          size: ScreenSize.height*0.03,
                        ),
                        tooltip: 'Düzenle',
                      ),
                    ),
                     SizedBox(width: ScreenSize.width*0.02),
                    Container(
                      height: ScreenSize.height*0.05,
                      width: ScreenSize.width*0.1,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(  ScreenSize.height * WidgetSizeConstant.borderCircular),
                      ),
                      child: IconButton(
                        onPressed: () {
                          mediaController.deleteMedia(media.mediaId);
                        },
                        icon:  Icon(
                          Icons.delete_outline,
                          color: Color(0xFFE74C3C),
                          size: ScreenSize.height*0.03,
                        ),
                        tooltip: 'Sil',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
