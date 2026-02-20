import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Un botón de acción estilizado para la aplicación.
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Size minimumSize;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.minimumSize = const Size(double.infinity, 70),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: minimumSize,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 30),
      label: Text(label, style: AppStyles.buttonText),
    );
  }
}
