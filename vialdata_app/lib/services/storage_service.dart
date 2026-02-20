import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/obra_model.dart';

/// Servicio encargado de la persistencia de datos local (Shared Preferences).
class StorageService {
  static const String _keyRemitos = 'vialdata_remitos';
  static const String _keyInformes = 'vialdata_informes';
  static const String _keyObras = 'vialdata_obras';
  static const String _keyContadorRemito = 'vialdata_contador_remito';

  // --- GESTIÓN DE REMITOS ---

  /// Guarda un nuevo remito al inicio de la lista.
  static Future<void> saveRemito(Map<String, dynamic> remitoData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyRemitos) ?? [];
    list.insert(0, jsonEncode(remitoData));
    await prefs.setStringList(_keyRemitos, list);
  }

  /// Obtiene la lista de remitos guardados.
  static Future<List<Map<String, dynamic>>> getRemitos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyRemitos) ?? [];
    return list
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  /// Actualiza un remito existente identicado por su ID.
  static Future<void> updateRemito(
      Map<String, dynamic> remitoActualizado) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyRemitos) ?? [];

    for (int i = 0; i < list.length; i++) {
      final Map<String, dynamic> item = jsonDecode(list[i]);
      if (item['id'] == remitoActualizado['id']) {
        list[i] = jsonEncode(remitoActualizado);
        await prefs.setStringList(_keyRemitos, list);
        return;
      }
    }
  }

  // --- GESTIÓN DE INFORMES DIARIOS ---

  /// Guarda un nuevo informe diario al inicio de la lista.
  static Future<void> saveInforme(Map<String, dynamic> informeData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyInformes) ?? [];
    list.insert(0, jsonEncode(informeData));
    await prefs.setStringList(_keyInformes, list);
  }

  /// Obtiene la lista de informes diarios.
  static Future<List<Map<String, dynamic>>> getInformes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyInformes) ?? [];
    return list
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  /// Actualiza un informe existente identificado por su ID.
  static Future<void> updateInforme(
      Map<String, dynamic> informeActualizado) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyInformes) ?? [];

    for (int i = 0; i < list.length; i++) {
      final Map<String, dynamic> item = jsonDecode(list[i]);
      if (item['id'] == informeActualizado['id']) {
        list[i] = jsonEncode(informeActualizado);
        await prefs.setStringList(_keyInformes, list);
        return;
      }
    }
  }

  // --- CONTADOR DE REMITOS ---

  /// Obtiene el siguiente número de remito formateado (p. ej., "00005").
  static Future<String> getProximoNroRemito() async {
    final prefs = await SharedPreferences.getInstance();
    int ultimo = prefs.getInt(_keyContadorRemito) ?? 0;
    int proximo = ultimo + 1;
    return proximo.toString().padLeft(5, '0');
  }

  /// Incrementa el contador global de remitos.
  static Future<void> incrementarContadorRemito() async {
    final prefs = await SharedPreferences.getInstance();
    int ultimo = prefs.getInt(_keyContadorRemito) ?? 0;
    await prefs.setInt(_keyContadorRemito, ultimo + 1);
  }

  // --- GESTIÓN DE OBRAS ---

  /// Guarda la lista completa de obras.
  static Future<void> saveObras(List<ObraModel> obras) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = ObraModel.encode(obras);
    await prefs.setString(_keyObras, encodedData);
  }

  /// Obtiene la lista de obras registradas.
  static Future<List<ObraModel>> getObras() async {
    final prefs = await SharedPreferences.getInstance();
    final String? obrasString = prefs.getString(_keyObras);
    if (obrasString == null) return [];
    return ObraModel.decode(obrasString);
  }

  /// Borra todos los datos almacenados (útil para pruebas).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRemitos);
    await prefs.remove(_keyInformes);
    await prefs.remove(_keyObras);
    await prefs.remove(_keyContadorRemito);
  }
}
