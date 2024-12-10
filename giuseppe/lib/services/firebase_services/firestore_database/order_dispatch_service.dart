import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giuseppe/models/order_dispatch_model.dart';

class OrderDispatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required List<Map<String, dynamic>> items,
    required String clientName,
    required String location,
    required String dispachDate,
    required String driverName,
    required String deliveryTime,
    required String receiveName,
    required String responsibleName,
  }) async {
      DocumentReference orderRef = _firestore.collection('order_dispatch').doc();

      DateTime now = DateTime.now();
      String orderDate = "${now.day.toString().padLeft(2, '0')}/"
          "${now.month.toString().padLeft(2, '0')}/"
          "${now.year}";

      await orderRef.set({
        'items': items,
        'clientName': clientName,
        'location': location,
        'dispachDate': dispachDate,
        'driverName': driverName,
        'deliveryTime': deliveryTime,
        'receiveName': receiveName,
        'responsibleName': responsibleName,
        'orderDate': orderDate,  // Fecha en formato dd/MM/yyyy
      });
  }

  Future<void> saveOrderDispatch(OrderDispatchModel order) async {
    try {
      DateTime now = DateTime.now();
      String orderDate = "${now.day.toString().padLeft(2, '0')}/"
          "${now.month.toString().padLeft(2, '0')}/"
          "${now.year}";
      order.orderDate = orderDate;

      await _firestore.collection('order_dispatch').add(order.toJson());
    }catch(e){
      throw Exception(" * ERROR al crear la orden: $e");
    }
  }

}
