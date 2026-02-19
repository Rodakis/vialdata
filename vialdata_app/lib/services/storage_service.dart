import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/obra_model.dart'; // <--- IMPORTANTE: Necesitamos importar el modelo de Obra

class StorageService {
  // --- CLAVES DE GUARDADO ---
  static const String _keyRemitos = 'vialdata_remitos';
  static const String _keyInformes = 'vialdata_informes';
  static const String _keyObras = 'vialdata_obras'; // Nueva clave para las obras

  // ---------------------------------------------------------
  // 1. GESTIÓN DE REMITOS
  // ---------------------------------------------------------
  static Future<void> saveRemito(Map<String, dynamic> remitoData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyRemitos) ?? [];
    list.insert(0, jsonEncode(remitoData));
    await prefs.setStringList(_keyRemitos, list);
  }

  static Future<List<Map<String, dynamic>>> getRemitos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyRemitos) ?? [];
    return list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  // ---------------------------------------------------------
  // 2. GESTIÓN DE INFORMES DIARIOS
  // ---------------------------------------------------------
  static Future<void> saveInforme(Map<String, dynamic> informeData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyInformes) ?? [];
    list.insert(0, jsonEncode(informeData));
    await prefs.setStringList(_keyInformes, list);
  }

  // --- ACTUALIZAR INFORME ---
  static Future<void> updateInforme(Map<String, dynamic> informeActualizado) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyInformes) ?? [];

    // 1. Convertimos toda la lista a Mapas para poder leer los IDs
    List<Map<String, dynamic>> decodedList = list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();

    // 2. Buscamos en qué posición está el informe que tiene el MISMO ID
    final index = decodedList.indexWhere((item) => item['id'] == informeActualizado['id']);

    if (index != -1) {
      // 3. Si lo encontramos, lo REEMPLAZAMOS por el nuevo
      decodedList[index] = informeActualizado;
      
      // 4. Guardamos la lista actualizada de nuevo en el celular
      final List<String> newList = decodedList.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_keyInformes, newList);
    }
  }

  // --- ACTUALIZAR REMITO ---
  static Future<void> updateRemito(Map<String, dynamic> remitoActualizado) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyRemitos) ?? [];

    List<Map<String, dynamic>> decodedList = list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();

    // Buscamos el índice por ID
    final index = decodedList.indexWhere((item) => item['id'] == remitoActualizado['id']);

    if (index != -1) {
      decodedList[index] = remitoActualizado; // Reemplazamos
      
      final List<String> newList = decodedList.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(_keyRemitos, newList);
    }
  }

  static Future<List<Map<String, dynamic>>> getInformes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyInformes) ?? [];
    return list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  // --- CONTADOR DE REMITOS ---
  static const String _keyContadorRemito = 'vialdata_contador_remito';

  // Obtiene el siguiente número (Ej: "00005")
  static Future<String> getProximoNroRemito() async {
    final prefs = await SharedPreferences.getInstance();
    // Leemos el último número guardado (si no existe, empezamos en 0)
    int ultimo = prefs.getInt(_keyContadorRemito) ?? 0;
    int proximo = ultimo + 1;
    
    // Devolvemos formateado con ceros (Ej: 00001)
    return proximo.toString().padLeft(5, '0');
  }

  // Confirmamos y guardamos el incremento (se llama al GUARDAR)
  static Future<void> incrementarContadorRemito() async {
    final prefs = await SharedPreferences.getInstance();
    int ultimo = prefs.getInt(_keyContadorRemito) ?? 0;
    await prefs.setInt(_keyContadorRemito, ultimo + 1);
  }

  // ---------------------------------------------------------
  // 3. GESTIÓN DE OBRAS (LO NUEVO)
  // ---------------------------------------------------------
  
  // Guardar la lista completa de obras
  static Future<void> saveObras(List<ObraModel> obras) async {
    final prefs = await SharedPreferences.getInstance();
    // Usamos la función encode que creamos en el modelo ObraModel
    final String encodedData = ObraModel.encode(obras);
    await prefs.setString(_keyObras, encodedData);
  }

  // Leer la lista de obras guardadas
  static Future<List<ObraModel>> getObras() async {
    final prefs = await SharedPreferences.getInstance();
    final String? obrasString = prefs.getString(_keyObras);
    
    if (obrasString == null) {
      // Si es la primera vez y no hay nada, devolvemos una lista vacía
      return [];
    }
    
    // Convertimos el texto guardado de vuelta a objetos ObraModel
    return ObraModel.decode(obrasString);
  }

  // ---------------------------------------------------------
  // UTILIDAD: BORRAR TODO (SOLO PARA PRUEBAS)
  // ---------------------------------------------------------
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRemitos);
    await prefs.remove(_keyInformes);
    await prefs.remove(_keyObras);
  }
}