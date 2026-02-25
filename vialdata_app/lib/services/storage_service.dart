import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/obra_model.dart';

/// Servicio encargado de la persistencia de datos local (Shared Preferences).
class StorageService {
  static const String _keyRemitos = 'vialdata_remitos';
  static const String _keyInformes = 'vialdata_informes';
  static const String _keyObras = 'vialdata_obras';
  static const String _keyContadorRemito = 'vialdata_contador_remito';
  static const String _keyContadorInforme = 'vialdata_contador_informe';

  // Claves para listas administrables
  static const String _keyListaMaquinas = 'vialdata_lista_maquinas';
  static const String _keyListaChoferes = 'vialdata_lista_choferes';
  static const String _keyListaOtrosEquipos = 'vialdata_lista_otros_equipos';
  static const String _keyListaPeones = 'vialdata_lista_peones';
  static const String _keyListaMateriales = 'vialdata_lista_materiales';
  static const String _keyListaOrigenes = 'vialdata_lista_origenes';
  static const String _keyListaRecibidores = 'vialdata_lista_recibidores';
  static const String _keyListaTransportistas = 'vialdata_lista_transportistas';

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

  // --- CONTADOR DE INFORMES ---

  /// Obtiene el siguiente número de informe formateado (p. ej., "#00005").
  static Future<String> getProximoNroInforme() async {
    final prefs = await SharedPreferences.getInstance();
    int ultimo = prefs.getInt(_keyContadorInforme) ?? 0;
    int proximo = ultimo + 1;
    return '#${proximo.toString().padLeft(5, '0')}';
  }

  /// Incrementa el contador global de informes.
  static Future<void> incrementarContadorInforme() async {
    final prefs = await SharedPreferences.getInstance();
    int ultimo = prefs.getInt(_keyContadorInforme) ?? 0;
    await prefs.setInt(_keyContadorInforme, ultimo + 1);
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

  // --- GESTIÓN DE LISTAS ADMINISTRABLES (Generic Helpers) ---

  static Future<List<String>> _getList(
      String key, List<String> defaults) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? defaults;
  }

  static Future<void> _saveList(String key, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list);
  }

  // Métodos específicos
  static Future<List<String>> getListaMaquinas() =>
      _getList(_keyListaMaquinas, ['Excavadora 320', 'Motoniveladora 140K']);
  static Future<void> saveListaMaquinas(List<String> list) =>
      _saveList(_keyListaMaquinas, list);

  static Future<List<String>> getListaChoferes() =>
      _getList(_keyListaChoferes, ['Carlos Ruiz', 'Pedro Picaso']);
  static Future<void> saveListaChoferes(List<String> list) =>
      _saveList(_keyListaChoferes, list);

  static Future<List<String>> getListaOtrosEquipos() =>
      _getList(_keyListaOtrosEquipos, ['Generador 20kVA', 'Compresor']);
  static Future<void> saveListaOtrosEquipos(List<String> list) =>
      _saveList(_keyListaOtrosEquipos, list);

  static Future<List<String>> getListaPeones() =>
      _getList(_keyListaPeones, ['Peón 1', 'Peón 2']);
  static Future<void> saveListaPeones(List<String> list) =>
      _saveList(_keyListaPeones, list);

  static Future<List<String>> getListaMateriales() =>
      _getList(_keyListaMateriales, ['Tosca', 'Arena', 'Piedra']);
  static Future<void> saveListaMateriales(List<String> list) =>
      _saveList(_keyListaMateriales, list);

  static Future<List<String>> getListaOrigenes() =>
      _getList(_keyListaOrigenes, ['Cantera A', 'Cantera B', 'Pozo Norte']);
  static Future<void> saveListaOrigenes(List<String> list) =>
      _saveList(_keyListaOrigenes, list);

  static Future<List<String>> getListaRecibidores() =>
      _getList(_keyListaRecibidores, ['Juan Pérez', 'María Gonzalez']);
  static Future<void> saveListaRecibidores(List<String> list) =>
      _saveList(_keyListaRecibidores, list);

  static Future<List<String>> getListaTransportistas() =>
      _getList(_keyListaTransportistas, ['Transporte Gomez', 'Logística Sur']);
  static Future<void> saveListaTransportistas(List<String> list) =>
      _saveList(_keyListaTransportistas, list);

  /// Borra todos los datos almacenados (útil para pruebas).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRemitos);
    await prefs.remove(_keyInformes);
    await prefs.remove(_keyObras);
    await prefs.remove(_keyContadorRemito);
    await prefs.remove(_keyContadorInforme);
    await prefs.remove(_keyListaMaquinas);
    await prefs.remove(_keyListaChoferes);
    await prefs.remove(_keyListaOtrosEquipos);
    await prefs.remove(_keyListaPeones);
    await prefs.remove(_keyListaMateriales);
    await prefs.remove(_keyListaOrigenes);
    await prefs.remove(_keyListaRecibidores);
    await prefs.remove(_keyListaTransportistas);
  }
}
