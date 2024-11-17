import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/login/login_page.dart';

class AppRoutes {
  static const String loginPage = 'login_page';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      loginPage: (BuildContext context) => const LoginPage(),
    };
  }

}