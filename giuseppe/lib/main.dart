import 'package:flutter/material.dart';
import 'package:giuseppe/router/app_routes.dart';
import 'package:giuseppe/services/local_storage/session_in_local_storage_service.dart';
import 'package:giuseppe/utils/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final initialRoute = await getInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> getInitialRoute() async {
  final bool isLoggedIn = await SessionInLocalStorageService.isLoggedIn();

  if (isLoggedIn) {
    return AppRoutes.tabsPage;
  } else {
    return AppRoutes.loginPage;
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({
    required this.initialRoute,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Giuseppe",
      theme: AppTheme.generalTheme,
      routes: AppRoutes.getRoutes(),
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
