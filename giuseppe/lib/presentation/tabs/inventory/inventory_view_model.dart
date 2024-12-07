import 'package:flutter/material.dart';
import 'package:giuseppe/router/app_routes.dart';
import 'package:giuseppe/services/local_storage/session_in_local_storage_service.dart';

class InventoryViewModel extends ChangeNotifier {
  late final SessionInLocalStorageService _localStorage = SessionInLocalStorageService();

  Future<void> removeSessionInLocalStorage({required BuildContext context}) async{
    _localStorage.removeSession();
    Navigator.pushReplacementNamed(context, AppRoutes.loginPage);
  }

}