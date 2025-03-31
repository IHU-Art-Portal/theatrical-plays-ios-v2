import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class ActorDetailsSection extends StatelessWidget {
  final String? birthdate;
  final String? height;
  final String? weight;
  final String? eyeColor;
  final String? hairColor;

  const ActorDetailsSection({
    Key? key,
    this.birthdate,
    this.height,
    this.weight,
    this.eyeColor,
    this.hairColor,
  }) : super(key: key);

  Widget buildDetail(String label, String? value, Color textColor) {
    return Row(
      children: [
        Text(
          "$label:",
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 8),
        Text(
          value ?? 'Άγνωστο',
          style: TextStyle(color: textColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Χαρακτηριστικά',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.accent,
            ),
          ),
          SizedBox(height: 12),
          buildDetail('Ημερομηνία Γέννησης', birthdate, colors.primaryText),
          SizedBox(height: 8),
          buildDetail('Ύψος', height, colors.primaryText),
          SizedBox(height: 8),
          buildDetail('Βάρος', weight, colors.primaryText),
          SizedBox(height: 8),
          buildDetail('Χρώμα Ματιών', eyeColor, colors.primaryText),
          SizedBox(height: 8),
          buildDetail('Χρώμα Μαλλιών', hairColor, colors.primaryText),
        ],
      ),
    );
  }
}
