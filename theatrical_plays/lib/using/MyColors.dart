import 'package:flutter/material.dart';

class MyColors {
  static final light = MyColors._light();
  static final dark = MyColors._dark();

  final Color background;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;
  final Color iconColor;

  MyColors._light()
      : background = const Color(0xFFFFFFFF), // White
        primaryText = const Color(0xFF1E1E1E), // Near Black
        secondaryText = const Color(0xFF8E8E93), // Soft Gray
        accent = const Color(0xFF00BFA6), // Neon Teal
        iconColor = const Color(0xFF1E1E1E); // Same as Primary

  MyColors._dark()
      : background = const Color(0xFF0D0D0D), // Absolute Black
        primaryText = const Color(0xFFFFFFFF), // White
        secondaryText = const Color(0xFFA1A1AA), // Muted Gray
        accent = const Color(0xFF00BFA6), // Neon Teal
        iconColor = const Color(0xFFFFFFFF); // White
}
