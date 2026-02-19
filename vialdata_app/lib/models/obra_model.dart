import 'dart:convert';

class ObraModel {
  final String id;
  final String nombre;
  final String direccion;
  final bool activa;

  ObraModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.activa = true,
  });

  // Convertir a Mapa para guardar
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'activa': activa,
    };
  }

  // Crear desde Mapa (al leer del celular)
  factory ObraModel.fromJson(Map<String, dynamic> json) {
    return ObraModel(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      activa: json['activa'] ?? true,
    );
  }

  // Lista estática para leer/guardar lista completa
  static String encode(List<ObraModel> obras) => json.encode(
        obras.map<Map<String, dynamic>>((music) => music.toJson()).toList(),
      );

  static List<ObraModel> decode(String obras) =>
      (json.decode(obras) as List<dynamic>)
          .map<ObraModel>((item) => ObraModel.fromJson(item))
          .toList();
}