import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/informe_diario_model.dart';
import '../models/obra_model.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class InformeDiarioFormScreen extends StatefulWidget {
  final ObraModel obra;
  final InformeDiarioModel? informeExistente;

  const InformeDiarioFormScreen(
      {super.key, required this.obra, this.informeExistente});

  @override
  State<InformeDiarioFormScreen> createState() =>
      _InformeDiarioFormScreenState();
}

class _InformeDiarioFormScreenState extends State<InformeDiarioFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- MOCK DATA PARA DROPDOWNS ---
  final List<String> _mockMaquinas = [
    'Excavadora 320',
    'Motoniveladora 140K',
    'Pala Cargadora 950',
    'Rodillo Compactador'
  ];
  final List<String> _mockEmpleadosInternos = [
    'Juan Pérez',
    'Carlos García',
    'Luis Rodríguez',
    'Alberto Sánchez'
  ];
  final List<String> _mockMateriales = [
    'Suelo Seleccionado',
    'Base Granular',
    'Asfalto',
    'Piedra 1-3'
  ];
  final List<String> _mockOtrosEquipos = [
    'Generador 20kVA',
    'Torre de Iluminación',
    'Compresor de Aire'
  ];
  final List<String> _mockCapacidadesCamion = [
    '3 m3',
    '7 m3',
    '10 m3',
    '20 m3'
  ];

  // --- ESTADO DEL FORMULARIO ---
  late DateTime _fecha;
  late String _numeroInforme;
  final TextEditingController _contratanteController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  List<MaquinaItem> _maquinas = [];
  List<MaterialItem> _materiales = [];
  List<OtroEquipoItem> _otrosEquipos = [];
  List<PeonItem> _peones = [];
  List<CamionItem> _camiones = [];
  List<String> _fotosRutas = [];

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (widget.informeExistente != null) {
      final inf = widget.informeExistente!;
      _fecha = inf.fecha;
      _numeroInforme = inf.numeroInforme;
      _contratanteController.text = inf.senorOEmpresaContratante;
      _observacionesController.text = inf.observaciones;
      _maquinas = List.from(inf.maquinas);
      _materiales = List.from(inf.materiales);
      _otrosEquipos = List.from(inf.otrosEquipos);
      _peones = List.from(inf.peonesAyudantes);
      _camiones = List.from(inf.camionesVolcadoras);
      _fotosRutas = List.from(inf.fotosRutas);
      setState(() => _isLoading = false);
    } else {
      _fecha = DateTime.now();
      _numeroInforme = await StorageService.getProximoNroInforme();
      setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DE GUARDADO ---
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String idFinal = widget.informeExistente?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      final nuevoInforme = InformeDiarioModel(
        id: idFinal,
        numeroInforme: _numeroInforme,
        fecha: _fecha,
        obraId: widget.obra.id,
        nombreObra: widget.obra.nombre,
        senorOEmpresaContratante: _contratanteController.text.trim(),
        maquinas: _maquinas,
        materiales: _materiales,
        otrosEquipos: _otrosEquipos,
        peonesAyudantes: _peones,
        camionesVolcadoras: _camiones,
        observaciones: _observacionesController.text.trim(),
        fotosRutas: _fotosRutas,
      );

      if (widget.informeExistente != null) {
        await StorageService.updateInforme(nuevoInforme.toJson());
      } else {
        await StorageService.saveInforme(nuevoInforme.toJson());
        await StorageService.incrementarContadorInforme();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Informe guardado correctamente'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  // --- WIDGETS DE SECCIÓN ---

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children,
      VoidCallback? onAdd}) {
    return Card(
      color: AppColors.corporateCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.beigePastel, size: 24),
                    const SizedBox(width: 10),
                    Text(title,
                        style: AppStyles.titleMedium.copyWith(
                            color: AppColors.beigePastel,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                if (onAdd != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.beigePastelDark, size: 28),
                    onPressed: onAdd,
                  ),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // --- DIÁLOGOS PARA AGREGAR ÍTEMS ---

  void _dialogAddMaquina() {
    String? selMaquina = _mockMaquinas.first;
    String? selChofer = _mockEmpleadosInternos.first;
    final hInicioController = TextEditingController(text: '07:00');
    final hFinController = TextEditingController(text: '18:00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corporateCard,
        title: const Text('Agregar Máquina',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.corporateCard,
              style: const TextStyle(color: Colors.white),
              initialValue: selMaquina,
              items: _mockMaquinas
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => selMaquina = v,
              decoration: const InputDecoration(
                  labelText: 'Máquina',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.corporateCard,
              style: const TextStyle(color: Colors.white),
              initialValue: selChofer,
              items: _mockEmpleadosInternos
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => selChofer = v,
              decoration: const InputDecoration(
                  labelText: 'Chofer Interno',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: hInicioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Hora Inicio',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: hFinController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Hora Final',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                _maquinas.add(MaquinaItem(
                  maquina: selMaquina!,
                  chofer: selChofer!,
                  horaInicio: hInicioController.text,
                  horaFinal: hFinController.text,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Agregar',
                style: TextStyle(color: AppColors.beigePastel)),
          ),
        ],
      ),
    );
  }

  void _dialogAddMaterial() {
    String? selMaterial = _mockMateriales.first;
    final cantController = TextEditingController();
    String selUnidad = 'm3';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.corporateCard,
          title: const Text('Agregar Material',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: AppColors.corporateCard,
                style: const TextStyle(color: Colors.white),
                initialValue: selMaterial,
                items: _mockMateriales
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => selMaterial = v,
                decoration: const InputDecoration(
                    labelText: 'Material',
                    labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: cantController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle: TextStyle(color: Colors.white70)),
              ),
              DropdownButtonFormField<String>(
                dropdownColor: AppColors.corporateCard,
                style: const TextStyle(color: Colors.white),
                initialValue: selUnidad,
                items: ['m3', 'kg']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selUnidad = v!),
                decoration: const InputDecoration(
                    labelText: 'Unidad',
                    labelStyle: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                setState(() {
                  _materiales.add(MaterialItem(
                    material: selMaterial!,
                    cantidad: double.tryParse(cantController.text) ?? 0,
                    unidad: selUnidad,
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Agregar',
                  style: TextStyle(color: AppColors.beigePastel)),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogAddOtroEquipo() {
    String? selEq = _mockOtrosEquipos.first;
    final hInicioController = TextEditingController(text: '07:00');
    final hFinController = TextEditingController(text: '18:00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corporateCard,
        title: const Text('Agregar Otro Equipo',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              dropdownColor: AppColors.corporateCard,
              style: const TextStyle(color: Colors.white),
              initialValue: selEq,
              items: _mockOtrosEquipos
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => selEq = v,
              decoration: const InputDecoration(
                  labelText: 'Equipo',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: hInicioController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Hora Inicio',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: hFinController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Hora Final',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                _otrosEquipos.add(OtroEquipoItem(
                  equipo: selEq!,
                  horaInicio: hInicioController.text,
                  horaFinal: hFinController.text,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Agregar',
                style: TextStyle(color: AppColors.beigePastel)),
          ),
        ],
      ),
    );
  }

  void _dialogAddCamion() {
    String? selCap = _mockCapacidadesCamion.first;
    final marcaController = TextEditingController();
    final matController = TextEditingController();
    final choferController = TextEditingController();
    final viajesController = TextEditingController(text: '1');
    final horasController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corporateCard,
        title: const Text('Agregar Camion Volcadora',
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: AppColors.corporateCard,
                style: const TextStyle(color: Colors.white),
                initialValue: selCap,
                items: _mockCapacidadesCamion
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => selCap = v,
                decoration: const InputDecoration(
                    labelText: 'Capacidad',
                    labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: marcaController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Marca',
                    labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: matController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Matrícula',
                    labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: choferController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Chofer (Externo)',
                    labelStyle: TextStyle(color: Colors.white70)),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: viajesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Viajes',
                          labelStyle: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: horasController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          labelText: 'Horas',
                          labelStyle: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                _camiones.add(CamionItem(
                  capacidad: selCap!,
                  marca: marcaController.text.trim(),
                  matricula: matController.text.trim().toUpperCase(),
                  chofer: choferController.text.trim(),
                  viajes: int.tryParse(viajesController.text) ?? 0,
                  horas: double.tryParse(horasController.text) ?? 0,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Agregar',
                style: TextStyle(color: AppColors.beigePastel)),
          ),
        ],
      ),
    );
  }

  void _dialogAddPeon() {
    final nombreController = TextEditingController();
    final horasController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corporateCard,
        title: const Text('Agregar Peón/Ayudante',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: horasController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Horas Trabajadas',
                  labelStyle: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                _peones.add(PeonItem(
                  nombre: nombreController.text.trim(),
                  horas: double.tryParse(horasController.text) ?? 0,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Agregar',
                style: TextStyle(color: AppColors.beigePastel)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image =
        await _picker.pickImage(source: source, imageQuality: 50);
    if (image != null) {
      setState(() => _fotosRutas.add(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          backgroundColor: AppColors.corporateDark,
          body: Center(
              child: CircularProgressIndicator(color: AppColors.beigePastel)));
    }

    return Scaffold(
      backgroundColor: AppColors.corporateDark,
      appBar: AppBar(
        title: const Text('INFORME DIARIO DE OBRA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.beigePastel,
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.beigePastel,
            foregroundColor: AppColors.corporateDark,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: _submitForm,
          child: const Text('GUARDAR INFORME',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // CABECERA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.corporateCard,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('N° INFORME: $_numeroInforme',
                            style: const TextStyle(
                                color: AppColors.beigePastel,
                                fontWeight: FontWeight.bold)),
                        Text(
                            'FECHA: ${DateFormat('dd/MM/yyyy').format(_fecha)}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('OBRA: ${widget.obra.nombre}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // DATOS GENERALES
              _buildSectionCard(
                title: 'Datos Generales',
                icon: Icons.business,
                children: [
                  TextFormField(
                    controller: _contratanteController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Señor o Empresa Contratante',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                ],
              ),

              // MÁQUINAS
              _buildSectionCard(
                title: 'Máquinas en Obra',
                icon: Icons.precision_manufacturing,
                onAdd: _dialogAddMaquina,
                children: _maquinas.isEmpty
                    ? [
                        const Text('No hay máquinas agregadas',
                            style: TextStyle(
                                color: Colors.white38,
                                fontStyle: FontStyle.italic))
                      ]
                    : _maquinas
                        .map((m) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(m.maquina,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                  '${m.chofer} | ${m.horaInicio} - ${m.horaFinal}',
                                  style:
                                      const TextStyle(color: Colors.white60)),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () =>
                                      setState(() => _maquinas.remove(m))),
                            ))
                        .toList(),
              ),

              // MATERIALES
              _buildSectionCard(
                title: 'Control de Materiales',
                icon: Icons.inventory,
                onAdd: _dialogAddMaterial,
                children: _materiales.isEmpty
                    ? [
                        const Text('No hay materiales registrados',
                            style: TextStyle(
                                color: Colors.white38,
                                fontStyle: FontStyle.italic))
                      ]
                    : _materiales
                        .map((m) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(m.material,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text('${m.cantidad} ${m.unidad}',
                                  style:
                                      const TextStyle(color: Colors.white60)),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () =>
                                      setState(() => _materiales.remove(m))),
                            ))
                        .toList(),
              ),

              // OTROS EQUIPOS
              _buildSectionCard(
                title: 'Otros Equipos',
                icon: Icons.construction,
                onAdd: _dialogAddOtroEquipo,
                children: _otrosEquipos.isEmpty
                    ? [
                        const Text('No hay otros equipos agregados',
                            style: TextStyle(
                                color: Colors.white38,
                                fontStyle: FontStyle.italic))
                      ]
                    : _otrosEquipos
                        .map((e) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(e.equipo,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text('${e.horaInicio} - ${e.horaFinal}',
                                  style:
                                      const TextStyle(color: Colors.white60)),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () =>
                                      setState(() => _otrosEquipos.remove(e))),
                            ))
                        .toList(),
              ),

              // CAMIONES
              _buildSectionCard(
                title: 'Camiones Volcadoras',
                icon: Icons.local_shipping,
                onAdd: _dialogAddCamion,
                children: _camiones.isEmpty
                    ? [
                        const Text('No hay camiones registrados',
                            style: TextStyle(
                                color: Colors.white38,
                                fontStyle: FontStyle.italic))
                      ]
                    : _camiones
                        .map((c) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('${c.marca} (${c.capacidad})',
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                  'Mat: ${c.matricula} | Chofer: ${c.chofer}\n${c.viajes} viajes | ${c.horas} hs',
                                  style:
                                      const TextStyle(color: Colors.white60)),
                              isThreeLine: true,
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () =>
                                      setState(() => _camiones.remove(c))),
                            ))
                        .toList(),
              ),

              // PEONES
              _buildSectionCard(
                title: 'Peones / Ayudantes',
                icon: Icons.groups,
                onAdd: _dialogAddPeon,
                children: _peones.isEmpty
                    ? [
                        const Text('No hay personal registrado',
                            style: TextStyle(
                                color: Colors.white38,
                                fontStyle: FontStyle.italic))
                      ]
                    : _peones
                        .map((p) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(p.nombre,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text('${p.horas} horas trabajadas',
                                  style:
                                      const TextStyle(color: Colors.white60)),
                              trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () =>
                                      setState(() => _peones.remove(p))),
                            ))
                        .toList(),
              ),

              // CIERRE
              _buildSectionCard(
                title: 'Cierre y Fotos',
                icon: Icons.comment,
                children: [
                  TextFormField(
                    controller: _observacionesController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.corporateCard,
                            foregroundColor: AppColors.beigePastel),
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Cámara'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.corporateCard,
                            foregroundColor: AppColors.beigePastel),
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galería'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_fotosRutas.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _fotosRutas.length,
                        itemBuilder: (ctx, i) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              Image.file(File(_fotosRutas[i]),
                                  width: 100, height: 100, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _fotosRutas.removeAt(i)),
                                  child: Container(
                                      color: Colors.red,
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 20)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
