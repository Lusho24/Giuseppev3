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
        items[existingItemIndex]['quantityOrder'] += quantity;
        await docRef.update({'items': items});
      } else {
        items.add({'itemId': itemId, 'quantityOrder': quantity});
        await docRef.update({'items': items});
      }
    } else {
      await docRef.set({
        'items': [{'itemId': itemId, 'quantityOrder': quantity}],
      });
    }

    notifyListeners();
  }

  ///Actualizar Cantidad
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
      final docSnapshot = await FirebaseFirestore.instance.collection('cart').doc('active_order').get();
      var items = docSnapshot.data()?['items'] ?? [];
      var itemIndex = -1;
      for (int i = 0; i < items.length; i++) {
        if (items[i]['itemId'] == itemId) {
          itemIndex = i;
          break;
        }
      }
      items[itemIndex]['quantityOrder'] = newQuantity;
      await FirebaseFirestore.instance.collection('cart').doc('active_order').update({
        'items': items,
      });
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
