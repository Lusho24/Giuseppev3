import 'package:giuseppe/models/user_model.dart';

abstract class UserServiceInterface {

  Future<List<UserModel>> getUsers();

  Future<UserModel>? getUserById(String id);

  Future<void> createUser(UserModel user);

  Future<void> deleteUser(String id);

}