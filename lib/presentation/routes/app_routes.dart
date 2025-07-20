import 'package:incubator/presentation/Screens/register_screen.dart';
import 'package:incubator/presentation/screens/data_screen.dart';
import 'package:incubator/presentation/screens/default_screen.dart';
import 'package:incubator/presentation/screens/experiment_details_screen.dart';
import 'package:incubator/presentation/screens/home_screen.dart';
import 'package:incubator/presentation/screens/login_screen.dart';
import '../screens/camera_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/register',
      page: () => RegisterScreen(),
      //transition: Transition.fade,
    ),

    GetPage(
      name: '/login',
      page: () => LoginScreen(),
      //transition: Transition.fade,
    ),

    GetPage(
      name: '/home',
      page: () => HomeScreen(),
     // transition: Transition.fade,
    ),
    GetPage(
      name: '/default',
      page: () => DefaultScreen(),
      //transition: Transition.fade,
    ),
    GetPage(
      name: '/data',
      page: () => DataScreen(),
      //transition: Transition.fade,
    ),
    GetPage(
      name: '/camera',
      page: () => CameraScreen(),
      //transition: Transition.downToUp,
    ),
    GetPage(
      name: '/details',
      page: () => ExperimentDetailsScreen(),
     // transition: Transition.fade,
     // arguments: Get.arguments,
    ),
  ];
}
