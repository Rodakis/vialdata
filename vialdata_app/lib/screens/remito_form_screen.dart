import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/obra_model.dart';
import '../models/remito_model.dart';
import '../services/storage_service.dart';

class RemitoFormScreen extends StatefulWidget {
  final ObraModel obra;
  final RemitoModel? remitoExistente;

  const RemitoFormScreen({Key? key, required this.obra, this.remitoExistente}) : super(key: key);

  @override
  _RemitoFormScreenState createState() => _RemitoFormScreenState();
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

  @override
  void initState() {
    super.initState();
    if (widget.remitoExistente != null) {
      final r = widget.remitoExistente!;
      _fecha = r.fecha;
      _nroRemitoController.text = r.nroRemito;
      _nroGuiaController.text = r.nroGuia;
      _procedenciaController.text = r.procedencia;
      _destinoController.text = r.destino;
      _materialController.text = r.material;
      _cantidadController.text = r.cantidad;
      _horaDescargaController.text = r.horaDescarga;
      _recibidorController.text = r.recibidor;
      _empresaController.text = r.empresaTransportista;
      _patenteCamionController.text = r.patenteCamion;
      _patenteAcopladoController.text = r.patenteAcoplado;
      _choferController.text = r.chofer;
      _observacionesController.text = r.observaciones;
      _fotoRuta = r.fotoRuta.isNotEmpty ? r.fotoRuta : null;
    } else {
      _fecha = DateTime.now();
      _cargarNumeroAutomatico();
      _destinoController.text = widget.obra.nombre; 
    }
  }

  Future<void> _cargarNumeroAutomatico() async {
    String proximo = await StorageService.getProximoNroRemito();
    setState(() => _nroRemitoController.text = proximo);
  }

  Future<void> _tomarFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (foto != null) setState(() => _fotoRuta = foto.path);
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      setState(() => _horaDescargaController.text = picked.format(context));
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_fotoRuta == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta la foto del remito')));
        return;
      }
      _formKey.currentState!.save();

      final nuevoRemito = RemitoModel(
        id: widget.remitoExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fecha: _fecha,
        obraId: widget.obra.id,
        nombreObra: widget.obra.nombre,
        nroRemito: _nroRemitoController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado correctamente'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.remitoExistente != null ? 'Editar Remito' : 'Nuevo Remito'), backgroundColor: Colors.blueGrey),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.blueGrey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('OBRA', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700)),
                        Text(widget.obra.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('FECHA (AUTO)', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700)),
                        Text(DateFormat('dd/MM/yyyy\nHH:mm').format(_fecha), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ),
              ),

              _buildSectionTitle('1. Identificación'),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _nroRemitoController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'N° Remito (Auto)', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFEEEEEE)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _nroGuiaController, decoration: const InputDecoration(labelText: 'N° Guía *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null)),
              ]),

              _buildSectionTitle('2. Origen y Destino'),
              TextFormField(controller: _procedenciaController, decoration: const InputDecoration(labelText: 'Procedencia', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextFormField(controller: _destinoController, decoration: const InputDecoration(labelText: 'Destino', border: OutlineInputBorder(), helperText: 'Editable si es necesario')),

              _buildSectionTitle('3. Datos de Carga'),
              Row(children: [
                Expanded(child: TextFormField(controller: _materialController, decoration: const InputDecoration(labelText: 'Material', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Req.' : null)),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _cantidadController, decoration: const InputDecoration(labelText: 'Cantidad (m3)', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Req.' : null)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _horaDescargaController, readOnly: true, onTap: _seleccionarHora, decoration: const InputDecoration(labelText: 'Hora Descarga', border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time)))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _recibidorController, decoration: const InputDecoration(labelText: 'Recibidor', border: OutlineInputBorder()))),
              ]),

              _buildSectionTitle('4. Transporte (Opcional)'),
              TextFormField(controller: _empresaController, decoration: const InputDecoration(labelText: 'Empresa Transportista', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _patenteCamionController, decoration: const InputDecoration(labelText: 'Patente Camión', border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _patenteAcopladoController, decoration: const InputDecoration(labelText: 'Patente Acoplado', border: OutlineInputBorder()))),
              ]),
              const SizedBox(height: 10),
              TextFormField(controller: _choferController, decoration: const InputDecoration(labelText: 'Chofer', border: OutlineInputBorder())),

              _buildSectionTitle('5. Fotos y Cierre'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _tomarFoto,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: Colors.grey.shade200, border: Border.all(color: Colors.grey)),
                      child: _fotoRuta == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) : Image.file(File(_fotoRuta!), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _observacionesController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Observaciones', border: OutlineInputBorder(), alignLabelWithHint: true),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.blue.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: _submitForm,
                child: const Text('GUARDAR REMITO', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}