import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/informe_diario_model.dart';
import '../models/obra_model.dart';
import '../models/remito_model.dart';
import 'informe_diario_form_screen.dart';
import 'remito_form_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros Guardados'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.local_shipping), text: 'REMITOS'),
            Tab(icon: Icon(Icons.assignment), text: 'INFORMES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemitosList(),
          _buildInformesList(),
        ],
      ),
    );
  }

  // --- PESTAÑA 1: REMITOS ---
  Widget _buildRemitosList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: StorageService.getRemitos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return _emptyState('No hay remitos guardados');

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            
            final material = item['material'] ?? '---';
            final cantidad = item['cantidad'] ?? '---';
            final obra = item['obra'] ?? 'Sin Obra';
            
            String fechaTexto = '---';
            if (item['fecha'] != null) {
              try {
                fechaTexto = item['fecha'].toString().split('T')[0];
              } catch (e) {
                fechaTexto = 'Fecha inválida';
              }
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: Text('$material - $cantidad'),
                subtitle: Text('Obra: $obra\nFecha: $fechaTexto\nTap para editar...'),
                isThreeLine: true,
                trailing: const Icon(Icons.edit, color: Colors.grey),
                onTap: () async {
                  await _abrirEditorRemito(item);
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- ABRIR EDITOR DE REMITO ---
  Future<void> _abrirEditorRemito(Map<String, dynamic> item) async {
    DateTime fechaParseada;
    try {
      fechaParseada = DateTime.parse(item['fecha']);
    } catch (e) {
      fechaParseada = DateTime.now();
    }

    final remitoObj = RemitoModel(
      id: item['id'],
      fecha: fechaParseada,
      obraId: item['obraId'] ?? 'unknown',
      nombreObra: item['obra'] ?? 'Obra Desconocida',
      nroRemito: item['nroRemito'] ?? '',
      nroGuia: item['nroGuia'] ?? '',
      procedencia: item['procedencia'] ?? '',
      destino: item['destino'] ?? '',
      material: item['material'] ?? '',
      cantidad: item['cantidad'] ?? '',
      horaDescarga: item['horaDescarga'] ?? '',
      recibidor: item['recibidor'] ?? '',
      empresaTransportista: item['empresaTransportista'] ?? '',
      patenteCamion: item['patenteCamion'] ?? '',
      patenteAcoplado: item['patenteAcoplado'] ?? '',
      chofer: item['chofer'] ?? '',
      observaciones: item['observaciones'] ?? '',
      fotoRuta: item['fotoRuta'] ?? '',
    );

    final obraObj = ObraModel(
      id: item['obraId'] ?? 'unknown',
      nombre: item['obra'] ?? 'Obra Desconocida',
      direccion: '',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RemitoFormScreen(
          obra: obraObj,
          remitoExistente: remitoObj,
        ),
      ),
    );

    setState(() {});
  }

  // --- PESTAÑA 2: INFORMES ---
  Widget _buildInformesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: StorageService.getInformes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return _emptyState('No hay informes diarios');

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            
            final titulo = item['obra'] ?? 'Obra sin nombre';
            String fechaTexto = '---';
             if (item['fecha'] != null) {
              try {
                fechaTexto = item['fecha'].toString().split('T')[0];
              } catch (e) {
                fechaTexto = 'Fecha inválida';
              }
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.assignment_turned_in, color: Colors.orange),
                title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Fecha: $fechaTexto\nTap para editar...'),
                isThreeLine: true,
                trailing: const Icon(Icons.edit, color: Colors.grey),
                onTap: () async {
                  await _abrirEditorInforme(item);
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- ABRIR EDITOR DE INFORME ---
  Future<void> _abrirEditorInforme(Map<String, dynamic> item) async {
    DateTime fechaParseada;
    try {
      fechaParseada = DateTime.parse(item['fecha']);
    } catch (e) {
      fechaParseada = DateTime.now();
    }

    final informeObj = InformeDiarioModel(
      id: item['id'],
      fecha: fechaParseada,
      obraId: item['obraId'] ?? '',
      nombreObra: item['obra'] ?? '',
      horasMaquina: item['horasMaquina'] ?? '',
      kmRecorridos: item['kmRecorridos'] ?? '',
      actividades: item['actividades'] ?? '',
      avanceDescripcion: item['avanceDescripcion'] ?? '',
      personal: item['personal'] ?? '',
      equipos: item['equipos'] ?? '',
      incidencias: item['incidencias'] ?? '',
      comentariosAdicionales: item['observaciones'] ?? '', 
      fotosRutas: List<String>.from(item['fotosRutas'] ?? []),
    );

    final obraObj = ObraModel(
      id: item['obraId'] ?? 'unknown',
      nombre: item['obra'] ?? 'Obra',
      direccion: '',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InformeDiarioFormScreen(
          obra: obraObj,
          informeExistente: informeObj,
        ),
      ),
    );

    setState(() {});
  }

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}