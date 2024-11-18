import 'package:flutter/material.dart';
import 'package:giuseppe/router/app_routes.dart';
import 'package:giuseppe/utils/theme/app_theme.dart';

void main() {
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
    );
  }
}
