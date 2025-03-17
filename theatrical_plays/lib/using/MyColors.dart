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
      : background = Color(0xFFFAF3E0), // Light beige (θεατρική κομψότητα)
        primaryText = Color(0xFF2C2C2C), // Charcoal black (ευανάγνωστο)
        secondaryText = Color(0xFF6B6B6B), // Soft gray (υποστηρικτικό κείμενο)
        accent = Color(0xFFD7263D), // Bold μπορντό (θεατρικό στοιχείο)
        iconColor = Color(0xFF444444); // Σκούρο γκρι (minimal icons)

  MyColors._dark()
      : background = Color(0xFF121212), // Dark charcoal (κομψό μαύρο)
        primaryText = Color(0xFFEFEFEF), // Απαλό λευκό (για readability)
        secondaryText = Color(0xFFB3B3B3), // Γκρι για δευτερεύον κείμενο
        accent = Color(0xFFFFC107), // Χρυσό (σαν φώτα σκηνής)
        iconColor = Color(0xFFE0E0E0); // Ανοιχτό γκρι (καθαρά εικονίδια)
}
