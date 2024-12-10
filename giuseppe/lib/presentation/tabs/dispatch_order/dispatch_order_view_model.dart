import 'package:flutter/material.dart';
import 'package:giuseppe/models/order_dispatch_model.dart';
import 'package:giuseppe/services/firebase_services/firestore_database/order_dispatch_service.dart';

class DispatchOrderViewModel extends ChangeNotifier{
  final OrderDispatchService _orderDispatchService = OrderDispatchService();

  Future<void> saveOrderDispatch(OrderDispatchModel order) async{
    _orderDispatchService.saveOrderDispatch(order);
  }


}