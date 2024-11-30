import 'package:flutter/material.dart';
import 'package:giuseppe/presentation/login/login_page.dart';
import 'package:giuseppe/presentation/tabs/tabs_page.dart';

class AppRoutes {
  static const String loginPage = 'login_page';
  static const String tabsPage = 'tabs_page';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      loginPage: (BuildContext context) => const LoginPage(),
      tabsPage: (BuildContext context) => const TabsPage()
    };
  }

}