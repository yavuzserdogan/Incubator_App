import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/presentation/screens/experiment_details_screen.dart';
import '../../core/constants/widget_size_constant.dart';
import '../../core/utils/screen_size.dart';
import '../../core/utils/text_files.dart';
import '../components/snackbar_helper.dart';

class ExperimentCard extends StatelessWidget {
  final String title;
  final String startDate;
  final String endDate;
  final String exerciseId;
  final Function(String) onDelete;
  final Function(String, String) onEdit;

  const ExperimentCard({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.exerciseId,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    final bool isActive = endDate == TextFiles.exercisesStatus;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.height * 0.01),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            ScreenSize.height * WidgetSizeConstant.borderCircular,
          ),
          onTap: () {
            Get.to(
              () => const ExperimentDetailsScreen(),
              arguments: exerciseId,
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: Container(
            padding: EdgeInsets.all(ScreenSize.height * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Status Indicator
                    Container(
                      padding: EdgeInsets.all(ScreenSize.height * 0.01),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * WidgetSizeConstant.borderCircular,
                        ),
                      ),
                      child: Icon(
                        isActive
                            ? Icons.play_circle_filled
                            : Icons.check_circle,
                        color:
                            isActive
                                ? Colors.green.shade600
                                : Colors.grey.shade600,
                        size: ScreenSize.height * 0.02,
                      ),
                    ),
                    SizedBox(width: ScreenSize.width * 0.03),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ScreenSize.height * 0.005),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenSize.width * 0.01,
                              vertical: ScreenSize.height * 0.001,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                ScreenSize.height *
                                    WidgetSizeConstant.borderCircular,
                              ),
                            ),
                            child: Text(
                              isActive ? "Devam Ediyor" : "Tamamlandı",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    isActive
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * WidgetSizeConstant.borderCircular,
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        borderRadius: BorderRadius.circular(
                          ScreenSize.height * WidgetSizeConstant.borderCircular,
                        ),
                        color: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenSize.height *
                                WidgetSizeConstant.borderCircular,
                          ),
                        ),
                        onSelected: (value) {
                          if (isActive) {
                            SnackBarHelper.showError(
                              message: TextFiles.exerciseErrorStop,
                            );
                            return;
                          }

                          if (value == 'edit') {
                            _showEditDialog(context);
                          } else if (value == 'delete') {
                            _showDeleteDialog(context);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: ScreenSize.height * 0.02,
                                      color: Colors.blue.shade600,
                                    ),
                                    SizedBox(width: ScreenSize.width * 0.01),
                                    const Text(
                                      'Düzenle',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: ScreenSize.height * 0.02,
                                      color: Colors.red.shade600,
                                    ),
                                    SizedBox(width: ScreenSize.width * 0.01),
                                    const Text(
                                      'Sil',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        child: Container(
                          padding: EdgeInsets.all(ScreenSize.height * 0.005),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.grey.shade600,
                            size: ScreenSize.height * 0.03,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ScreenSize.height * 0.02),

                // Date Information
                Container(
                  padding: EdgeInsets.all(ScreenSize.height * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(
                      ScreenSize.height * WidgetSizeConstant.borderCircular,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Start Date
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(ScreenSize.height * 0.003),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                ScreenSize.height *
                                    WidgetSizeConstant.borderCircular,
                              ),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: ScreenSize.height * 0.02,
                              color: Colors.green.shade600,
                            ),
                          ),
                          SizedBox(width: ScreenSize.width * 0.01),
                          Text(
                            TextFiles.startDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            startDate,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),

                      if (!isActive) ...[
                        SizedBox(height: ScreenSize.height * 0.01),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                ScreenSize.height * 0.003,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  ScreenSize.height *
                                      WidgetSizeConstant.borderCircular,
                                ),
                              ),
                              child: Icon(
                                Icons.stop,
                                size: 16,
                                color: Colors.red.shade600,
                              ),
                            ),
                            SizedBox(width: ScreenSize.width * 0.03),
                            Text(
                              TextFiles.endDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              endDate,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Active indicator
                if (isActive) ...[
                  SizedBox(height: ScreenSize.height * 0.02),
                  Row(
                    children: [
                      Container(
                        width: ScreenSize.width * 0.02,
                        height: ScreenSize.height * 0.01,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(
                            ScreenSize.height *
                                WidgetSizeConstant.borderCircular,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenSize.width * 0.02),
                      Text(
                        TextFiles.continues,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController editController = TextEditingController(
      text: title,
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(ScreenSize.height * 0.01),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ScreenSize.height * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ScreenSize.height * WidgetSizeConstant.borderCircular,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.blue.shade600,
                      size: ScreenSize.height * 0.02,
                    ),
                  ),
                  SizedBox(width: ScreenSize.width * 0.03),
                  Text(
                    "Deney Düzenle",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenSize.height * .02),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(
                    ScreenSize.height * WidgetSizeConstant.borderCircular,
                  ),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: editController,
                  decoration: InputDecoration(
                    labelText: "Deney Adı",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(ScreenSize.height * 0.01),
                  ),
                ),
              ),
              SizedBox(height: ScreenSize.height * 0.02),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "İptal",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenSize.width * 0.01),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onEdit(exerciseId, editController.text);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenSize.height *
                                WidgetSizeConstant.borderCircular,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Kaydet",
                        style: TextStyle(color: Colors.white),
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

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScreenSize.height * WidgetSizeConstant.borderCircular,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(ScreenSize.height * 0.02),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(ScreenSize.height * 0.02),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ScreenSize.height * 0.05),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade600,
                  size: ScreenSize.height * 0.04,
                ),
              ),
              SizedBox(height: ScreenSize.height * 0.02),
              Text(
                "Deneyi Sil",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: ScreenSize.height * 0.01),
              Text(
                "Bu deneyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              SizedBox(height: ScreenSize.height * 0.02),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "İptal",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenSize.width * 0.01),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onDelete(exerciseId);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScreenSize.height *
                                WidgetSizeConstant.borderCircular,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Sil",
                        style: TextStyle(color: Colors.white),
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
