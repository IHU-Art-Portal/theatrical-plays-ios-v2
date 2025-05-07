import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MoviePeopleSection.dart';
import 'package:theatrical_plays/using/ExpandableDescription.dart';
import 'package:theatrical_plays/using/MoviesService.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class MovieInfo extends StatefulWidget {
  final int movieId;
  const MovieInfo(this.movieId, {super.key});

  @override
  State<MovieInfo> createState() => _MovieInfoState();
}

class _MovieInfoState extends State<MovieInfo> {
  Movie? movie;
  String? selectedVenue;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    final result = await MoviesService.fetchMovieById(widget.movieId);
    setState(() {
      movie = result;
      selectedVenue = result?.datesPerVenue?.keys.first;
    });
  }

  Future<void> claimProduction() async {
    if (movie?.datesPerVenue?.isEmpty ?? true) return;

    // Πάρε το πρώτο event ID που μπορείς (θα το φέρουμε πιο σωστά μετά)
    final productionId = movie!.id;
    final eventId =
        await MoviesService.getFirstEventIdForProduction(productionId);

    if (eventId == null) {
      showAwesomeNotification("Δεν βρέθηκε διαθέσιμο event",
          title: "⚠️ Σφάλμα");
      return;
    }

    final success = await UserService.claimEvent(eventId);

    if (success) {
      showAwesomeNotification("Το αίτημα στάλθηκε", title: "✅ Επιτυχία");
    } else {
      showAwesomeNotification("Αποτυχία αιτήματος", title: "❌ Αποτυχία");
    }
  }

  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) return '$hours ώρες και $mins λεπτά';
    if (hours > 0) return '$hours ώρες';
    return '$mins λεπτά';
  }

  @override
  Widget build(BuildContext context) {
    if (movie == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  movie!.mediaUrl ?? '',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                const Positioned(
                  top: 40,
                  left: 16,
                  child: BackButton(color: Colors.white),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: GestureDetector(
                    onTap: claimProduction,
                    child: Tooltip(
                      message: "Κάνε αίτημα διεκδίκησης",
                      child: Icon(Icons.verified_outlined,
                          color: Colors.amber, size: 30),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie!.title,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  if (movie!.priceRange != null &&
                      movie!.priceRange!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        movie!.priceRange!,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpandableDescription(description: movie!.description),
                  const SizedBox(height: 16),
                  if (movie!.duration != null &&
                      int.tryParse(movie!.duration!) != null)
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text(
                          formatDuration(int.parse(movie!.duration!)),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  if (movie!.datesPerVenue != null &&
                      movie!.datesPerVenue!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Επίλεξε θέατρο',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              value: selectedVenue,
                              onChanged: (val) =>
                                  setState(() => selectedVenue = val),
                              items: movie!.datesPerVenue!.keys
                                  .map((v) => DropdownMenuItem(
                                      value: v, child: Text(v)))
                                  .toList(),
                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (selectedVenue != null)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: movie!.datesPerVenue![selectedVenue]!
                                .map((d) => _dateChip(d))
                                .toList(),
                          ),
                      ],
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Δεν υπάρχουν διαθέσιμες ημερομηνίες.',
                          style: TextStyle(color: Colors.white60)),
                    ),
                  const SizedBox(height: 24),
                  if (movie!.ticketUrl != null &&
                      movie!.ticketUrl!.trim().isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(movie!.ticketUrl!)),
                      icon: const Icon(Icons.local_activity_outlined),
                      label: const Text('Αγορά Εισιτηρίου'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MoviePeopleSection(movieId: movie!.id),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _dateChip(String dateStr) {
    final parsed = DateTime.tryParse(dateStr);
    final text = parsed != null
        ? DateFormat('dd/MM/yyyy').format(parsed)
        : 'Άγνωστη ημερομηνία';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  void showAwesomeNotification(String body,
      {String title = '🔔 Ειδοποίηση',
      NotificationLayout layout = NotificationLayout.Default}) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: layout,
      ),
    );
  }
}
