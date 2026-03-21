import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Clase que centraliza los estilos y decoraciones de la aplicación.
class AppStyles {
  static TextStyle get heroDisplay => GoogleFonts.bellefair(
        fontSize: 34,
        color: AppColors.beigePastelLight,
        letterSpacing: 2.5,
      );

  static TextStyle get heroSubtitle => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: AppColors.beigePastelLight.withOpacity(0.9),
        height: 1.5,
      );

  static TextStyle get bodyText => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        color: AppColors.beigePastel,
        letterSpacing: 0.4,
      );

  static TextStyle get label => GoogleFonts.rajdhani(
        fontSize: 14,
        color: AppColors.beigePastelLight,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get sectionTitle => GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.secondaryBlue,
      );

  static TextStyle get chipLabel => GoogleFonts.rajdhani(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.beigePastelLight,
      );

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
      labelStyle: labelStyle ??
          GoogleFonts.manrope(color: AppColors.beigePastelLight),
      floatingLabelStyle: floatingLabelStyle,
      helperText: helperText,
      hintText: hintText,
      hintStyle: hintStyle,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.beigePastelLight)
          : null,
      border: border ??
          OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      filled: filled,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }

  static BoxDecoration heroCardDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.heroGradientStart, AppColors.heroGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.all(Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black54,
          blurRadius: 26,
          offset: Offset(0, 16),
        ),
      ],
    );
  }

  static BoxDecoration surfaceSectionDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      border: Border.all(color: AppColors.beigePastelLight.withOpacity(0.2)),
      gradient: const LinearGradient(
        colors: [AppColors.surfaceCard, Color(0xFF1C2230)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration glassPanel() {
    return BoxDecoration(
      color: AppColors.heroCard.withOpacity(0.7),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      border: Border.all(color: Colors.white24),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 30,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  static TextStyle get buttonText => GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.beigePastelLight,
      );

  static BoxDecoration cardDecoration({
    Color color = AppColors.heroCard,
    double borderRadius = 12,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color,
      border: borderColor != null ? Border.all(color: borderColor) : null,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}
