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

}
