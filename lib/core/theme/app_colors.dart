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

  // Standard UI surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);

  // Backward-compatible aliases used by existing screens.
  static const Color backgroundTop = background;
  static const Color backgroundMiddle = background;
  static const Color backgroundBottom = background;

  static const Color darkBackgroundTop = darkBackground;
  static const Color darkBackgroundMiddle = darkBackground;
  static const Color darkBackgroundBottom = darkBackground;

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textInverse = Colors.white;
  
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  // Legacy parameters retained for old widget constructors.
  static const double appOpacity = 1.0;
  static const double appBlur = 0.0;
}
