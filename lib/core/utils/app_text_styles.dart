import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const normal = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const hint = TextStyle(
    fontSize: 15,
    color: Colors.black38,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subheading = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 13.5,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontSize: 12,
    color: Colors.black54,
  );
}