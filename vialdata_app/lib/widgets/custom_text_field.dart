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

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.prefixIcon,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.maxLines = 1,
    this.initialValue,
    this.onSaved,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: AppStyles.inputDecoration(
        label: label,
        prefixIcon: prefixIcon,
        helperText: helperText,
      ),
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      maxLines: maxLines,
      onSaved: onSaved,
      inputFormatters: inputFormatters,
    );
  }
}
