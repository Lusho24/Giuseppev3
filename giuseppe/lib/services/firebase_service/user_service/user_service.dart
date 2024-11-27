import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giuseppe/models/user_model.dart';
import 'dart:developer' as dev;

class UserService{
  final  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<UserModel> users = querySnapshot.docs
            .map((doc) => UserModel.fromJson(doc.data()))
            .toList();

        return users;
      }
      return [];
    } catch (e) {
      dev.log(' - ERROR EN LA CONEXION Y OBTENER LOS DATOS: $e');
      return [];
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final query = await _firestore.collection('users')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return UserModel.fromJson(doc.data());
      }
      return null;
    } catch (e) {
      dev.log(' - ERROR EN LA CONEXION Y OBTENER LOS DATOS: $e');
      return null;
    }
  }
  
}