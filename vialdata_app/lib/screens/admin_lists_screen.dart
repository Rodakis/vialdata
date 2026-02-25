import 'package:flutter/material.dart';
import '../services/config_service.dart';

class AdminListsScreen extends StatefulWidget {
  const AdminListsScreen({super.key});

  @override
  State<AdminListsScreen> createState() => _AdminListsScreenState();
}

class _AdminListsScreenState extends State<AdminListsScreen> {
  // Controlamos qué lista estamos editando
  String _currentListType = 'materiales';
  final TextEditingController _itemController = TextEditingController();

  // Obtener la lista actual según la selección
  List<String> get _currentList {
    switch (_currentListType) {
      case 'materiales':
        return ConfigService.materiales;
      case 'origenes':
        return ConfigService.origenes;
      case 'transportistas':
        return ConfigService.transportistas;
      case 'recibidores':
        return ConfigService.recibidores;
      default:
        return [];
    }
  }

  void _addItem() async {
    if (_itemController.text.isNotEmpty) {
      await ConfigService.addItem(
          _currentListType, _itemController.text.trim());
      _itemController.clear();
      setState(() {}); // Refrescar UI
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Elemento agregado')));
      }
    }
  }

  void _deleteItem(String item) async {
    await ConfigService.removeItem(_currentListType, item);
    setState(() {}); // Refrescar UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Listas'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // SELECTOR DE TIPO DE LISTA
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: DropdownButtonFormField<String>(
              initialValue: _currentListType,
              decoration: const InputDecoration(
                labelText: 'Seleccione qué lista editar',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              items: const [
                DropdownMenuItem(
                    value: 'materiales', child: Text('Materiales')),
                DropdownMenuItem(
                    value: 'origenes', child: Text('Orígenes / Procedencia')),
                DropdownMenuItem(
                    value: 'transportistas',
                    child: Text('Empresas Transportistas')),
                DropdownMenuItem(
                    value: 'recibidores',
                    child: Text('Recibidores / Capataces')),
              ],
              onChanged: (val) {
                setState(() {
                  _currentListType = val!;
                });
              },
            ),
          ),

          // CAMPO PARA AGREGAR NUEVO
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      labelText: 'Nuevo $_currentListType',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.green, size: 30),
                        onPressed: _addItem,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // LISTADO DE ELEMENTOS EXISTENTES
          Expanded(
            child: ListView.builder(
              itemCount: _currentList.length,
              itemBuilder: (context, index) {
                final item = _currentList[index];
                return ListTile(
                  title: Text(item),
                  leading:
                      const Icon(Icons.label_important, color: Colors.grey),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
