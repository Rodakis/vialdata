import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Clase que centraliza los estilos y decoraciones de la aplicación.
class AppStyles {
  // Estilos de texto
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleSmall = TextStyle(
    fontSize: 12,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.secondaryBlue,
  );

  // Decoraciones
  static InputDecoration inputDecoration({
    required String label,
    IconData? prefixIcon,
    String? helperText,
    String? hintText,
    bool filled = true,
    Color? fillColor = Colors.white,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    TextStyle? floatingLabelStyle,
    InputBorder? border,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: labelStyle,
      floatingLabelStyle: floatingLabelStyle,
      helperText: helperText,
      hintText: hintText,
      hintStyle: hintStyle,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      border: border ?? const OutlineInputBorder(),
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      filled: filled,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  static BoxDecoration cardDecoration({
    Color color = AppColors.adminRedLight,
    double borderRadius = 8,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color,
      border: borderColor != null ? Border.all(color: borderColor) : null,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
