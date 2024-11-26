class UserModel {
  String id;
  String name;
  String email;
  String password;
  String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
    );
  }

}
