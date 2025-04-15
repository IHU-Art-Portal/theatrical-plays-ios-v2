import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:intl/intl.dart';

class MovieDatesSection extends StatelessWidget {
  final List<String> dates;

  const MovieDatesSection({super.key, required this.dates});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    if (dates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          "Δεν υπάρχουν διαθέσιμες ημερομηνίες",
          style: TextStyle(color: colors.accent.withOpacity(0.6)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Ημερομηνίες παραστάσεων',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.accent,
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.map((dateStr) {
              final date = DateTime.tryParse(dateStr);
              final formatted = date != null
                  ? DateFormat("dd/MM/yyyy").format(date)
                  : dateStr;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(
                    formatted,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
