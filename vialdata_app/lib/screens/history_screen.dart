import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../models/informe_diario_model.dart';
import '../models/obra_model.dart';
import '../models/remito_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'informe_diario_form_screen.dart';
import 'remito_form_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<_HistorySummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _summaryFuture = _loadHistorySummary();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSummarySection(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRemitosList(),
                _buildInformesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PESTAÑA 1: REMITOS ---
  Widget _buildRemitosList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: StorageService.getRemitos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return _emptyState('No hay remitos guardados');
        }

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

            final remitoObj = RemitoModel(
              id: item['id'] ?? '',
              fecha: item['fecha'] != null
                  ? DateTime.parse(item['fecha'])
                  : DateTime.now(),
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

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: Text('$material - $cantidad'),
                subtitle: Text('Obra: $obra\nFecha: $fechaTexto'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.blue),
                      onPressed: () =>
                          PdfService.generateAndShareRemito(remitoObj),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _abrirEditorRemito(item);
                      },
                      child: const Text('Editar'),
                    ),
                  ],
                ),
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

    setState(() {
      _summaryFuture = _loadHistorySummary();
    });
  }

  // --- PESTAÑA 2: INFORMES ---
  Widget _buildInformesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: StorageService.getInformes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return _emptyState('No hay informes diarios');
        }

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

            final informeObj = InformeDiarioModel.fromJson(item);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.assignment_turned_in,
                    color: Colors.orange),
                title: Text(titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Fecha: $fechaTexto'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.orange),
                      onPressed: () =>
                          PdfService.generateAndShareInforme(informeObj),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _abrirEditorInforme(item);
                      },
                      child: const Text('Editar'),
                    ),
                  ],
                ),
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
    final informeObj = InformeDiarioModel.fromJson(item);

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

    setState(() {
      _summaryFuture = _loadHistorySummary();
    });
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

  Widget _buildSummarySection() {
    return FutureBuilder<_HistorySummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final summary = snapshot.data!;
        return Container(
          decoration: AppStyles.surfaceSectionDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _summaryChip('Remitos', summary.remitos.toString()),
                  const SizedBox(width: 12),
                  _summaryChip('Informes', summary.informes.toString()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Chip(
                      backgroundColor:
                          AppColors.reminderAccent.withOpacity(0.15),
                      label: const Text('Recordatorio diario 16:30',
                          style: TextStyle(color: AppColors.reminderAccent)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(summary.lastTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(summary.lastDate != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(summary.lastDate!)
                  : 'Aún no hay registros guardados'),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(fontSize: 20, color: Colors.white)),
            Text(label, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  Future<_HistorySummary> _loadHistorySummary() async {
    final remitos = await StorageService.getRemitos();
    final informes = await StorageService.getInformes();
    DateTime? lastDate;
    String lastTitle = 'Sin registros guardados';
    DateTime? lastDateShown;

    void evaluate(String type, Map<String, dynamic> item) {
      final fecha = _parseFecha(item['fecha']);
      if (fecha == null) return;
      if (lastDate == null || fecha.isAfter(lastDate!)) {
        lastDate = fecha;
        lastDateShown = fecha;
        lastTitle = type == 'remito'
            ? 'Remito ${item['nroRemito'] ?? 'N/D'} - ${item['obra'] ?? 'Obra desconocida'}'
            : 'Informe ${item['obra'] ?? 'Sin obra'}';
      }
    }

    for (final item in remitos) {
      evaluate('remito', item);
    }
    for (final item in informes) {
      evaluate('informe', item);
    }

    return _HistorySummary(
      remitos: remitos.length,
      informes: informes.length,
      lastTitle: lastTitle,
      lastDate: lastDateShown,
    );
  }

  DateTime? _parseFecha(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }
}

class _HistorySummary {
  final int remitos;
  final int informes;
  final String lastTitle;
  final DateTime? lastDate;

  _HistorySummary({
    required this.remitos,
    required this.informes,
    required this.lastTitle,
    required this.lastDate,
  });
}
