import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  // Claves para guardar en memoria
  static const String _keyMateriales = 'cfg_materiales';
  static const String _keyOrigenes = 'cfg_origenes';
  static const String _keyTransportistas = 'cfg_transportistas';
  static const String _keyRecibidores = 'cfg_recibidores';

  // Listas en memoria (Cache)
  static List<String> materiales = [];
  static List<String> origenes = [];
  static List<String> transportistas = [];
  static List<String> recibidores = [];

  // INICIALIZAR (Cargar o crear defaults)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    materiales = prefs.getStringList(_keyMateriales) ?? 
        ['Tosca', 'Arena', 'Relleno', 'Piedra', 'Balasto'];
    
    origenes = prefs.getStringList(_keyOrigenes) ?? 
        ['Cantera A', 'Cantera B', 'Pozo Norte', 'Otro'];

    transportistas = prefs.getStringList(_keyTransportistas) ?? 
        ['Transporte Gomez', 'Logística Sur', 'Transp. El Rápido'];
    
    recibidores = prefs.getStringList(_keyRecibidores) ?? 
        ['Juan Pérez', 'María Gonzalez', 'Capataz de Turno'];
  }

  // MÉTODOS PARA AGREGAR/BORRAR
  static Future<void> addItem(String listKey, String item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    String key = '';

    switch (listKey) {
      case 'materiales': list = materiales; key = _keyMateriales; break;
      case 'origenes': list = origenes; key = _keyOrigenes; break;
      case 'transportistas': list = transportistas; key = _keyTransportistas; break;
      case 'recibidores': list = recibidores; key = _keyRecibidores; break;
    }

    if (!list.contains(item)) {
      list.add(item);
      await prefs.setStringList(key, list);
    }
  }

  static Future<void> removeItem(String listKey, String item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    String key = '';

    switch (listKey) {
      case 'materiales': list = materiales; key = _keyMateriales; break;
      case 'origenes': list = origenes; key = _keyOrigenes; break;
      case 'transportistas': list = transportistas; key = _keyTransportistas; break;
      case 'recibidores': list = recibidores; key = _keyRecibidores; break;
    }

    list.remove(item);
    await prefs.setStringList(key, list);
  }
}