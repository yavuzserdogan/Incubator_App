import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/core/utils/screen_size.dart';
import '../../core/constants/widget_size_constant.dart';
import '../../core/utils/text_files.dart';
import '../../presentation/controllers/experiment_controller.dart';

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

Widget buildSensorCard(
  String title,
  String value,
  String optimum,
  Color color,
) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(ScreenSize.height * 0.02),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        ScreenSize.height * WidgetSizeConstant.borderCircular,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(ScreenSize.height * 0.01),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderCircular,
                ),
              ),
              child: Icon(_getSensorIcon(title), color: color, size: 20),
            ),
            SizedBox(width: ScreenSize.width * 0.02),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenSize.width * 0.035,
                vertical: ScreenSize.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderCircular,
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenSize.height * 0.02),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenSize.width * 0.01,
            vertical: ScreenSize.height * 0.01,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.temple_buddhist_sharp,
                size: ScreenSize.height * 0.02,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                "${TextFiles.dataOpt} $optimum",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildStatusTile(IconData icon, String label, String value) {
  return Container(
    padding: EdgeInsets.all(ScreenSize.height * 0.01),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        ScreenSize.height * WidgetSizeConstant.borderCircular,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(ScreenSize.height * 0.013),
          decoration: BoxDecoration(
            color: _getStatusColor(label).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
          ),
          child: Icon(icon, size: 24, color: _getStatusColor(label)),
        ),
        SizedBox(height: ScreenSize.height * 0.01),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.grey.shade700,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: ScreenSize.height * 0.01),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: _getStatusColor(label),
          ),
        ),
      ],
    ),
  );
}

Widget buildExperimentInfoCard(ExperimentController experimentController) {
  return Obx(() {
    final isActive = experimentController.isExperimentActive.value;
    final experiment = experimentController.currentExperiment.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenSize.height * 0.01),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isActive
                  ? [Colors.green.shade50, Colors.green.shade100]
                  : [Colors.grey.shade100, Colors.grey.shade200],
        ),
        borderRadius: BorderRadius.circular(
          ScreenSize.height * WidgetSizeConstant.borderCircular,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isActive
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color:
              isActive
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
          width: ScreenSize.width * 0.006,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ScreenSize.height * 0.01),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive
                      ? Icons.play_circle_filled
                      : Icons.pause_circle_filled,
                  color:
                      isActive ? Colors.green.shade700 : Colors.grey.shade600,
                  size: ScreenSize.height * 0.03,
                ),
              ),
              SizedBox(width: ScreenSize.width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Deney Durumu",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isActive ? "Devam Ediyor" : "Aktif Deney Yok",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isActive
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenSize.height * 0.02),

          _buildInfoRow(
            "Deney Adı",
            experimentController.experimentTitle.value,
            Icons.assignment_outlined,
          ),

          if (isActive && experiment != null) ...[
            SizedBox(height: ScreenSize.height * 0.02),
            _buildInfoRow(
              "Başlangıç Zamanı",
              formatDate(experiment.startDateTime),
              Icons.access_time,
            ),
          ],
        ],
      ),
    );
  });
}

Widget _buildInfoRow(String label, String value, IconData icon) {
  return Container(
    padding: EdgeInsets.all(ScreenSize.height * 0.01),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: ScreenSize.height * 0.02, color: Colors.grey.shade600),
        SizedBox(width: ScreenSize.width * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

IconData _getSensorIcon(String sensorType) {
  if (sensorType.toLowerCase().contains('co')) {
    return Icons.air;
  } else if (sensorType.toLowerCase().contains('humidity') ||
      sensorType.toLowerCase().contains('nem')) {
    return Icons.water_drop;
  } else if (sensorType.toLowerCase().contains('temperature') ||
      sensorType.toLowerCase().contains('sıcaklık')) {
    return Icons.thermostat;
  }
  return Icons.sensors;
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'batarya':
    case 'battery':
      return Colors.green;
    case 'valf':
    case 'valve':
      return Colors.blue;
    case 'bluetooth':
      return Colors.indigo;
    default:
      return Colors.grey;
  }
}
