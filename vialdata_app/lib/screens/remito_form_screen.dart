import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/obra_model.dart';
import '../models/remito_model.dart';
import '../services/config_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_text_field.dart';

/// Pantalla para crear o editar un Remito de carga.
class RemitoFormScreen extends StatefulWidget {
  final ObraModel obra;
  final RemitoModel? remitoExistente;

  const RemitoFormScreen({super.key, required this.obra, this.remitoExistente});

  @override
  State<RemitoFormScreen> createState() => _RemitoFormScreenState();
}

class _RemitoFormScreenState extends State<RemitoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fecha;

  // CONTROLADORES
  final _nroRemitoController = TextEditingController();
  final _nroGuiaController = TextEditingController();
  final _procedenciaController = TextEditingController();
  final _destinoController = TextEditingController();
  final _materialController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _horaDescargaController = TextEditingController();
  final _recibidorController = TextEditingController();
  final _empresaController = TextEditingController();
  final _patenteCamionController = TextEditingController();
  final _patenteAcopladoController = TextEditingController();
  final _choferController = TextEditingController();
  final _observacionesController = TextEditingController();

  String? _fotoRuta;
  final ImagePicker _picker = ImagePicker();

  // Valores seleccionados para Dropdowns
  String? _selectedProcedencia;
  String? _selectedMaterial;
  String? _selectedRecibidor;
  String? _selectedEmpresa;

  @override
  void initState() {
    super.initState();
    if (widget.remitoExistente != null) {
      final r = widget.remitoExistente!;
      _fecha = r.fecha;
      _nroRemitoController.text = r.nroRemito;
      _nroGuiaController.text = r.nroGuia;

      // Inicializar dropdowns con valores del servicio
      if (ConfigService.origenes.contains(r.procedencia)) {
        _selectedProcedencia = r.procedencia;
      }
      _procedenciaController.text = r.procedencia;

      if (ConfigService.materiales.contains(r.material)) {
        _selectedMaterial = r.material;
      }
      _materialController.text = r.material;

      if (ConfigService.recibidores.contains(r.recibidor)) {
        _selectedRecibidor = r.recibidor;
      }
      _recibidorController.text = r.recibidor;

      if (ConfigService.transportistas.contains(r.empresaTransportista)) {
        _selectedEmpresa = r.empresaTransportista;
      }
      _empresaController.text = r.empresaTransportista;

      _choferController.text = r.chofer;

      _patenteCamionController.text = r.patenteCamion;
      _patenteAcopladoController.text = r.patenteAcoplado;

      _destinoController.text = r.destino;
      _cantidadController.text = r.cantidad;
      _horaDescargaController.text = r.horaDescarga;
      _observacionesController.text = r.observaciones;
      _fotoRuta = r.fotoRuta.isNotEmpty ? r.fotoRuta : null;
    } else {
      _fecha = DateTime.now();
      _cargarNumeroAutomatico();
      _destinoController.text = widget.obra.nombre;
    }
  }

  /// Carga el siguiente número de remito de forma automática.
  Future<void> _cargarNumeroAutomatico() async {
    String proximo = await StorageService.getProximoNroRemito();
    setState(() => _nroRemitoController.text = proximo);
  }

  /// Toma una fotografía del remito físico.
  Future<void> _tomarFoto() async {
    final XFile? foto =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (foto != null) setState(() => _fotoRuta = foto.path);
  }

  /// Selecciona la hora de descarga.
  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      setState(() => _horaDescargaController.text = picked.format(context));
    }
  }

  /// Valida y guarda el remito con lógica de versionado.
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_fotoRuta == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falta la foto del remito')));
        return;
      }
      _formKey.currentState!.save();

      String nroFinal = _nroRemitoController.text;

      // Si es una edición, aplicamos versionado (ej: 00001 -> 00001-1)
      if (widget.remitoExistente != null) {
        nroFinal = _getUpdatedVersionNumber(nroFinal);
      }

      final nuevoRemito = RemitoModel(
        id: widget.remitoExistente?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        fecha: _fecha,
        obraId: widget.obra.id,
        nombreObra: widget.obra.nombre,
        nroRemito: nroFinal,
        nroGuia: _nroGuiaController.text,
        procedencia: _procedenciaController.text,
        destino: _destinoController.text,
        material: _materialController.text,
        cantidad: _cantidadController.text,
        horaDescarga: _horaDescargaController.text,
        recibidor: _recibidorController.text,
        empresaTransportista: _empresaController.text,
        patenteCamion: _patenteCamionController.text,
        patenteAcoplado: _patenteAcopladoController.text,
        chofer: _choferController.text,
        observaciones: _observacionesController.text,
        fotoRuta: _fotoRuta!,
      );

      if (widget.remitoExistente != null) {
        await StorageService.updateRemito(nuevoRemito.toJson());
      } else {
        await StorageService.saveRemito(nuevoRemito.toJson());
        await StorageService.incrementarContadorRemito();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Guardado correctamente'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true); // Devolvemos true para refrescar lista
      }
    }
  }

  /// Gestiona el sufijo de versión (ej: "00001" -> "00001-1", "00001-1" -> "00001-2")
  String _getUpdatedVersionNumber(String currentNro) {
    if (!currentNro.contains('-')) {
      return '$currentNro-1';
    } else {
      List<String> parts = currentNro.split('-');
      String base = parts[0];
      int version = int.tryParse(parts[1]) ?? 0;
      return '$base-${version + 1}';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: AppStyles.titleLarge.copyWith(color: AppColors.secondaryBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.remitoExistente != null ? 'Remito' : 'Nuevo Remito',
                style: const TextStyle(fontSize: 20)),
            Text(widget.obra.nombre,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo en la cabecera
              Center(
                child: Image.asset(
                  'assets/logo.jpg',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),

              // 1. Identificación
              _buildSectionTitle('1. Identificación'),
              Row(
                children: [
                  Expanded(
                    child: _buildReadOnlyField(
                      label: 'Fecha',
                      value: DateFormat('dd/MM/yy').format(_fecha),
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextField(
                      controller: _nroGuiaController,
                      label: 'Nº Guía *',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildReadOnlyField(
                label: 'Nº de Remito',
                value: _nroRemitoController.text,
              ),

              // 2. Origen y Destino
              _buildSectionTitle('2. Origen y Destino'),
              DropdownButtonFormField<String>(
                initialValue: _selectedProcedencia,
                decoration: AppStyles.inputDecoration(label: 'Procedencia'),
                items: ConfigService.origenes.isEmpty
                    ? [
                        const DropdownMenuItem(
                            value: null,
                            child: Text('No hay datos disponibles'))
                      ]
                    : ConfigService.origenes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedProcedencia = v;
                      _procedenciaController.text = v;
                    });
                  }
                },
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _destinoController,
                label: 'Destino',
                helperText: 'Editable si es necesario',
              ),

              // 3. Datos de Carga
              _buildSectionTitle('3. Datos de Carga'),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedMaterial,
                      decoration: AppStyles.inputDecoration(label: 'Material'),
                      items: ConfigService.materiales.isEmpty
                          ? [
                              const DropdownMenuItem(
                                  value: null,
                                  child: Text('No hay datos disponibles'))
                            ]
                          : ConfigService.materiales
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedMaterial = v;
                            _materialController.text = v;
                          });
                        }
                      },
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextField(
                      controller: _cantidadController,
                      label: 'Cantidad (...)',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _horaDescargaController,
                      label: 'Hora Descarga',
                      readOnly: true,
                      onTap: _seleccionarHora,
                      prefixIcon: Icons.access_time_outlined,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedRecibidor,
                      decoration: AppStyles.inputDecoration(label: 'Recibidor'),
                      items: ConfigService.recibidores.isEmpty
                          ? [
                              const DropdownMenuItem(
                                  value: null,
                                  child: Text('No hay datos disponibles'))
                            ]
                          : ConfigService.recibidores
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedRecibidor = v;
                            _recibidorController.text = v;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              // 4. Transporte (Opcional)
              _buildSectionTitle('4. Transporte (Opcional)'),
              DropdownButtonFormField<String>(
                initialValue: _selectedEmpresa,
                decoration:
                    AppStyles.inputDecoration(label: 'Empresa Transportista'),
                items: ConfigService.transportistas.isEmpty
                    ? [
                        const DropdownMenuItem(
                            value: null,
                            child: Text('No hay datos disponibles'))
                      ]
                    : ConfigService.transportistas
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedEmpresa = v;
                      _empresaController.text = v;
                    });
                  }
                },
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _patenteCamionController,
                      label: 'Patente Cam.',
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextField(
                      controller: _patenteAcopladoController,
                      label: 'Patente Ac.',
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _choferController,
                label: 'Chofer',
              ),

              // 5. Fotos y Cierre
              _buildSectionTitle('5. Fotos y Cierre'),
              GestureDetector(
                onTap: _tomarFoto,
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _fotoRuta == null
                        ? Icon(Icons.camera_alt,
                            size: 40, color: Colors.grey.shade400)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child:
                                Image.file(File(_fotoRuta!), fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _observacionesController,
                label: 'Observaciones',
                maxLines: 3,
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.secondaryBlue,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                onPressed: _submitForm,
                child: const Text('GUARDAR REMITO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Stack(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 16)),
              if (icon != null) Icon(icon, color: Colors.black54),
            ],
          ),
        ),
        Positioned(
          left: 10,
          top: -1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: Colors.white,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
    );
  }
}

/// Formateador para convertir texto a mayúsculas automáticamente.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
