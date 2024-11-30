import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:giuseppe/models/object_model.dart';
import 'dart:developer' as dev;

class ObjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Subir la imagen al almacenamiento y obtener su URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Generar un nombre único para la imagen
      String timeKey = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child("Object Images/$timeKey.jpg");

      // Subir la imagen
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Retornar la URL de la imagen
      String downloadUrl = await snapshot.ref.getDownloadURL();
      dev.log("Imagen subida exitosamente: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      dev.log("Error al subir la imagen: $e");
      return null;
    }
  }

  /// Guardar datos del objeto en Firestore
  Future<bool> saveObject(ObjectModel object) async {
    try {
      await _firestore.collection("objects").add(object.toJson());
      dev.log("Objeto guardado exitosamente en Firestore");
      return true;
    } catch (e) {
      dev.log("Error al guardar el objeto: $e");
      return false;
    }
  }

  /// Subir imagen y guardar datos del objeto
  Future<bool> saveObjectWithImages(List<File> imageFiles, ObjectModel object) async {
    try {
      List<String> imageUrls = [];
      // Subir todas las imágenes y agregar sus URLs a la lista
      for (var imageFile in imageFiles) {
        String? imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }

      if (imageUrls.isEmpty) return false;

      // Asignar la lista de URLs de imágenes al objeto
      object.images = imageUrls;

      // Guardar el objeto en Firestore
      return await saveObject(object);
    } catch (e) {
      dev.log("Error en saveObjectWithImages: $e");
      return false;
    }
  }
}
