import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _cartDocId = "active_order";
  final String _cartCollection = "cart";

  /// Lista de ítems del carrito
  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final doc = await _firestore.collection(_cartCollection).doc(_cartDocId).get();
    if (doc.exists) {
      final data = doc.data();
      final items = data?['items'] as List<dynamic>? ?? [];
      return items.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  }

  /// Agrega ítem al carrito
  Future<void> addItemToCart(String itemId, int quantity) async {
    final docRef = _firestore.collection(_cartCollection).doc(_cartDocId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data();
      final items = List<Map<String, dynamic>>.from(data?['items'] ?? []);

      final existingItemIndex = items.indexWhere((cartItem) => cartItem['itemId'] == itemId);

      if (existingItemIndex != -1) {
        // Si el ítem ya existe en el carrito, actualizamos la cantidad
        items[existingItemIndex]['quantityOrder'] += quantity;
        await docRef.update({'items': items});
      } else {
        // Si el ítem no está en el carrito, lo agregamos
        items.add({'itemId': itemId, 'quantityOrder': quantity});
        await docRef.update({'items': items});
      }
    } else {
      // Si el carrito no existe, lo creamos con el primer ítem
      await docRef.set({
        'items': [{'itemId': itemId, 'quantityOrder': quantity}],
      });
    }

    notifyListeners();
  }


  /// Elimina items
  Future<void> clearCart() async {
    await _firestore.collection(_cartCollection).doc(_cartDocId).delete();
    notifyListeners();
  }

  /// Elimina un ítem específico del carrito
  Future<void> removeItemFromCart(String itemId) async {
    final docRef = _firestore.collection(_cartCollection).doc(_cartDocId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data();
      final items = List<Map<String, dynamic>>.from(data?['items'] ?? []);
      items.removeWhere((cartItem) => cartItem['itemId'] == itemId);

      await docRef.update({'items': items});
    }

    notifyListeners();
  }



}
