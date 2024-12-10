class OrderItemModel {
  String name;
  String observations;
  int quantity;

  OrderItemModel({
    required this.name,
    required this.observations,
    required this.quantity
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'observations': observations,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'],
      observations: json['observations'],
      quantity: json['quantity'],
    );
  }

}