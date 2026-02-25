import 'package:flutter/material.dart';
import '../screens/admin_users_screen.dart';
import '../screens/admin_obras_screen.dart';
import '../screens/admin_lists_screen.dart';
import '../screens/config_informes_screen.dart';
import '../screens/admin_materiales_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

/// Panel de herramientas para administradores.
class AdminPanel extends StatelessWidget {
  final VoidCallback onObraUpdated;

  const AdminPanel({super.key, required this.onObraUpdated});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: AppStyles.cardDecoration(
        color: AppColors.adminRedLight,
        borderColor: Colors.red.shade200,
      ),
      child: Column(
        children: [
          const Text(
            'PANEL ADMINISTRADOR',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.adminRed),
          ),
          const SizedBox(height: 10),
          _AdminButton(
            icon: Icons.person_add,
            label: 'Gestionar Usuarios (Personas)',
            color: AppColors.adminRed,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _AdminButton(
            icon: Icons.business,
            label: 'Gestionar Proyectos / Obras',
            color: AppColors.adminRedDark,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminObrasScreen()),
              );
              onObraUpdated();
            },
          ),
          _AdminButton(
            icon: Icons.list,
            label: 'Gestionar Listas (Varios)',
            color: Colors.red.shade700,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminListsScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _AdminButton(
            icon: Icons.inventory,
            label: 'Gestionar Materiales',
            color: Colors.blueGrey,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminMaterialesScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _AdminButton(
            icon: Icons.settings_applications,
            label: 'Configurar Informes Diarios',
            color: const Color(0xFFC62828), // Rojo oscuro/Naranja oscuro
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConfigInformesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _AdminButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 40),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
