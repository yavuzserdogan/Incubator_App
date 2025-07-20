import 'package:flutter/material.dart';
import 'package:incubator/core/constants/color_constant.dart';
import 'package:incubator/core/constants/widget_size_constant.dart';
import '../../core/utils/screen_size.dart';
import '../../core/utils/text_files.dart';
import '../controllers/experiment_controller.dart';
import 'package:incubator/presentation/themes/data_cards.dart';
import 'package:get/get.dart';
import '../themes/text_style.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  late final ExperimentController experimentController;

  @override
  void initState() {
    super.initState();
    experimentController = Get.find<ExperimentController>();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    final SizedBox mediumConstBox = SizedBox(height: ScreenSize.height * 0.04);
    final SizedBox smallConstBox = SizedBox(height: ScreenSize.height * 0.02);
    return Scaffold(
      backgroundColor: Color(ColorConstant.screenBackground),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(ScreenSize.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      TextFiles.sensorData,
                      Icons.sensors,
                      Colors.red,
                    ),
                    smallConstBox,

                    _buildSensorGrid(),

                    smallConstBox,

                    _buildSectionHeader(
                      TextFiles.deviceData,
                      Icons.devices,
                      Colors.purple,
                    ),
                    smallConstBox,
                    _buildDeviceStatusGrid(),

                    smallConstBox,

                    _buildSectionHeader(
                      TextFiles.exerciseData,
                      Icons.assignment,
                      Colors.green,
                    ),
                    smallConstBox,
                    buildExperimentInfoCard(experimentController),
                  ],
                ),
              ),
            ),

            Obx(() {
              final isActive = experimentController.isExperimentActive.value;
              return Container(
                width: double.infinity,
                height: ScreenSize.height * 0.055,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isActive
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                  borderRadius: BorderRadius.circular(
                    ScreenSize.height * WidgetSizeConstant.borderRadius,
                  ),
                  boxShadow:
                      isActive
                          ? [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                          : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      ScreenSize.height * WidgetSizeConstant.borderRadius,
                    ),
                    onTap: isActive ? experimentController.endExperiment : null,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop_circle_outlined,
                            color: Colors.white,
                            size: ScreenSize.height * 0.04,
                          ),
                          SizedBox(width: ScreenSize.width * 0.03),
                          Text(
                            TextFiles.exerciseEnd,
                            style: titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ScreenSize.height * 0.01),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ScreenSize.height * 0.01),
          ),
          child: Icon(icon, color: color, size: ScreenSize.height * 0.02),
        ),
        SizedBox(width: ScreenSize.width * 0.03),
        Text(
          title,
          style: titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Expanded(
          child: Container(
            height: ScreenSize.height * 0.002,
            margin: EdgeInsets.only(left: ScreenSize.width * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.3), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorGrid() {
    return Column(
      children: [
        buildSensorCard(
          TextFiles.dataCO,
          "352 ppm",
          TextFiles.dataCOOpt,
          Colors.green,
        ),
        SizedBox(height: ScreenSize.height * 0.015),
        buildSensorCard(
          TextFiles.dataHumidity,
          "60%",
          TextFiles.dataHumidityOpt,
          Colors.orange,
        ),
        SizedBox(height: ScreenSize.height * 0.015),
        buildSensorCard(
          TextFiles.dataTemperature,
          "27°C",
          TextFiles.dataTemperatureOpt,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildDeviceStatusGrid() {
    return Row(
      children: [
        Expanded(
          child: buildStatusTile(
            Icons.battery_full,
            TextFiles.dataBattery,
            "87%",
          ),
        ),
        SizedBox(width: ScreenSize.width * 0.02),
        Expanded(
          child: buildStatusTile(Icons.water, TextFiles.dataValf, "Açık"),
        ),
        SizedBox(width: ScreenSize.width * 0.02),
        Expanded(
          child: buildStatusTile(
            Icons.bluetooth,
            TextFiles.dataBluetooth,
            "Bağlı",
          ),
        ),
      ],
    );
  }
}
