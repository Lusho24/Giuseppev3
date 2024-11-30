import 'package:flutter/material.dart';
import 'package:giuseppe/router/app_routes.dart';
import 'package:giuseppe/services/local_storage/session_in_local_storage_service.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/login_service.dart';
import 'dart:developer' as dev;


class LoginViewModel extends ChangeNotifier {

  late final LoginService _loginService = LoginService();
  late final SessionInLocalStorageService _localStorage = SessionInLocalStorageService();
  bool _isLoggedIn = false;
  bool _isAdmin = false;

  Future<void> signIn({
    required String id,
    required String password,
    required BuildContext context}) async {

    List<bool> result = await _loginService.signIn(id, password);
    _isLoggedIn = result[0];
    _isAdmin = result[1];

    if (_isLoggedIn) {
      await saveSessionInLocalStorage(id, _isAdmin);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bienvenido")),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.tabsPage);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(" !Error al iniciar sesión! ")),
      );
    }
  }

  Future<void> saveSessionInLocalStorage(String userId, bool isAdmin) async {
    await _localStorage.saveSession(userId, isAdmin);
  }


}