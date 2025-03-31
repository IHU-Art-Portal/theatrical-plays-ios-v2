import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class BiographySection extends StatefulWidget {
  final String? bio;

  const BiographySection({Key? key, required this.bio}) : super(key: key);

  @override
  State<BiographySection> createState() => _BiographySectionState();
}

class _BiographySectionState extends State<BiographySection> {
  bool showFull = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    final bioText = widget.bio?.trim();

    if (bioText == null || bioText.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Text(
          'Δεν υπάρχει διαθέσιμη βιογραφία.',
          style: TextStyle(color: colors.secondaryText, fontSize: 14),
        ),
      );
    }

    final isLong = bioText.length > 300;
    final displayText =
        isLong && !showFull ? bioText.substring(0, 300) + '...' : bioText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Βιογραφία',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.accent,
            ),
          ),
          SizedBox(height: 10),
          Text(
            displayText,
            style:
                TextStyle(color: colors.primaryText, fontSize: 14, height: 1.5),
          ),
          if (isLong)
            TextButton(
              onPressed: () {
                setState(() {
                  showFull = !showFull;
                });
              },
              child: Text(
                showFull ? 'Λιγότερα' : 'Περισσότερα',
                style: TextStyle(color: colors.accent),
              ),
            )
        ],
      ),
    );
  }
}
