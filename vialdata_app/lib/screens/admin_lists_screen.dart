import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AdminListsScreen extends StatefulWidget {
  const AdminListsScreen({super.key});

  @override
  State<AdminListsScreen> createState() => _AdminListsScreenState();
}

class _AdminListsScreenState extends State<AdminListsScreen> {
  String _currentListType = 'origenes';
  final TextEditingController _itemController = TextEditingController();
  List<String> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    List<String> list;
    switch (_currentListType) {
      case 'origenes':
        list = await StorageService.getListaOrigenes();
        break;
      case 'transportistas':
        list = await StorageService.getListaTransportistas();
        break;
      case 'recibidores':
        list = await StorageService.getListaRecibidores();
        break;
      case 'materiales':
        list = await StorageService.getListaMateriales();
        break;
      default:
        list = [];
    }
    setState(() {
      _items = list;
      _isLoading = false;
    });
  }

  void _addItem() async {
    if (_itemController.text.trim().isNotEmpty) {
      final newItem = _itemController.text.trim();
      final newList = List<String>.from(_items)..add(newItem);

      switch (_currentListType) {
        case 'origenes':
          await StorageService.saveListaOrigenes(newList);
          break;
        case 'transportistas':
          await StorageService.saveListaTransportistas(newList);
          break;
        case 'recibidores':
          await StorageService.saveListaRecibidores(newList);
          break;
        case 'materiales':
          await StorageService.saveListaMateriales(newList);
          break;
      }

      _itemController.clear();
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Elemento agregado')));
      }
    }
  }

  void _deleteItem(String item) async {
    final newList = List<String>.from(_items)..remove(item);
    switch (_currentListType) {
      case 'origenes':
        await StorageService.saveListaOrigenes(newList);
        break;
      case 'transportistas':
        await StorageService.saveListaTransportistas(newList);
        break;
      case 'recibidores':
        await StorageService.saveListaRecibidores(newList);
        break;
      case 'materiales':
        await StorageService.saveListaMateriales(newList);
        break;
    }
    _loadData();
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
                _loadData();
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item),
                        leading: const Icon(Icons.label_important,
                            color: Colors.grey),
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
