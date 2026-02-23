import 'package:flutter/material.dart';
import '../models/obra_model.dart';
import '../services/storage_service.dart';

class AdminObrasScreen extends StatefulWidget {
  const AdminObrasScreen({super.key});

  @override
  State<AdminObrasScreen> createState() => _AdminObrasScreenState();
}

class _AdminObrasScreenState extends State<AdminObrasScreen> {
  List<ObraModel> _obras = [];
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    final lista = await StorageService.getObras();
    setState(() {
      _obras = lista;
    });
  }

  void _agregarObra() async {
    if (_nombreController.text.isEmpty) return;

    final nuevaObra = ObraModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text,
      direccion: _direccionController.text,
    );

    setState(() {
      _obras.add(nuevaObra);
    });

    await StorageService.saveObras(_obras);
    _nombreController.clear();
    _direccionController.clear();
    Navigator.pop(context); // Cerrar el diálogo
  }

  void _borrarObra(String id) async {
    setState(() {
      _obras.removeWhere((obra) => obra.id == id);
    });
    await StorageService.saveObras(_obras);
  }

  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Obra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nombreController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de la Obra')),
            TextField(
                controller: _direccionController,
                decoration:
                    const InputDecoration(labelText: 'Dirección / Ubicación')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(onPressed: _agregarObra, child: const Text('Guardar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Obras')),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        child: const Icon(Icons.add),
      ),
      body: _obras.isEmpty
          ? const Center(
              child: Text('No hay obras registradas. Agrega una (+).'))
          : ListView.builder(
              itemCount: _obras.length,
              itemBuilder: (ctx, i) {
                final obra = _obras[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.business)),
                    title: Text(obra.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(obra.direccion),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _borrarObra(obra.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
