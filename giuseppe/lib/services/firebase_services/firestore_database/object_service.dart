import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:giuseppe/models/object_model.dart';

class ObjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Subir la imagen al Storage y obtener su URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Generar un nombre para la imagen
      String timeKey = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child("Object Images/$timeKey.jpg");
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
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
      for (var imageFile in imageFiles) {
        String? imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }
      if (imageUrls.isEmpty) return false;
      object.images = imageUrls;
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
      for (var imageUrl in imageUrls) {
        Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
      await _firestore.collection('objects').doc(documentId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Actualizar un objeto existente en Firestore
  Future<bool> updateObjectWithImages(String objectId, ObjectModel object, List<String> imagesToRemove, List<File> newImages) async {
    try {
      if (imagesToRemove.isNotEmpty) {
        for (var imageUrl in imagesToRemove) {
          Reference ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        }
      }
      List<String> newImageUrls = [];
      for (var imageFile in newImages) {
        String? imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          newImageUrls.add(imageUrl);
        }
      }
      object.images.addAll(newImageUrls);
      await _firestore.collection("objects").doc(objectId).update(object.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }


}
