import 'package:flutter/cupertino.dart';
import 'package:giuseppe/services/local_storage/session_in_local_storage_service.dart';
import 'dart:developer' as dev;

class TabsViewModel extends ChangeNotifier{

  final SessionInLocalStorageService _localStorage = SessionInLocalStorageService();

  Future<Map<String, dynamic>?> fetchSessionInLocalStorage() async {
    try{
      final Map<String, dynamic>? sessionData= await _localStorage.fetchSession();

      if (sessionData != null) {
        dev.log(" * ID EN LOCAL STORAGE: ${sessionData['userId']}");
        dev.log(" * IsAdmin EN LOCAL STORAGE: ${sessionData['isAdmin']}");
        return sessionData;
      }
    } catch(e) {
      dev.log(" * ¡ERROR AL RECUPERAR USAURIO!: $e");
      return null;
    }
    return null;

  }

}