import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _keyUsers = 'vialdata_users';
  static UserModel? currentUser;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyUsers)) {
      final admin = UserModel(username: 'admin', password: '123', role: 'admin');
      List<String> users = [jsonEncode(admin.toJson())];
      await prefs.setStringList(_keyUsers, users);
    }
  }

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

  static void logout() {
    currentUser = null;
  }

  static Future<bool> createUser(String username, String password, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usersJson = prefs.getStringList(_keyUsers) ?? [];

    for (var u in usersJson) {
      final user = UserModel.fromJson(jsonDecode(u));
      if (user.username == username) return false; 
    }

    final newUser = UserModel(username: username, password: password, role: role);
    usersJson.add(jsonEncode(newUser.toJson()));
    await prefs.setStringList(_keyUsers, usersJson);
    return true;
  }
  
  static bool get isAdmin => currentUser?.role == 'admin';

  // --- NUEVAS FUNCIONES PARA GESTIÓN ---

  // 1. Obtener lista de usuarios para mostrar
  static Future<List<UserModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> usersJson = prefs.getStringList(_keyUsers) ?? [];
    return usersJson.map((u) => UserModel.fromJson(jsonDecode(u))).toList();
  }

  // 2. Borrar un usuario (Requerido para resetear claves: se borra y se crea de nuevo)
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