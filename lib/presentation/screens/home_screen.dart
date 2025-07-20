import 'package:flutter/material.dart';
import 'package:incubator/core/constants/color_constant.dart';
import 'package:incubator/core/constants/widget_size_constant.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:incubator/core/utils/text_files.dart';
import 'package:incubator/presentation/themes/experiment_card.dart';
import 'package:get/get.dart';
import 'package:incubator/presentation/themes/text_style.dart';
import '../controllers/experiment_controller.dart';
import '../controllers/media_controller.dart';
import '../controllers/page_controller.dart';
import 'data_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final experimentController = Get.find<ExperimentController>();
  final mediaController = Get.find<MediaController>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(ColorConstant.gradientColorsFirst),
              Color(ColorConstant.gradientColorsSecond),
              Color(ColorConstant.gradientColorsFirst),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (experimentController.experiments.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildExperimentsList();
                }),
              ),
            ],
          ),
        ),
      ),

      // Premium FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.indigo.shade600],
          ),
          borderRadius: BorderRadius.circular(
            ScreenSize.height * WidgetSizeConstant.borderRadius,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showCreateExperimentDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            TextFiles.newExercise,
            style: labelLarge.copyWith(color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    ScreenSize.init(context);
    final SizedBox mediumConstBox = SizedBox(height: ScreenSize.height * 0.04);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(ScreenSize.height * 0.02),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(
                ScreenSize.height * WidgetSizeConstant.borderRadius,
              ),
            ),
            child: Icon(
              Icons.science_outlined,
              size: ScreenSize.height * 0.07,
              color: Colors.grey.shade400,
            ),
          ),
          mediumConstBox,
          Text(
            TextFiles.emptyHomeScreen,
            style: titleSmall.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          mediumConstBox,
          Text(
            TextFiles.newExerciseDetails,
            style: labelLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExperimentsList() {
    final SizedBox smallConstBox = SizedBox(height: ScreenSize.height * 0.02);
    final SizedBox mediumConstBox = SizedBox(height: ScreenSize.height * 0.04);
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenSize.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextFiles.endExercises,
            style: titleLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w800,
            ),
          ),
          mediumConstBox,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: experimentController.experiments.length,
            separatorBuilder: (context, index) => smallConstBox,
            itemBuilder: (context, index) {
              final experiment = experimentController.experiments[index];
              return ExperimentCard(
                title: experiment.title,
                startDate: formatDate(experiment.startDateTime),
                endDate:
                    experiment.endDateTime.isEmpty
                        ? TextFiles.exercisesStatus
                        : formatDate(experiment.endDateTime),
                exerciseId: experiment.exerciseId,
                onDelete:
                    (exerciseId) =>
                        experimentController.deleteExercise(exerciseId),
                onEdit:
                    (exerciseId, title) =>
                        experimentController.editExercise(exerciseId, title),
              );
            },
          ),
          SizedBox(height: ScreenSize.height * 0.08),
        ],
      ),
    );
  }

  void _showCreateExperimentDialog() {
    _textController.clear();
    ScreenSize.init(context);
    final SizedBox smallConstBox = SizedBox(height: ScreenSize.height * 0.02);
    final SizedBox smallConstBoxRow = SizedBox(width: ScreenSize.width * 0.02);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScreenSize.height * WidgetSizeConstant.borderRadius,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(ScreenSize.height * 0.02),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderRadius,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ScreenSize.height * 0.005),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ScreenSize.height * 0.01,
                      ),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.indigo.shade600,
                      size: ScreenSize.height * 0.03,
                    ),
                  ),
                  smallConstBoxRow,
                  Text(
                    TextFiles.newExercises,
                    style: titleLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              smallConstBox,
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(
                    ScreenSize.height * WidgetSizeConstant.borderRadius,
                  ),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: TextFiles.nameExercises,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(ScreenSize.height * 0.01),
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                  ),
                  onChanged: (value) {
                    experimentController.experimentTitle.value = value;
                  },
                ),
              ),
              smallConstBox,
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _textController.clear();
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenSize.height * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenSize.height * 0.01,
                          ),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        TextFiles.cancelExercises,
                        style: labelLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  smallConstBoxRow,
                  Expanded(
                    child: Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          gradient:
                              experimentController.experimentTitle.value.isEmpty
                                  ? null
                                  : LinearGradient(
                                    colors: [
                                      Colors.indigo.shade400,
                                      Colors.indigo.shade600,
                                    ],
                                  ),
                          color:
                              experimentController.experimentTitle.value.isEmpty
                                  ? Colors.grey.shade300
                                  : null,
                          borderRadius: BorderRadius.circular(
                            ScreenSize.height *
                                WidgetSizeConstant.borderCircular,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              ScreenSize.height *
                                  WidgetSizeConstant.borderCircular,
                            ),
                            onTap:
                                experimentController
                                        .experimentTitle
                                        .value
                                        .isEmpty
                                    ? null
                                    : () async {
                                      FocusScope.of(context).unfocus();
                                      final startTime =
                                          DateTime.now()
                                              .toUtc()
                                              .toIso8601String();
                                      experimentController.startExperiment(
                                        title:
                                            experimentController
                                                .experimentTitle
                                                .value,
                                        startTime: startTime,
                                      );

                                      _textController.clear();
                                      Get.back();
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      Get.find<PagesController>().changeWidget(
                                        DataScreen(),
                                        1,
                                      );
                                    },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: ScreenSize.height * 0.015,
                              ),
                              child: Center(
                                child: Text(
                                  TextFiles.startExercises,
                                  style: TextStyle(
                                    color:
                                        experimentController
                                                .experimentTitle
                                                .value
                                                .isEmpty
                                            ? Colors.grey.shade500
                                            : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
