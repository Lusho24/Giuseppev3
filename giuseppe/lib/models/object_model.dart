class ObjectModel {
  String name;
  int quantity;
  String detail;
  String category;
  List<String> images;

  ObjectModel({
    required this.name,
    required this.quantity,
    required this.detail,
    required this.category,
    required this.images
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'detail': detail,
      'category': category,
      'images': images,

    };
  }

  factory ObjectModel.fromJson(Map<String, dynamic> json) {
    return ObjectModel(
      name: json['name'],
      quantity: json['quantity'],
      detail: json['detail'],
      category: json['category'],
      images: List<String>.from(json['images'] ?? []),
    );
  }

}
