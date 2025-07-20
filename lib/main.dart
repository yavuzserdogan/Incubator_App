import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/data/sources/local/database/database_helper.dart';
import 'package:incubator/injection.dart';
import 'package:incubator/presentation/routes/app_routes.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    final dbHelper = DatabaseHelper();
    await dbHelper.database;

    await initDependencies();
    runApp(const MyApp());
  } catch (e) {
    print('Initialization error: $e');

  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Incubator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/register',
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

