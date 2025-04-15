import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class ShowDatesSection extends StatelessWidget {
  final List<String> dateStrings;
  final void Function(DateTime)? onDateSelected;

  ShowDatesSection({
    required this.dateStrings,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    // Μετατροπή σε DateTime
    final validDates = dateStrings
        .map((str) => DateTime.tryParse(str))
        .whereType<DateTime>()
        .toList();

    if (validDates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text("Δεν υπάρχουν διαθέσιμες ημερομηνίες.",
            style: TextStyle(color: colors.accent)),
      );
    }

    // Χρήση της πρώτης ημερομηνίας ως focused day
    final firstDate = validDates.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📅 Ημερομηνίες Παραστάσεων",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: 10),
          TableCalendar(
            focusedDay: firstDate,
            firstDay: DateTime.now().subtract(Duration(days: 365)),
            lastDay: DateTime.now().add(Duration(days: 365)),
            calendarFormat: CalendarFormat.week,
            availableGestures: AvailableGestures.horizontalSwipe,
            daysOfWeekVisible: false,
            headerVisible: false,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              defaultTextStyle: TextStyle(color: colors.accent),
              weekendTextStyle:
                  TextStyle(color: colors.accent.withOpacity(0.8)),
              markersAlignment: Alignment.bottomCenter,
              markerSizeScale: 0.2,
            ),
            selectedDayPredicate: (day) {
              return false;
            },
            enabledDayPredicate: (date) {
              return validDates.any((d) =>
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day);
            },
            onDaySelected: (selected, focused) {
              if (onDateSelected != null) onDateSelected!(selected);
            },
          ),
        ],
      ),
    );
  }
}
