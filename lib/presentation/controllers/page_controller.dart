import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/presentation/screens/home_screen.dart';

import '../../core/utils/text_files.dart';

class PagesController extends GetxController {
  var selectedWidget = Rx<Widget>(Container());
  var selectedIndex = 0.obs;
  var currentTitle = RxString(TextFiles.homeAppBar);

  @override
  void onInit() {
    super.onInit();
    selectedWidget.value = HomeScreen();
    currentTitle.value = TextFiles.homeAppBar;
  }

  void changeWidget(Widget widget, int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      selectedWidget.value = widget;
      switch (index) {
        case 0:
          currentTitle.value = TextFiles.homeAppBar;
          break;
        case 1:
          currentTitle.value = TextFiles.dataAppBar;
          break;
        case 2:
          currentTitle.value = TextFiles.mediaAppBar;
          break;
        case 3:
          currentTitle.value = TextFiles.devicesAppBar;
        default:
          currentTitle.value = TextFiles.settingsAppBar;
      }
    }
  }
}
