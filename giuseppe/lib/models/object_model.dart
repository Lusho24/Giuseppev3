class ObjectModel {
  String id;
  String name;
  String quantity;
  String detail;
  String category;
  String image;

  ObjectModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.detail,
    required this.category,
    required this.image
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cuantity': quantity,
      'detail': detail,
      'category': category,
      'image': image,

    };
  }

  factory ObjectModel.fromJson(Map<String, dynamic> json) {
    return ObjectModel(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      detail: json['detail'],
      category: json['category'],
      image: json['image'],
    );
  }

}
