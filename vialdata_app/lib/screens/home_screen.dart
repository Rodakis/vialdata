import 'package:flutter/material.dart';
import '../models/obra_model.dart';
import '../services/auth_service.dart';
import 'remito_form_screen.dart';
import 'informe_diario_form_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarObras();
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
              style: AppStyles.subtitleSmall,
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Panel de administrador
              if (AuthService.isAdmin) AdminPanel(onObraUpdated: _cargarObras),

              // Botón de historial
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

              const SizedBox(height: 20),

              const Text('1. Seleccionar Obra', style: AppStyles.titleLarge),
              const SizedBox(height: 10),

              DropdownButtonFormField<ObraModel>(
                initialValue: selectedObra,
                decoration: AppStyles.inputDecoration(
                  label: '',
                  prefixIcon: Icons.business,
                ),
                hint: const Text('¿En qué obra estás hoy?'),
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

              if (selectedObra != null) ...[
                const Text('2. ¿Qué vas a registrar?',
                    style: AppStyles.titleLarge),
                const SizedBox(height: 20),
                ActionButton(
                  label: 'NUEVO REMITO',
                  icon: Icons.local_shipping,
                  backgroundColor: AppColors.secondaryBlue,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RemitoFormScreen(obra: selectedObra!),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
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
              ]
            ],
          ),
        ),
      ),
    );
  }
}
