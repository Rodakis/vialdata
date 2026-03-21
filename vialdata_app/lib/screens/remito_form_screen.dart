import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/obra_model.dart';
import '../models/remito_model.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_text_field.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

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

  // Listas Dinámicas
  List<String> _listaOrigenes = [];
  List<String> _listaMateriales = [];
  List<String> _listaRecibidores = [];
  List<String> _listaTransportistas = [];

  // Valores seleccionados para Dropdowns
  String? _selectedProcedencia;
  String? _selectedMaterial;
  String? _selectedRecibidor;
  String? _selectedEmpresa;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    _listaOrigenes = await StorageService.getListaOrigenes();
    _listaMateriales = await StorageService.getListaMateriales();
    _listaRecibidores = await StorageService.getListaRecibidores();
    _listaTransportistas = await StorageService.getListaTransportistas();

    if (widget.remitoExistente != null) {
      final r = widget.remitoExistente!;
      _fecha = r.fecha;
      _nroRemitoController.text = r.nroRemito;
      _nroGuiaController.text = r.nroGuia;

      if (_listaOrigenes.contains(r.procedencia)) {
        _selectedProcedencia = r.procedencia;
      } else {
        _selectedProcedencia = 'Otro';
      }
      _procedenciaController.text = r.procedencia;

      if (_listaMateriales.contains(r.material)) {
        _selectedMaterial = r.material;
      } else {
        _selectedMaterial = 'Otro';
      }
      _materialController.text = r.material;

      if (_listaRecibidores.contains(r.recibidor)) {
        _selectedRecibidor = r.recibidor;
      } else {
        _selectedRecibidor = 'Otro';
      }
      _recibidorController.text = r.recibidor;

      if (_listaTransportistas.contains(r.empresaTransportista)) {
        _selectedEmpresa = r.empresaTransportista;
      } else {
        _selectedEmpresa = 'Otro';
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
    setState(() => _isLoading = false);
  }

  /// Carga el siguiente número de remito de forma automática.
  Future<void> _cargarNumeroAutomatico() async {
    String proximo = await StorageService.getProximoNroRemito();
    setState(() => _nroRemitoController.text = proximo);
  }

  /// Toma una fotografía del remito físico y prepara el contexto para la IA.
  Future<void> _tomarFoto() async {
    // 🔥 VERIFICACIÓN DE PERMISOS ANTES DE EMPEZAR 🔥
    // Verificamos el estado del permiso de cámara
    var status = await Permission.camera.status;
    
    // Si no tenemos permiso, lo pedimos
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    // Si el usuario rechaza el permiso, mostramos un mensaje y salimos
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se requiere permiso de cámara para tomar la foto.')));
      }
      return; 
    }
    // 🔥 FIN VERIFICACIÓN DE PERMISOS 🔥

    try {
      final XFile? fotoOriginal =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

      if (fotoOriginal != null) {
        // Guardamos la ruta real para mostrar la imagen en la UI (lo que ya tenías)
        setState(() => _fotoRuta = fotoOriginal.path);

        // --- INICIO DE PREPARACIÓN PARA LA IA ---

        // 1. Obtenemos el número de remito actual que está en la pantalla
        String nroRemito = _nroRemitoController.text;

        // 2. Extraemos la extensión del archivo real (ej: 'jpg' o 'png')
        String extension = fotoOriginal.name.split('.').last.toLowerCase();

        // Ajuste rápido de MIME type (jpg en mime type suele ser jpeg)
        String mimeType = extension == 'jpg' ? 'image/jpeg' : 'image/$extension';

        // 3. ¡EL TRUCO! Le damos un "nombre lógico" a la foto que incluya el nro de remito
        // para que cuando la IA lo lea, valide la regla "Remito Association".
        String nombreLogico = 'remito_${nroRemito}_carga.$extension';

        // 4. Armamos el "Map" con la estructura exacta de 'Expected Input Context' de SKILL.md
        Map<String, dynamic> payloadParaIA = {
          "current_remito_number": nroRemito,
          "attachments": [
            {"filename": nombreLogico, "mime_type": mimeType}
          ]
        };

        // 5. Lo convertimos a JSON y lo imprimimos en consola
        String jsonFinal = jsonEncode(payloadParaIA);
        print("🚀 JSON LISTO PARA LA IA:\n$jsonFinal");

        // NOTA: Aquí en el futuro llamaremos a la función que conecta con Gemini/IA
        // ej: await validarConIA(jsonFinal);

        // --- FIN DE PREPARACIÓN PARA LA IA ---
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir la cámara: $e')),
        );
      }
    }
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
  Future<void> _submitForm({bool closeAfter = true}) async {
    if (!_formKey.currentState!.validate()) return;
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
      if (closeAfter) {
        Navigator.pop(context, true);
      } else {
        await _cargarNumeroAutomatico();
        _fotoRuta = null;
        setState(() {});
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.corporateDark,
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
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.beigePastel,
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
              Center(
                child: Image.asset(
                  'assets/logo.jpg',
                  height: 80,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.remitoExistente != null
                    ? 'Actualiza el remito con los datos más recientes'
                    : 'Completa los datos obligatorios para el nuevo remito',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: '1. Identificación',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyField(
                            label: 'Fecha',
                            value: DateFormat('dd/MM/yy').format(_fecha),
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _nroGuiaController,
                            label: 'Nº Guía *',
                            style: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'Ej: 001-0001',
                            hintStyle: const TextStyle(color: Colors.white38),
                            fillColor: AppColors.surfaceCard,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyField(
                      label: 'Nº de Remito',
                      value: _nroRemitoController.text,
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: '2. Origen y Destino',
                helper: 'Campos obligatorios marcados con *',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedProcedencia,
                      dropdownColor: AppColors.surfaceCard,
                      style: const TextStyle(color: Colors.white),
                      decoration: AppStyles.inputDecoration(
                        label: 'Procedencia *',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'Seleccione origen',
                        hintStyle: const TextStyle(color: Colors.white38),
                        fillColor: AppColors.surfaceCard,
                      ),
                      items: [..._listaOrigenes, 'Otro']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedProcedencia = v;
                          if (v != 'Otro') {
                            _procedenciaController.text = v ?? '';
                          }
                        });
                      },
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    if (_selectedProcedencia == 'Otro') ...[
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _procedenciaController,
                        label: 'Procedencia (Manual)',
                        style: const TextStyle(color: Colors.white),
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'Ej: Cantera B',
                        hintStyle: const TextStyle(color: Colors.white38),
                        fillColor: AppColors.surfaceCard,
                      ),
                    ],
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _destinoController,
                      label: 'Destino',
                      helperText: 'Editable si es necesario',
                      style: const TextStyle(color: Colors.white),
                      labelStyle: const TextStyle(color: Colors.white70),
                      fillColor: AppColors.surfaceCard,
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: '3. Datos de Carga',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedMaterial,
                      dropdownColor: AppColors.surfaceCard,
                      style: const TextStyle(color: Colors.white),
                      decoration: AppStyles.inputDecoration(
                        label: 'Material *',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'Seleccione material',
                        hintStyle: const TextStyle(color: Colors.white38),
                        fillColor: AppColors.surfaceCard,
                      ),
                      items: [..._listaMateriales, 'Otro']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedMaterial = v;
                          if (v != 'Otro') {
                            _materialController.text = v ?? '';
                          }
                        });
                      },
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    if (_selectedMaterial == 'Otro') ...[
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _materialController,
                        label: 'Material (Manual)',
                        style: const TextStyle(color: Colors.white),
                        labelStyle: const TextStyle(color: Colors.white70),
                        fillColor: AppColors.surfaceCard,
                      ),
                    ],
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _cantidadController,
                      label: 'Cantidad (...) *',
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'Ej: 15.5',
                      hintStyle: const TextStyle(color: Colors.white38),
                      fillColor: AppColors.surfaceCard,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _horaDescargaController,
                            label: 'Hora Descarga',
                            readOnly: true,
                            onTap: _seleccionarHora,
                            prefixIcon: Icons.access_time_outlined,
                            style: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white70),
                            fillColor: AppColors.surfaceCard,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedRecibidor,
                                dropdownColor: AppColors.surfaceCard,
                                style: const TextStyle(color: Colors.white),
                                decoration: AppStyles.inputDecoration(
                                  label: 'Recibidor',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  hintText: 'Seleccione recibidor',
                                  hintStyle:
                                      const TextStyle(color: Colors.white38),
                                  fillColor: AppColors.surfaceCard,
                                ),
                                items: [..._listaRecibidores, 'Otro']
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedRecibidor = v;
                                    if (v != 'Otro') {
                                      _recibidorController.text = v ?? '';
                                    }
                                  });
                                },
                              ),
                              if (_selectedRecibidor == 'Otro') ...[
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: _recibidorController,
                                  label: 'Recibidor (Manual)',
                                  style: const TextStyle(color: Colors.white),
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  fillColor: AppColors.surfaceCard,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: '4. Transporte (Opcional)',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedEmpresa,
                      dropdownColor: AppColors.surfaceCard,
                      style: const TextStyle(color: Colors.white),
                      decoration: AppStyles.inputDecoration(
                        label: 'Empresa Transportista',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'Seleccione transporte',
                        hintStyle: const TextStyle(color: Colors.white38),
                        fillColor: AppColors.surfaceCard,
                      ),
                      items: [..._listaTransportistas, 'Otro']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedEmpresa = v;
                          if (v != 'Otro') {
                            _empresaController.text = v ?? '';
                          }
                        });
                      },
                    ),
                    if (_selectedEmpresa == 'Otro') ...[
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _empresaController,
                        label: 'Empresa (Manual)',
                        style: const TextStyle(color: Colors.white),
                        labelStyle: const TextStyle(color: Colors.white70),
                        fillColor: AppColors.surfaceCard,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _patenteCamionController,
                            label: 'Patente Cam.',
                            style: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'ABC 123',
                            hintStyle: const TextStyle(color: Colors.white38),
                            fillColor: AppColors.surfaceCard,
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _patenteAcopladoController,
                            label: 'Patente Ac.',
                            style: const TextStyle(color: Colors.white),
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'DEF 456',
                            hintStyle: const TextStyle(color: Colors.white38),
                            fillColor: AppColors.surfaceCard,
                            inputFormatters: [
                              UpperCaseTextFormatter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _choferController,
                      label: 'Chofer',
                      style: const TextStyle(color: Colors.white),
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'Nombre del chofer',
                      hintStyle: const TextStyle(color: Colors.white38),
                      fillColor: AppColors.surfaceCard,
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: '5. Fotos y cierre',
                helper: 'La foto del remito es obligatoria para guardar',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _tomarFoto,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Center(
                          child: _fotoRuta == null
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.camera_alt,
                                        size: 40, color: Colors.white38),
                                    SizedBox(height: 6),
                                    Text('Toca para tomar la foto',
                                        style:
                                            TextStyle(color: Colors.white54)),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(_fotoRuta!),
                                      fit: BoxFit.cover),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _observacionesController,
                      label: 'Observaciones',
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'Notas adicionales...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      fillColor: AppColors.surfaceCard,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildActionButtons(),
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
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(4),
            color: AppColors.corporateDark,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
              if (icon != null) Icon(icon, color: Colors.white70),
            ],
          ),
        ),
        Positioned(
          left: 10,
          top: -1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: AppColors.corporateDark,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    String? helper,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.surfaceSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(title, style: AppStyles.sectionTitle),
              const Spacer(),
              if (helper != null)
                Chip(
                  label: Text(helper, style: AppStyles.chipLabel),
                  backgroundColor: AppColors.chipWarning.withOpacity(0.15),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
            ],
          ),
          if (helper != null) const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.secondaryBlue,
              shape: const StadiumBorder(),
            ),
            onPressed: () => _submitForm(),
            child: const Text('GUARDAR Y CERRAR',
                style:
                    TextStyle(letterSpacing: 1.1, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            onPressed: () => _submitForm(closeAfter: false),
            child: const Text('GUARDAR Y SEGUIR'),
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
