// lib/models/informe_diario_model.dart

class InformeDiarioModel {
  final String id;
  final DateTime fecha;
  final String obraId;

  // --- CAMPOS NUEVOS ---
  final String nombreObra; // Para guardar el nombre
  final String horasMaquina; // Para guardar las horas
  final String kmRecorridos; // Para guardar los km

  // --- Avance ---
  final String actividades; // Qué se hizo hoy
  final String avanceDescripcion; // Cantidad o volumen (texto libre para flexibilidad)
  final String? incidencias; // Problemas encontrados

  // --- Recursos ---
  final String personal; // Quiénes trabajaron (lista de nombres o cantidad)
  final String equipos; // Maquinaria utilizada

  // --- Cierre ---
  final String? comentariosAdicionales;
  final List<String> fotosRutas;

 
  InformeDiarioModel({
    required this.id,
    required this.fecha,
    required this.obraId,
    required this.nombreObra,      // Requerido ahora
    this.horasMaquina = '',        // Opcional (por defecto vacío)
    this.kmRecorridos = '',        // Opcional (por defecto vacío)
    required this.actividades,
    required this.avanceDescripcion,
    required this.personal,
    required this.equipos,
    required this.incidencias,
    required this.comentariosAdicionales,
    required this.fotosRutas,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'obraId': obraId,
      'obra': nombreObra, // IMPORTANTE: Guardamos con la clave 'obra' para el historial
      'horasMaquina': horasMaquina,
      'kmRecorridos': kmRecorridos,
      'actividades': actividades,
      'avanceDescripcion': avanceDescripcion,
      'personal': personal,
      'equipos': equipos,
      'incidencias': incidencias,
      'observaciones': comentariosAdicionales,
      'fotosRutas': fotosRutas,
    };
  }
}