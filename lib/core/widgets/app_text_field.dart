import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String)? onChanged;
  final bool isPhone;
  final bool isNumber;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.isPhone = false,
    this.isNumber = false,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: isPhone || isNumber
            ? TextInputType.phone
            : TextInputType.text,
        maxLength: isPhone ? 10 : maxLength,
        inputFormatters: isPhone || isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        textAlign: textAlign,
        style: style ?? AppTextStyles.normal,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          filled: true,
          fillColor: AppColors.background,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}