import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_styles.dart';

/// Un campo de texto personalizado con estilos consistentes.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? prefixIcon;
  final String? helperText;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final String? initialValue;
  final Function(String?)? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final InputBorder? border;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.prefixIcon,
    this.helperText,
    this.hintText,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.fillColor,
    this.border,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.maxLines = 1,
    this.initialValue,
    this.onSaved,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      style: style,
      decoration: AppStyles.inputDecoration(
        label: label,
        prefixIcon: prefixIcon,
        helperText: helperText,
        hintText: hintText,
        hintStyle: hintStyle,
        labelStyle: labelStyle,
        fillColor: fillColor ?? Colors.white,
        border: border,
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      maxLines: maxLines,
      onSaved: onSaved,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
    );
  }
}
