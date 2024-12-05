import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:giuseppe/models/object_model.dart';
//import 'dart:developer' as dev;

class ObjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Subir la imagen al Storage y obtener su URL
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
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Guardar datos del item
  Future<bool> saveObject(ObjectModel object) async {
    try {
      await _firestore.collection("objects").add(object.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Guardar Item
  Future<bool> saveObjectWithImages(List<File> imageFiles, ObjectModel object) async {
    try {
      List<String> imageUrls = [];
      // Subir imagenes y agregar a lista
      for (var imageFile in imageFiles) {
        String? imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }
      if (imageUrls.isEmpty) return false;
      // Asignar listas al item
      object.images = imageUrls;
      // Guardar el item
      return await saveObject(object);
    } catch (e) {
      return false;
    }
  }

  /// Recuperar items
  Future<List<Map<String, dynamic>>> getAllItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('objects').get();
      List<Map<String, dynamic>> items = [];
      // Mapeo
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        items.add(data);
      }
      return items;
    } catch (e) {
      return [];
    }
  }

  /// Eliminar documento e imagenes
  Future<bool> deleteObject(String documentId, List<String> imageUrls) async {
    try {
      // Eliminar Imagenes
      for (var imageUrl in imageUrls) {
        Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
      // Eliminar el documentos
      await _firestore.collection('objects').doc(documentId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Actualizar un objeto existente en Firestore
  Future<bool> updateObjectWithImages(String objectId, ObjectModel object, List<String> imagesToRemove, List<File> newImages) async {
    try {
      // Eliminar imágenes del Storage
      if (imagesToRemove.isNotEmpty) {
        for (var imageUrl in imagesToRemove) {
          Reference ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        }
      }

      // Subir las nuevas imágenes
      List<String> newImageUrls = [];
      for (var imageFile in newImages) {
        String? imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          newImageUrls.add(imageUrl);
        }
      }

      // Agregar las URLs nuevas al objeto
      object.images.addAll(newImageUrls);

      // Actualizar el objeto en Firestore
      await _firestore.collection("objects").doc(objectId).update(object.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }


}
