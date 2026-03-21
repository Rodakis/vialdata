import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/obra_model.dart';
import '../services/auth_service.dart';
import 'remito_form_screen.dart';
import 'informe_diario_form_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'admin_obras_screen.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/admin_panel.dart';
import '../widgets/action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ObraModel? selectedObra;
  List<ObraModel> obras = [];
  int _remitosHoy = 0;
  int _informesHoy = 0;
  String _lastReportLabel = 'Aún no registraste nada';
  String _lastReportSubtitle = 'Todavía no hay registros guardados';

  @override
  void initState() {
    super.initState();
    _cargarObras();
    _loadDashboardMetrics();
  }

  /// Carga la lista de obras desde el almacenamiento local.
  Future<void> _cargarObras() async {
    final lista = await StorageService.getObras();
    if (mounted) {
      setState(() {
        obras = lista;
        if (selectedObra != null &&
            !obras.any((o) => o.id == selectedObra!.id)) {
          selectedObra = null;
        }
      });
    }
  }

  Future<void> _loadDashboardMetrics() async {
    final remitos = await StorageService.getRemitos();
    final informes = await StorageService.getInformes();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    int remitosHoy = remitos.where((item) {
      final fecha = _parseFecha(item['fecha']);
      return fecha != null && !fecha.isBefore(todayStart);
    }).length;

    int informesHoy = informes.where((item) {
      final fecha = _parseFecha(item['fecha']);
      return fecha != null && !fecha.isBefore(todayStart);
    }).length;

    DateTime? lastDate;
    String lastLabel = 'Aún no registraste nada';
    String lastSubtitle = 'Todavía no hay registros guardados';

    void evaluate(String type, Map<String, dynamic> item) {
      final fecha = _parseFecha(item['fecha']);
      if (fecha == null) return;
      if (lastDate == null || fecha.isAfter(lastDate!)) {
        lastDate = fecha;
        lastLabel = type == 'remito'
            ? 'Último remito reportado: ${item['nroRemito'] ?? 'N/D'}'
            : 'Último informe reportado: ${item['obra'] ?? 'Sin nombre'}';
        lastSubtitle = 'Fecha: ${DateFormat('dd/MM/yyyy').format(fecha)}';
      }
    }

    for (final item in remitos) {
      evaluate('remito', item);
    }
    for (final item in informes) {
      evaluate('informe', item);
    }

    if (mounted) {
      setState(() {
        _remitosHoy = remitosHoy;
        _informesHoy = informesHoy;
        _lastReportLabel = lastLabel;
        _lastReportSubtitle = lastSubtitle;
      });
    }
  }

  DateTime? _parseFecha(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }

  void _logout() {
    AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('VialData - Campo'),
            Text(
              'Usuario: ${AuthService.currentUser?.username}',
              style: AppStyles.label.copyWith(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppColors.blueGreyDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver Registros',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboardHero(),
            const SizedBox(height: 20),
            if (AuthService.isAdmin)
              AdminPanel(onObraUpdated: () {
                _cargarObras();
                _loadDashboardMetrics();
              }),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                side: const BorderSide(color: AppColors.blueGrey),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
              icon: const Icon(Icons.list_alt, color: AppColors.blueGrey),
              label: const Text(
                'VER MIS REGISTROS GUARDADOS',
                style: TextStyle(
                    color: AppColors.blueGrey, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 28),
            const Text('1. Seleccionar Obra',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (obras.isEmpty)
              _buildEmptyObraCard()
            else ...[
              DropdownButtonFormField<ObraModel>(
                initialValue: selectedObra,
                decoration: AppStyles.inputDecoration(
                  label: '¿En qué obra estás hoy?',
                  prefixIcon: Icons.business,
                  fillColor: AppColors.surfaceCard,
                ),
                items: obras.map((obra) {
                  return DropdownMenuItem(
                    value: obra,
                    child: Text(
                      obra.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedObra = val),
              ),
              const SizedBox(height: 20),
              if (selectedObra != null) _buildActionCluster()
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.heroCardDecoration(),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -30,
            child: Transform.rotate(
              angle: -pi / 5,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumen de Campo', style: AppStyles.heroDisplay),
              const SizedBox(height: 6),
              Text('Data sincronizada con la oficina y recordatorios activos',
                  style: AppStyles.heroSubtitle),
              const SizedBox(height: 18),
              Row(
                children: [
                  _metricBlock('REMITOS HOY', '$_remitosHoy'),
                  const SizedBox(width: 14),
                  _metricBlock('INFORMES HOY', '$_informesHoy'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Chip(
                    backgroundColor:
                        AppColors.reminderAccent.withOpacity(0.25),
                    label: const Text('Recordatorio diario 16:30',
                        style: TextStyle(color: AppColors.reminderAccent)),
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: 'Sincroniza en cuanto hay señal',
                    child: InkWell(
                      onTap: () {},
                      child: const Icon(Icons.bolt, color: AppColors.neonAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.heroCard.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_lastReportLabel, style: AppStyles.label.copyWith(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(_lastReportSubtitle,
                        style: AppStyles.bodyText.copyWith(color: Colors.white70)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyObraCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.surfaceSectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aún no agregaste obras',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'Solicita al administrador crear la obra o hazlo tú desde el panel si tienes permisos.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryBlue,
            ),
            onPressed: () {
              if (AuthService.isAdmin) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminObrasScreen()),
                );
              }
            },
            child: const Text('Ir al panel de obras'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCluster() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('2. ¿Qué vas a registrar?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ActionButton(
          label: 'NUEVO REMITO',
          icon: Icons.local_shipping,
          backgroundColor: AppColors.secondaryBlue,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RemitoFormScreen(obra: selectedObra!),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ActionButton(
          label: 'INFORME DIARIO',
          icon: Icons.assignment,
          backgroundColor: Colors.orange.shade700,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  InformeDiarioFormScreen(obra: selectedObra!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricBlock(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.label.copyWith(fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: AppStyles.heroDisplay.copyWith(fontSize: 32, letterSpacing: 1.2)),
        ],
      ),
    );
  }
}
