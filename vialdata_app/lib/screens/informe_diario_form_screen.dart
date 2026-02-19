import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/informe_diario_model.dart';
import '../models/obra_model.dart';
import '../services/storage_service.dart';

class InformeDiarioFormScreen extends StatefulWidget {
  final ObraModel obra;
  final InformeDiarioModel? informeExistente;

  const InformeDiarioFormScreen({
    Key? key, 
    required this.obra, 
    this.informeExistente
  }) : super(key: key);

  @override
  _InformeDiarioFormScreenState createState() => _InformeDiarioFormScreenState();
}

class _InformeDiarioFormScreenState extends State<InformeDiarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _fecha;
  final TextEditingController _horasController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();

  String _actividades = '';
  String _avance = '';
  String _personal = '';
  String _equipos = '';
  String _incidencias = '';
  String _comentarios = '';
  
  List<String> _fotosRutas = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.informeExistente != null) {
      final inf = widget.informeExistente!;
      _fecha = inf.fecha;
      _horasController.text = inf.horasMaquina ?? ''; 
      _kmController.text = inf.kmRecorridos ?? '';
      _actividades = inf.actividades ?? '';
      _avance = inf.avanceDescripcion ?? '';
      _personal = inf.personal ?? '';
      _equipos = inf.equipos ?? '';
      _incidencias = inf.incidencias ?? '';
      _comentarios = inf.comentariosAdicionales ?? '';
      _fotosRutas = List.from(inf.fotosRutas); 
    } else {
      _fecha = DateTime.now();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 50);
    if (image != null) {
      setState(() {
        _fotosRutas.add(image.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String idFinal = widget.informeExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final nuevoInforme = InformeDiarioModel(
        id: idFinal,
        fecha: _fecha,
        obraId: widget.obra.id,
        nombreObra: widget.obra.nombre,
        horasMaquina: _horasController.text,
        kmRecorridos: _kmController.text,
        actividades: _actividades,
        avanceDescripcion: _avance,
        personal: _personal,
        equipos: _equipos,
        incidencias: _incidencias,
        comentariosAdicionales: _comentarios,
        fotosRutas: _fotosRutas,
      );

      if (widget.informeExistente != null) {
        await StorageService.updateInforme(nuevoInforme.toJson());
        if (mounted) _mostrarMensaje('Informe actualizado correctamente');
      } else {
        await StorageService.saveInforme(nuevoInforme.toJson());
        if (mounted) _mostrarMensaje('Informe creado correctamente');
      }
      
      if (mounted) Navigator.pop(context);
    }
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.informeExistente != null ? 'Editar Informe' : 'Nuevo Informe Diario';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text('OBRA: ${widget.obra.nombre}', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade900)),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 5),
                          Text(DateFormat('dd/MM/yyyy').format(_fecha)),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _fecha,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) setState(() => _fecha = picked);
                            },
                            child: const Text('Cambiar Fecha'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Uso de Maquinaria y Vehículos'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horasController,
                      decoration: const InputDecoration(labelText: 'Horas Máquina', prefixIcon: Icon(Icons.timer), border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _kmController,
                      decoration: const InputDecoration(labelText: 'Km Recorridos', prefixIcon: Icon(Icons.speed), border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildTextInput('Actividades Realizadas', _actividades, (val) => _actividades = val, lines: 3),
              _buildTextInput('Descripción del Avance', _avance, (val) => _avance = val, lines: 2),
              _buildTextInput('Personal en Obra', _personal, (val) => _personal = val, lines: 2),
              _buildTextInput('Equipos Utilizados', _equipos, (val) => _equipos = val, lines: 2),
              _buildTextInput('Incidencias / Problemas', _incidencias, (val) => _incidencias = val, lines: 2),
              _buildTextInput('Observaciones Adicionales', _comentarios, (val) => _comentarios = val, lines: 2),

              const SizedBox(height: 20),
              _buildSectionTitle('Evidencia Fotográfica'),
               Row(
                children: [
                  ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Cámara')),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Galería')),
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
                          Image.file(File(_fotosRutas[i]), width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0, top: 0,
                            child: GestureDetector(
                              onTap: (){ setState(() { _fotosRutas.removeAt(i); }); },
                              child: Container(color: Colors.red, child: const Icon(Icons.close, color: Colors.white, size: 20)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitForm,
                child: Text(widget.informeExistente != null ? 'ACTUALIZAR INFORME' : 'GUARDAR INFORME', style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(String label, String valorInicial, Function(String) onSave, {int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        TextFormField(
          initialValue: valorInicial,
          decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
          maxLines: lines,
          onSaved: (val) => onSave(val ?? ''),
          validator: (val) {
             if (label.contains('Actividades') && (val == null || val.isEmpty)) return 'Obligatorio';
             return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 10),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
    );
  }
}