import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDispatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required List<Map<String, dynamic>> items,
    required String clienteName,
    required String location,
    required String dispachDate,
    required String driverName,
    required String deliveryTime,
    required String receiveName,
    required String responsibleName,
  }) async {
    try {
      DocumentReference orderRef = _firestore.collection('order_dispach').doc();

      await orderRef.set({
        'items': items,
        'clienteName': clienteName,
        'location': location,
        'dispachDate': dispachDate,
        'driverName': driverName,
        'deliveryTime': deliveryTime,
        'receiveName': receiveName,
        'responsibleName': responsibleName,
      });

      print("Orden creada con éxito");
    } catch (e) {
      print("Error al crear la orden: $e");
      throw Exception("Error al crear la orden: $e");
    }
  }
}
