// lib/models/informe_diario_model.dart

class InformeDiarioModel {
  final String id;
  final String numeroInforme; // Autogenerado (ej. #00001)
  final DateTime fecha;
  final String obraId;
  final String nombreObra;
  final String senorOEmpresaContratante;

  // Listas dinámicas
  final List<MaquinaItem> maquinas;
  final List<MaterialItem> materiales;
  final List<OtroEquipoItem> otrosEquipos;
  final List<PeonItem> peonesAyudantes;
  final List<CamionItem> camionesVolcadoras;

  // Cierre
  final String observaciones;
  final List<String> fotosRutas;

  InformeDiarioModel({
    required this.id,
    required this.numeroInforme,
    required this.fecha,
    required this.obraId,
    required this.nombreObra,
    required this.senorOEmpresaContratante,
    required this.maquinas,
    required this.materiales,
    required this.otrosEquipos,
    required this.peonesAyudantes,
    required this.camionesVolcadoras,
    required this.observaciones,
    required this.fotosRutas,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroInforme': numeroInforme,
      'fecha': fecha.toIso8601String(),
      'obraId': obraId,
      'obra': nombreObra,
      'contratante': senorOEmpresaContratante,
      'maquinas': maquinas.map((x) => x.toJson()).toList(),
      'materiales': materiales.map((x) => x.toJson()).toList(),
      'otrosEquipos': otrosEquipos.map((x) => x.toJson()).toList(),
      'peones': peonesAyudantes.map((x) => x.toJson()).toList(),
      'camiones': camionesVolcadoras.map((x) => x.toJson()).toList(),
      'observaciones': observaciones,
      'fotosRutas': fotosRutas,
    };
  }

  factory InformeDiarioModel.fromJson(Map<String, dynamic> json) {
    return InformeDiarioModel(
      id: json['id'] ?? '',
      numeroInforme: json['numeroInforme'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      obraId: json['obraId'] ?? '',
      nombreObra: json['obra'] ?? '',
      senorOEmpresaContratante: json['contratante'] ?? '',
      maquinas: (json['maquinas'] as List? ?? [])
          .map((x) => MaquinaItem.fromJson(x))
          .toList(),
      materiales: (json['materiales'] as List? ?? [])
          .map((x) => MaterialItem.fromJson(x))
          .toList(),
      otrosEquipos: (json['otrosEquipos'] as List? ?? [])
          .map((x) => OtroEquipoItem.fromJson(x))
          .toList(),
      peonesAyudantes: (json['peones'] as List? ?? [])
          .map((x) => PeonItem.fromJson(x))
          .toList(),
      camionesVolcadoras: (json['camiones'] as List? ?? [])
          .map((x) => CamionItem.fromJson(x))
          .toList(),
      observaciones: json['observaciones'] ?? '',
      fotosRutas: List<String>.from(json['fotosRutas'] ?? []),
    );
  }
}

class MaquinaItem {
  final String maquina;
  final String chofer;
  final String horaInicio;
  final String horaFinal;

  MaquinaItem({
    required this.maquina,
    required this.chofer,
    required this.horaInicio,
    required this.horaFinal,
  });

  Map<String, dynamic> toJson() => {
        'maquina': maquina,
        'chofer': chofer,
        'horaInicio': horaInicio,
        'horaFinal': horaFinal,
      };

  factory MaquinaItem.fromJson(Map<String, dynamic> json) => MaquinaItem(
        maquina: json['maquina'] ?? '',
        chofer: json['chofer'] ?? '',
        horaInicio: json['horaInicio'] ?? '',
        horaFinal: json['horaFinal'] ?? '',
      );
}

class MaterialItem {
  final String material;
  final double cantidad;
  final String unidad; // "m3" o "kg"

  MaterialItem({
    required this.material,
    required this.cantidad,
    required this.unidad,
  });

  Map<String, dynamic> toJson() => {
        'material': material,
        'cantidad': cantidad,
        'unidad': unidad,
      };

  factory MaterialItem.fromJson(Map<String, dynamic> json) => MaterialItem(
        material: json['material'] ?? '',
        cantidad: (json['cantidad'] as num? ?? 0).toDouble(),
        unidad: json['unidad'] ?? 'm3',
      );
}

class OtroEquipoItem {
  final String equipo;
  final String horaInicio;
  final String horaFinal;

  OtroEquipoItem({
    required this.equipo,
    required this.horaInicio,
    required this.horaFinal,
  });

  Map<String, dynamic> toJson() => {
        'equipo': equipo,
        'horaInicio': horaInicio,
        'horaFinal': horaFinal,
      };

  factory OtroEquipoItem.fromJson(Map<String, dynamic> json) => OtroEquipoItem(
        equipo: json['equipo'] ?? '',
        horaInicio: json['horaInicio'] ?? '',
        horaFinal: json['horaFinal'] ?? '',
      );
}

class PeonItem {
  final String nombre;
  final double horas;

  PeonItem({
    required this.nombre,
    required this.horas,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'horas': horas,
      };

  factory PeonItem.fromJson(Map<String, dynamic> json) => PeonItem(
        nombre: json['nombre'] ?? '',
        horas: (json['horas'] as num? ?? 0).toDouble(),
      );
}

class CamionItem {
  final String capacidad; // "3 m3", "7 m3", "10 m3", "20 m3"
  final String marca;
  final String matricula;
  final String chofer;
  final int viajes;
  final double horas;

  CamionItem({
    required this.capacidad,
    required this.marca,
    required this.matricula,
    required this.chofer,
    required this.viajes,
    required this.horas,
  });

  Map<String, dynamic> toJson() => {
        'capacidad': capacidad,
        'marca': marca,
        'matricula': matricula,
        'chofer': chofer,
        'viajes': viajes,
        'horas': horas,
      };

  factory CamionItem.fromJson(Map<String, dynamic> json) => CamionItem(
        capacidad: json['capacidad'] ?? '',
        marca: json['marca'] ?? '',
        matricula: json['matricula'] ?? '',
        chofer: json['chofer'] ?? '',
        viajes: json['viajes'] ?? 0,
        horas: (json['horas'] as num? ?? 0).toDouble(),
      );
}
