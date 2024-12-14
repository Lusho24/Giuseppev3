import 'package:giuseppe/models/order_item_model.dart';

class OrderDispatchModel{
  String client;
  String location;
  String dispachDate;
  String? orderDate;
  String driverName;
  String deliveryTime;
  String receiverName;
  String responsibleName;
  bool? isEnable;
  List<OrderItemModel> items;

  OrderDispatchModel({
    required this.client,
    required this.location,
    required this.dispachDate,
    this.orderDate,
    required this.driverName,
    required this.deliveryTime,
    required this.receiverName,
    required this.responsibleName,
    this.isEnable,
    required this.items
  });

  Map<String, dynamic> toJson() {
    return {
      'client': client,
      'location': location,
      'dispachDate': dispachDate,
      'orderDate': orderDate,
      'driverName': driverName,
      'deliveryTime': deliveryTime,
      'receiverName': receiverName,
      'responsibleName': responsibleName,
      'isEnable': isEnable,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory OrderDispatchModel.fromJson(Map<String, dynamic> json) {
    return OrderDispatchModel(
      client: json['client'],
      location: json['location'],
      dispachDate: json['dispachDate'],
      orderDate: json['orderDate'],
      driverName: json['driverName'],
      deliveryTime: json['deliveryTime'],
      receiverName: json['receiverName'],
      responsibleName: json['responsibleName'],
      isEnable: json['isEnable'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
    );
  }

}