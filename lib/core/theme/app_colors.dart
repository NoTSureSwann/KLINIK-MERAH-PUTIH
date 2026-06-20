import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF60A5FA);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color danger = Color(0xFFEF4444);

  // Background Gradient Colors
  static const Color backgroundTop = Color(0xFFE0F2FE);
  static const Color backgroundMiddle = Color(0xFFDBEAFE);
  static const Color backgroundBottom = Color(0xFFBFDBFE);
  
  // Background Colors for Dark Mode
  static const Color darkBackgroundTop = Color(0xFF0F172A);
  static const Color darkBackgroundMiddle = Color(0xFF1E293B);
  static const Color darkBackgroundBottom = Color(0xFF334155);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textInverse = Colors.white;
  
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  // Glassmorphism default parameters
  static const double glassOpacity = 0.20;
  static const double glassBlur = 20.0;
}
