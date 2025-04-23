import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF4CD964);
  static const Color lightGreen = Color(0xFFB4E9BC);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}