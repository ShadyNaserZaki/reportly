import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final TextInputType inputType;

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
    this.inputType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      obscuringCharacter: '•',
      keyboardType: widget.inputType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 13.sp,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
        errorText: widget.errorText,
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
          fontSize: 9.sp,
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: AppColors.primary, size: 18.sp)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.primary,
                  size: 18.sp,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          vertical: 10.h,
          horizontal: 12.w,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.3),
        ),
      ),
    );
  }
}
