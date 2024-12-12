import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giuseppe/models/order_dispatch_model.dart';

class OrderDispatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<OrderDispatchModel?> findOrderDispatchByClient(String client) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('order_dispatch')
          .where('client', isEqualTo: client)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return OrderDispatchModel.fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>);
    }catch(e){
      throw Exception(" * ERROR al encontrar la orden: $e");
    }
  }

  Future<List<OrderDispatchModel>> findAllOrdersDispatch() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('order_dispatch')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => OrderDispatchModel.fromJson(doc.data() as Map<String,dynamic>))
          .toList();
    }catch(e){
      throw Exception(" * ERROR al devolver las ordenes: $e");
    }
  }

}
