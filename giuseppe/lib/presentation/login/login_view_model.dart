import 'package:flutter/material.dart';
import 'package:giuseppe/router/app_routes.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/login_service.dart';
import 'dart:developer' as dev;


class LoginViewModel extends ChangeNotifier {

  late final LoginService _userService = LoginService();
  bool _isLoggedIn = false;
  bool _isAdmin = false;

  Future<void> signIn({
    required String id,
    required String password,
    required BuildContext context}) async {

    List<bool> result = await _userService.signIn(id, password);
    _isLoggedIn = result[0];
    _isAdmin = result[1];


    if (_isLoggedIn && _isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login exitoso como ADMIN!')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.tabsPage, arguments: true);
    } else if(_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login exitoso como USUARIO!')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.tabsPage, arguments: false);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar sesión!')),
      );
    }
  }


}