class ObjectModel {
  String name;
  String quantity;
  String detail;
  String category;
  String image;

  ObjectModel({
    required this.name,
    required this.quantity,
    required this.detail,
    required this.category,
    required this.image
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'detail': detail,
      'category': category,
      'image': image,

    };
  }

  factory ObjectModel.fromJson(Map<String, dynamic> json) {
    return ObjectModel(
      name: json['name'],
      quantity: json['quantity'],
      detail: json['detail'],
      category: json['category'],
      image: json['image'],
    );
  }

}
