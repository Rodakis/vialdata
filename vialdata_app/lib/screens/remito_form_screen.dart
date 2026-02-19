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
  
  late DateTime _fecha; // Será fija
  
  final TextEditingController _nroRemitoController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();
  final TextEditingController _patenteController = TextEditingController();
  final TextEditingController _choferController = TextEditingController();
  
  // Nuevo campo de Guía y Materiales
  final TextEditingController _guiaController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  
  String? _fotoRuta;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.remitoExistente != null) {
      // MODO EDICIÓN
      final r = widget.remitoExistente!;
      _fecha = r.fecha; // Mantiene la fecha original
      _nroRemitoController.text = r.nroRemito;
      _proveedorController.text = r.proveedor;
      _patenteController.text = r.patente;
      _choferController.text = r.chofer;
      _guiaController.text = r.nroGuia; // Recuperamos guía
      _materialController.text = r.material;
      _cantidadController.text = r.cantidad;
      _fotoRuta = r.fotoRuta.isNotEmpty ? r.fotoRuta : null;
    } else {
      // MODO NUEVO
      _fecha = DateTime.now(); // Fecha actual fija
      _cargarNumeroAutomatico(); // Buscamos el siguiente número
    }
  }

  Future<void> _cargarNumeroAutomatico() async {
    // Pedimos al servicio el próximo número disponible
    String proximo = await StorageService.getProximoNroRemito();
    setState(() {
      _nroRemitoController.text = proximo;
    });
  }

  Future<void> _tomarFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (foto != null) setState(() => _fotoRuta = foto.path);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_fotoRuta == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta la foto del remito')));
        return;
      }
      _formKey.currentState!.save();

      final idFinal = widget.remitoExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final nuevoRemito = RemitoModel(
        id: idFinal,
        fecha: _fecha,
        obraId: widget.obra.id,
        nombreObra: widget.obra.nombre,
        nroRemito: _nroRemitoController.text,
        proveedor: _proveedorController.text,
        patente: _patenteController.text,
        chofer: _choferController.text,
        nroGuia: _guiaController.text, // Guardamos guía
        material: _materialController.text,
        cantidad: _cantidadController.text,
        fotoRuta: _fotoRuta!,
      );

      if (widget.remitoExistente != null) {
        // Si editamos, actualizamos
        await StorageService.updateRemito(nuevoRemito.toJson());
      } else {
        // Si es nuevo, guardamos e incrementamos el contador oficial
        await StorageService.saveRemito(nuevoRemito.toJson());
        await StorageService.incrementarContadorRemito();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado correctamente'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.remitoExistente != null ? 'Editar Remito' : 'Nuevo Remito'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // INFO CABECERA (OBRA + FECHA FIJA)
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
                        // Muestra la fecha fija, ya no hay botón para cambiarla
                        Text(DateFormat('dd/MM/yyyy\nHH:mm').format(_fecha), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- FILA 1: Nro Remito (AUTO) y Nro Guía (NUEVO) ---
              Row(children: [
                Expanded(
                  // Este campo es SOLO LECTURA (readOnly: true)
                  child: TextFormField(
                    controller: _nroRemitoController,
                    readOnly: true, 
                    decoration: const InputDecoration(
                      labelText: 'N° Remito (Auto)', 
                      prefixIcon: Icon(Icons.tag, color: Colors.blue), 
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFEEEEEE), // Grisecito para indicar que es automático
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildInput(_guiaController, 'N° Guía', Icons.receipt_long)),
              ]),
              const SizedBox(height: 15),

              // --- FILA 2: Proveedor y Chofer ---
              Row(children: [
                Expanded(child: _buildInput(_proveedorController, 'Proveedor', Icons.store)),
                const SizedBox(width: 10),
                Expanded(child: _buildInput(_choferController, 'Chofer', Icons.person)),
              ]),
              const SizedBox(height: 15),
              
              // --- FILA 3: Patente ---
              _buildInput(_patenteController, 'Patente Vehículo', Icons.directions_car),
              const SizedBox(height: 20),

              const Divider(thickness: 2),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("DETALLE DE CARGA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),

              // --- FILA 4: Material y Cantidad ---
              _buildInput(_materialController, 'Material (Ej: Ripio)', Icons.category, required: true),
              const SizedBox(height: 15),
              _buildInput(_cantidadController, 'Cantidad (m3)', Icons.numbers, isNumber: true, required: true),
              
              const SizedBox(height: 20),

              // FOTO
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _fotoRuta == null
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(icon: const Icon(Icons.camera_alt, size: 50, color: Colors.blueGrey), onPressed: _tomarFoto),
                          const Text("Toca para tomar foto")
                        ],
                      ))
                    : GestureDetector(onTap: _tomarFoto, child: Image.file(File(_fotoRuta!), fit: BoxFit.cover)),
              ),
              
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15), 
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitForm,
                child: const Text('GUARDAR REMITO', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon, size: 20), 
        border: const OutlineInputBorder(), 
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15)
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: required ? (v) => v!.isEmpty ? 'Requerido' : null : null,
    );
  }
}