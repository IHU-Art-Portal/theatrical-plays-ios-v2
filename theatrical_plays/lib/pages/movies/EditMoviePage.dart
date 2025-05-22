import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/MoviesService.dart';

class EditMoviePage extends StatefulWidget {
  final Movie movie;
  const EditMoviePage({Key? key, required this.movie}) : super(key: key);

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> venues = [];
  int? selectedEventId;
  String? price;
  DateTime? selectedDate;
  int? selectedVenueId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final fetchedEvents =
        await MoviesService.getEventsForProduction(widget.movie.id);
    final fetchedVenues = await MoviesService.getVenues();

    setState(() {
      events = fetchedEvents
          .map((e) => {
                "id": e.id,
                "priceRange": e.priceRange,
                "venueId": e.venueId,
                "dateEvent": e.dateEvent,
              })
          .toList();
      venues = fetchedVenues;
      if (events.isNotEmpty) {
        final e = events.first;
        selectedEventId = e['id'];
        selectedVenueId = e['venueId'];
        selectedDate = DateTime.tryParse(e['dateEvent']);
        price = e['priceRange'];
      }
    });
  }

  Future<void> updateEvent() async {
    if (selectedEventId == null) return;

    await MoviesService.updateEvent(
      eventId: selectedEventId!,
      priceRange: price,
      eventDate: selectedDate?.toIso8601String(),
      venueId: selectedVenueId,
      productionId: widget.movie.id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Το event ενημερώθηκε.')),
    );
  }

  Future<void> addNewVenueEvent() async {
    if (selectedVenueId == null || selectedDate == null) return;

    await MoviesService.createEvent(
      productionId: widget.movie.id,
      venueId: selectedVenueId!,
      eventDate: selectedDate!.toIso8601String(),
      priceRange: price ?? '',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Προστέθηκε νέα παράσταση.')),
    );

    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : 'Επιλογή ημερομηνίας';

    return Scaffold(
      appBar: AppBar(title: Text('Επεξεργασία Παράστασης')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<int>(
              value: selectedEventId,
              items: events
                  .map<DropdownMenuItem<int>>(
                      (Map<String, dynamic> e) => DropdownMenuItem<int>(
                            value: e['id'] as int,
                            child: Text(
                                "Event ID ${e['id']} - ${e['priceRange'] ?? ''}"),
                          ))
                  .toList(),
              onChanged: (val) {
                final e = events.firstWhere((e) => e['id'] == val);
                setState(() {
                  selectedEventId = val;
                  price = e['priceRange'];
                  selectedVenueId = e['venueId'];
                  selectedDate = DateTime.tryParse(e['dateEvent']);
                });
              },
              decoration: InputDecoration(labelText: "Επιλογή Event"),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedVenueId,
              items: venues
                  .map((v) => DropdownMenuItem<int>(
                        value: v['id'] as int,
                        child: Text(v['title'] ?? 'Χωρίς τίτλο'),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedVenueId = val),
              decoration: InputDecoration(labelText: "Χώρος"),
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: price,
              onChanged: (val) => setState(() => price = val),
              decoration: InputDecoration(labelText: "Τιμή Εισιτηρίου"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: Text("Ημερομηνία: $dateStr"),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: updateEvent,
              child: Text("💾 Ενημέρωση υπάρχοντος Event"),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: addNewVenueEvent,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("➕ Προσθήκη νέου χώρου"),
            ),
          ],
        ),
      ),
    );
  }
}
