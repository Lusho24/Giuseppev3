class OrderDispatchModel{
  String client;
  String location;
  String dispachDate;
  String? orderDate;
  String driverName;
  String deliveryTime;
  String receiverName;
  String responsibleName;
  List<Map<String, dynamic>> items;

  OrderDispatchModel({
    required this.client,
    required this.location,
    required this.dispachDate,
    this.orderDate,
    required this.driverName,
    required this.deliveryTime,
    required this.receiverName,
    required this.responsibleName,
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
      'items': items
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
      items: json['items'],
    );
  }

}