import 'package:flutter/material.dart';
import 'package:giuseppe/models/user_model.dart';
import 'package:giuseppe/services/firebase_service/user_service/user_service.dart';
import 'dart:developer' as dev;

class LoginViewModel extends ChangeNotifier {

  late final UserService _userService = UserService();

  Future<void> getAllUsers() async {
    try{
      final users = await _userService.getAllUsers();
      if (users.isNotEmpty) {
        String firstUserName = users.first.name;
        dev.log("Nombre del primer usuario: $firstUserName");
      } else {
        dev.log("No hay usuarios disponibles.");
      }
    }catch(e){
      dev.log("- ERROR EN EL VIEEW MODEL: $e");
    }

  }

  Future<void> funcionTest() async {
    dev.log("SI VALE EL VIEW MODEL");
  }


  Future<void> getUserById(String id) async {
    final user = await _userService.getUserById(id);
    if (user != null) {
      dev.log("USUARIO: $user");
    } else {
      dev.log("ERROR: NO HAY ");
    }
  }


}