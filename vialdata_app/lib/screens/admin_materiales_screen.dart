import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

class AdminMaterialesScreen extends StatefulWidget {
  const AdminMaterialesScreen({super.key});

  @override
  State<AdminMaterialesScreen> createState() => _AdminMaterialesScreenState();
}

class _AdminMaterialesScreenState extends State<AdminMaterialesScreen> {
  List<String> _materiales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await StorageService.getListaMateriales();
    setState(() {
      _materiales = list;
      _isLoading = false;
    });
  }

  void _addItem() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corporateCard,
        title: const Text('Agregar Material',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre del Material',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final newList = List<String>.from(_materiales)
                  ..add(controller.text.trim());
                await StorageService.saveListaMateriales(newList);
                _loadData();
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Agregar',
                style: TextStyle(color: AppColors.beigePastel)),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corporateCard,
        title: const Text('Eliminar', style: TextStyle(color: Colors.white)),
        content: Text('¿Desea eliminar "$item"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No', style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final newList = List<String>.from(_materiales)..remove(item);
      await StorageService.saveListaMateriales(newList);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.corporateDark,
      appBar: AppBar(
        title: const Text('GESTIONAR MATERIALES'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.beigePastel,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.beigePastel,
        foregroundColor: AppColors.corporateDark,
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.beigePastel))
          : _materiales.isEmpty
              ? const Center(
                  child: Text('No hay materiales cargados',
                      style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _materiales.length,
                  itemBuilder: (ctx, i) {
                    final item = _materiales[i];
                    return Card(
                      color: AppColors.corporateCard,
                      child: ListTile(
                        title: Text(item,
                            style: const TextStyle(color: Colors.white)),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteItem(item),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
