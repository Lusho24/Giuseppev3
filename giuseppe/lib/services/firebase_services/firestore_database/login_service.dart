import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giuseppe/models/user_model.dart';
import 'dart:developer' as dev;

class LoginService{
  final  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<bool>> signIn(String id, String password) async {
    try{
      QuerySnapshot querySnapshot = await _firestore
          .collection('user')
          .where('id', isEqualTo: id)
          .get();

      if(querySnapshot.docs.isEmpty){
        dev.log("ID no encontrado.");
        return [false, false];
      }

      var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
     if(userData['password'] == password){
       if(userData['role'] == "ADMIN"){
         dev.log(" ** SESION INICIADA COMO ADMIN");
         return [true, true];
       } else if (userData['role'] == "USER"){
         dev.log(" ** SESION INICIADA COMO USUARIO");
         return [true, false];
       } else {
         return [false, false];
       }

     } else{
       dev.log(" ** Contraseña incorrecta ");
       return [false, false];
     }

    }catch(e){
      dev.log(" * ERROR en el servicio signIn: $e");
      return [false, false];
    }
  }

  Future<void> saveLocalUser() async {
    try{
      //TODO hacer el guardado local del usaurio en proceso
    }catch(e){
      dev.log("- ERROR: $e");
    }

  }

}