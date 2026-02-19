class UserModel {
  final String username;
  final String password; // En producción esto debería estar encriptado
  final String role; // 'admin' o 'operario'

  UserModel({
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      password: json['password'],
      role: json['role'],
    );
  }
}