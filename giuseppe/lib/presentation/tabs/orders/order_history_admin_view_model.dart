import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class OrderHistoryAdminViewModel extends ChangeNotifier{
  final List<Order> _orders = [
    Order(detail: 'Orden A', date: '21/11/24', isChecked: false),
    Order(detail: 'Orden B', date: '22/11/24', isChecked: false),
    Order(detail: 'Orden C', date: '23/11/24', isChecked: false),
  ];

  void checkOrder(Order order){
    dev.log("Orden seleccionada: $order");
    notifyListeners();
  }

  List<Order> get orders => _orders;
}


// Modelo para representar una orden
class Order {
  String detail;
  String date;
  bool isChecked;

  Order({required this.detail, required this.date, this.isChecked = false});
}
