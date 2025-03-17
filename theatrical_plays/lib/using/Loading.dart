import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? MyColors.dark.background
          : MyColors.light.background, // ✅ Δυναμική αλλαγή χρώματος
      body: Center(
        child: SpinKitWave(
          color: isDarkMode
              ? MyColors.dark.accent
              : MyColors
                  .light.accent, // ✅ Αλλάζει το κύριο χρώμα σύμφωνα με το θέμα
          size: 40.0,
        ),
      ),
    );
  }
}
