import 'package:flutter/material.dart';
import 'package:giuseppe/router/app_routes.dart';
import 'package:giuseppe/utils/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Giuseppe",
      theme: AppTheme.generalTheme,
      routes: AppRoutes.getRoutes(),
      initialRoute: AppRoutes.loginPage,
      debugShowCheckedModeBanner: false,
    );
  }
}
