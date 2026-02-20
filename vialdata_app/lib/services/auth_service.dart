import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Servicio encargado de la autenticación y gestión de usuarios.
class AuthService {
  static const String _keyUsers = 'vialdata_users';

  /// Usuario logueado actualmente en la sesión.
  static UserModel? currentUser;

  /// Inicializa el servicio y crea un usuario administrador por defecto si no existe.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyUsers)) {
      final admin =
          UserModel(username: 'admin', password: '123', role: 'admin');
      List<String> users = [jsonEncode(admin.toJson())];
      await prefs.setStringList(_keyUsers, users);
    }
  }

  /// Intenta iniciar sesión con el [username] y [password] proporcionados.
  /// Retorna `true` si el login es exitoso.
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usersJson = prefs.getStringList(_keyUsers) ?? [];

    for (var u in usersJson) {
      final user = UserModel.fromJson(jsonDecode(u));
      if (user.username == username && user.password == password) {
        currentUser = user;
        return true;
      }
    }
    return false;
  }

  /// Cierra la sesión del usuario actual.
  static void logout() {
    currentUser = null;
  }

  /// Crea un nuevo usuario en el sistema.
  /// Retorna `false` si el nombre de usuario ya existe.
  static Future<bool> createUser(
      String username, String password, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usersJson = prefs.getStringList(_keyUsers) ?? [];

    // Verificamos si el usuario ya existe usando any para mayor eficiencia
    final exists = usersJson.any((u) {
      final user = UserModel.fromJson(jsonDecode(u));
      return user.username == username;
    });

    if (exists) return false;

    final newUser =
        UserModel(username: username, password: password, role: role);
    usersJson.add(jsonEncode(newUser.toJson()));
    await prefs.setStringList(_keyUsers, usersJson);
    return true;
  }

  /// Indica si el usuario actual tiene permisos de administrador.
  static bool get isAdmin => currentUser?.role == 'admin';

  /// Obtiene la lista completa de usuarios registrados.
  static Future<List<UserModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usersJson = prefs.getStringList(_keyUsers) ?? [];
    return usersJson.map((u) => UserModel.fromJson(jsonDecode(u))).toList();
  }

  /// Elimina un usuario del sistema por su [username].
  static Future<void> deleteUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersJson = prefs.getStringList(_keyUsers) ?? [];

    usersJson.removeWhere((u) {
      final user = UserModel.fromJson(jsonDecode(u));
      return user.username == username;
    });

    await prefs.setStringList(_keyUsers, usersJson);
  }
}
