class RemitoModel {
  final String id;
  final DateTime fecha;
  final String obraId;
  final String nombreObra;

  // 1. Identificación
  final String nroRemito; // Automático
  final String nroGuia;

  // 2. Origen y Destino
  final String procedencia;
  final String destino;

  // 3. Datos de Carga
  final String material;
  final String cantidad;
  final String horaDescarga;
  final String recibidor;

  // 4. Transporte
  final String empresaTransportista;
  final String patenteCamion;
  final String patenteAcoplado;
  final String chofer;

  // 5. Fotos y Cierre
  final String observaciones;
  final String fotoRuta;

  RemitoModel({
    required this.id,
    required this.fecha,
    required this.obraId,
    required this.nombreObra,
    required this.nroRemito,
    this.nroGuia = '',
    this.procedencia = '',
    this.destino = '',
    this.material = '',
    this.cantidad = '',
    this.horaDescarga = '',
    this.recibidor = '',
    this.empresaTransportista = '',
    this.patenteCamion = '',
    this.patenteAcoplado = '',
    this.chofer = '',
    this.observaciones = '',
    required this.fotoRuta,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'obraId': obraId,
      'obra': nombreObra,
      'nroRemito': nroRemito,
      'nroGuia': nroGuia,
      'procedencia': procedencia,
      'destino': destino,
      'material': material,
      'cantidad': cantidad,
      'horaDescarga': horaDescarga,
      'recibidor': recibidor,
      'empresaTransportista': empresaTransportista,
      'patenteCamion': patenteCamion,
      'patenteAcoplado': patenteAcoplado,
      'chofer': chofer,
      'observaciones': observaciones,
      'fotoRuta': fotoRuta,
    };
  }
}
