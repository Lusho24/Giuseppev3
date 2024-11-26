import 'package:giuseppe/models/user_model.dart';
import 'package:giuseppe/services/firebase_service/user_service/user_service_interface.dart';
import 'dart:developer' as dev;

class UserService implements UserServiceInterface{
  @override
  Future<void> createUser(UserModel user) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser(String id) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<UserModel>? getUserById(String id) {
    try {
      // TODO: implement getUserById
      return null;
    } catch (e) {
      dev.log('Error al obtener usuario: $e');
      return null;
    }
  }

  @override
  Future<List<UserModel>> getUsers() {
    // TODO: implement getUsers
    throw UnimplementedError();
  }
  
}