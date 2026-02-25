import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

class ConfigInformesScreen extends StatelessWidget {
  const ConfigInformesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.corporateDark,
        appBar: AppBar(
          title: const Text('CONFIGURAR INFORMES'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.beigePastel,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.beigePastel,
            labelColor: AppColors.beigePastel,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: 'Máquinas'),
              Tab(text: 'Choferes'),
              Tab(text: 'Equipos'),
              Tab(text: 'Peones'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListManagerTab(type: _ListType.maquinas),
            _ListManagerTab(type: _ListType.choferes),
            _ListManagerTab(type: _ListType.equipos),
            _ListManagerTab(type: _ListType.peones),
          ],
        ),
      ),
    );
  }
}

enum _ListType { maquinas, choferes, equipos, peones }

class _ListManagerTab extends StatefulWidget {
  final _ListType type;
  const _ListManagerTab({required this.type});

  @override
  State<_ListManagerTab> createState() => _ListManagerTabState();
}

class _ListManagerTabState extends State<_ListManagerTab> {
  List<String> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<String> list;
    switch (widget.type) {
      case _ListType.maquinas:
        list = await StorageService.getListaMaquinas();
        break;
      case _ListType.choferes:
        list = await StorageService.getListaChoferes();
        break;
      case _ListType.equipos:
        list = await StorageService.getListaOtrosEquipos();
        break;
      case _ListType.peones:
        list = await StorageService.getListaPeones();
        break;
    }
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData(List<String> newList) async {
    switch (widget.type) {
      case _ListType.maquinas:
        await StorageService.saveListaMaquinas(newList);
        break;
      case _ListType.choferes:
        await StorageService.saveListaChoferes(newList);
        break;
      case _ListType.equipos:
        await StorageService.saveListaOtrosEquipos(newList);
        break;
      case _ListType.peones:
        await StorageService.saveListaPeones(newList);
        break;
    }
    _loadData();
  }

  void _addItem() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.corporateCard,
        title: Text('Agregar ${widget.type.name}',
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre / Descripción',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _saveData(
                    List<String>.from(_items)..add(controller.text.trim()));
                Navigator.pop(ctx);
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
      _saveData(List<String>.from(_items)..remove(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppColors.beigePastel));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.beigePastel,
        foregroundColor: AppColors.corporateDark,
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
      body: _items.isEmpty
          ? const Center(
              child:
                  Text('Lista vacía', style: TextStyle(color: Colors.white38)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final item = _items[i];
                return Card(
                  color: AppColors.corporateCard,
                  child: ListTile(
                    title:
                        Text(item, style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteItem(item),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
