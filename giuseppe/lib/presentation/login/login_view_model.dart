import 'package:flutter/cupertino.dart';
import 'package:giuseppe/models/user_model.dart';
import 'package:giuseppe/services/firebase_service/user_service/user_service_interface.dart';

class LoginViewModel extends ChangeNotifier{

  late final UserServiceInterface _userService;

  LoginViewModel(this._userService);

  Future<List<UserModel>> getUsers() async{
    return [];
  }

  Future<void> updateUser(UserModel user) async {
    await [];
  }

  Future<void> deleteUser(String id) async {
    await [];
  }

}