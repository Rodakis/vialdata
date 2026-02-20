import 'package:flutter/material.dart';
import '../screens/admin_users_screen.dart';
import '../screens/admin_obras_screen.dart';
import '../screens/admin_lists_screen.dart';
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
          const SizedBox(height: 10),
          _AdminButton(
            icon: Icons.list,
            label: 'Gestionar Listas (Materiales/Empresas)',
            color: Colors.red.shade700,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminListsScreen()),
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
