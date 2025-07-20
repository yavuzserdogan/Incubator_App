import 'package:flutter/material.dart';
import 'package:incubator/core/constants/color_constant.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:incubator/presentation/screens/data_screen.dart';
import 'package:incubator/presentation/screens/device_screen.dart';
import 'package:incubator/presentation/screens/home_screen.dart';
import 'package:incubator/presentation/screens/media_screen.dart';
import 'package:incubator/presentation/screens/settings_screen.dart';
import 'package:incubator/presentation/themes/app_bar_style.dart';
import 'package:incubator/presentation/controllers/page_controller.dart';
import 'package:get/get.dart';
import 'package:incubator/presentation/controllers/experiment_controller.dart';
import 'package:incubator/presentation/controllers/media_controller.dart';
import '../../core/constants/widget_size_constant.dart';
import '../themes/text_style.dart';

class DefaultScreen extends StatefulWidget {
  const DefaultScreen({super.key});

  @override
  State<DefaultScreen> createState() => _DefaultScreenState();
}

class _DefaultScreenState extends State<DefaultScreen> {
  final PagesController controller = Get.find<PagesController>();
  final experimentController = Get.find<ExperimentController>();
  final mediaController = Get.find<MediaController>();

  @override
  void initState() {
    super.initState();
    controller.changeWidget(HomeScreen(), 0);
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);

    SizedBox constBox = SizedBox(width: ScreenSize.width * 0.01);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarStyle(
        title: Obx(() => Text(controller.currentTitle.value)),
        style: headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Obx(() {
            if (controller.selectedIndex.value == 0) {
              return Container(
                padding: EdgeInsets.all(ScreenSize.height * 0.01),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    ScreenSize.height * WidgetSizeConstant.borderCircular,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(ColorConstant.gradientColorsFirst),
                      Color(ColorConstant.gradientColorsSecond),
                      Color(ColorConstant.gradientColorsFirst),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "Toplam: ",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${experimentController.experiments.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          Obx(() {
            return controller.selectedIndex.value == 0
                ? IconButton(
                  icon: Icon(
                    Icons.cached,
                    color: Colors.white,
                    size: ScreenSize.height * 0.05,
                  ),
                  onPressed: () async {
                    // await experimentController.syncExercises();
                    // await mediaController.syncMedia();
                  },
                )
                : const SizedBox.shrink();
          }),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(ColorConstant.gradientColorsFirst),
              Color(ColorConstant.gradientColorsSecond),
              Color(ColorConstant.gradientColorsFirst),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: ScreenSize.height * 0.01,
            left: ScreenSize.width * 0.02,
            right: ScreenSize.width * 0.02,
          ),

          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: ScreenSize.height * 0.75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Obx(() => controller.selectedWidget.value),
              ),
              SizedBox(height: ScreenSize.height * 0.02),
              Container(
                height: ScreenSize.height * 0.06,
                width: ScreenSize.width * 0.7,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(
                    ColorConstant.navigationBar,
                  ).withValues(alpha: 0.8),
                  border: Border.all(
                    color: Color(ColorConstant.navigationBarBorder),
                    width: ScreenSize.height * WidgetSizeConstant.border,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      ScreenSize.height * WidgetSizeConstant.borderCircular,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => controller.changeWidget(HomeScreen(), 0),
                      child: Obx(
                        () => Icon(
                          Icons.home_outlined,
                          color:
                              controller.selectedIndex.value == 0
                                  ? Color(ColorConstant.activeIcon)
                                  : Color(ColorConstant.passiveIcon),
                          size: ScreenSize.height * WidgetSizeConstant.iconSize,
                        ),
                      ),
                    ),
                    constBox,
                    GestureDetector(
                      onTap: () => controller.changeWidget(DataScreen(), 1),
                      child: Obx(
                        () => Icon(
                          Icons.science_outlined,
                          color:
                              controller.selectedIndex.value == 1
                                  ? Color(ColorConstant.activeIcon)
                                  : Color(ColorConstant.passiveIcon),
                          size: ScreenSize.height * WidgetSizeConstant.iconSize,
                        ),
                      ),
                    ),
                    constBox,
                    GestureDetector(
                      onTap: () => controller.changeWidget(MediaScreen(), 2),
                      child: Obx(
                        () => Icon(
                          Icons.photo_camera_outlined,
                          color:
                              controller.selectedIndex.value == 2
                                  ? Color(ColorConstant.activeIcon)
                                  : Color(ColorConstant.passiveIcon),
                          size: ScreenSize.height * WidgetSizeConstant.iconSize,
                        ),
                      ),
                    ),
                    constBox,
                    GestureDetector(
                      onTap: () => controller.changeWidget(DeviceScreen(), 3),
                      child: Obx(
                        () => Icon(
                          Icons.bluetooth_outlined,
                          color:
                              controller.selectedIndex.value == 3
                                  ? Color(ColorConstant.activeIcon)
                                  : Color(ColorConstant.passiveIcon),
                          size: ScreenSize.height * WidgetSizeConstant.iconSize,
                        ),
                      ),
                    ),
                    constBox,
                    GestureDetector(
                      onTap: () => controller.changeWidget(SettingsScreen(), 4),
                      child: Obx(
                        () => Icon(
                          Icons.settings_outlined,
                          color:
                              controller.selectedIndex.value == 4
                                  ? Color(ColorConstant.activeIcon)
                                  : Color(ColorConstant.passiveIcon),
                          size: ScreenSize.height * WidgetSizeConstant.iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
