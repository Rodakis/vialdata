class RemitoModel {
  final String id;
  final DateTime fecha;
  final String obraId;
  final String nombreObra;
  
  final String nroRemito; // Ahora será automático
  final String proveedor;
  final String patente;
  final String chofer;
  
  // --- CAMPO NUEVO ---
  final String nroGuia; 
  // -------------------

  final String material;
  final String cantidad;
  final String fotoRuta;

  RemitoModel({
    required this.id,
    required this.fecha,
    required this.obraId,
    required this.nombreObra,
    required this.nroRemito,
    this.proveedor = '',
    this.patente = '',
    this.chofer = '',
    this.nroGuia = '', // Inicializamos vacío por defecto
    required this.material,
    required this.cantidad,
    required this.fotoRuta,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'obraId': obraId,
      'obra': nombreObra,
      'nroRemito': nroRemito,
      'proveedor': proveedor,
      'patente': patente,
      'chofer': chofer,
      'nroGuia': nroGuia, // Guardamos el nuevo campo
      'material': material,
      'cantidad': cantidad,
      'fotoRuta': fotoRuta,
    };
  }
}