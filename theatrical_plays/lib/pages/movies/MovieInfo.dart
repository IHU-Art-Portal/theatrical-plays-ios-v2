import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/MoviesService.dart';
import 'package:theatrical_plays/using/ExpandableDescription.dart';
import 'package:theatrical_plays/pages/movies/MoviePeopleSection.dart';

class MovieInfo extends StatefulWidget {
  final int movieId;

  const MovieInfo(this.movieId, {super.key});

  @override
  State<MovieInfo> createState() => _MovieInfoState();
}

class _MovieInfoState extends State<MovieInfo> {
  Movie? movie;
  String? selectedVenue; // Επιλεγμένο θέατρο από dropdown

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    final result = await MoviesService.fetchMovieById(widget.movieId);
    setState(() {
      movie = result;
      selectedVenue = result?.datesPerVenue?.keys.first; // default επιλογή
    });
  }

  // Χρήσιμο για να εμφανίσουμε διάρκεια σε format: "1 ώρα και 30 λεπτά"
  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) return 'Διάρκεια: $hours ώρες και $mins λεπτά';
    if (hours > 0) return 'Διάρκεια: $hours ώρες';
    return 'Διάρκεια: $mins λεπτά';
  }

  @override
  Widget build(BuildContext context) {
    if (movie == null) {
      return Scaffold(
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
            // Εικόνα εξωφύλλου
            Stack(
              children: [
                Image.network(
                  movie!.mediaUrl!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: BackButton(color: Colors.white),
                ),
              ],
            ),

            // Τίτλος παράστασης
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                movie!.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Περιεχόμενα
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpandableDescription(description: movie!.description),
                  const SizedBox(height: 16),

                  // Αν υπάρχει διάρκεια, την εμφανίζουμε formatted
                  if (movie!.duration != null &&
                      int.tryParse(movie!.duration!) != null)
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text(
                          formatDuration(int.parse(movie!.duration!)),
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Αν υπάρχουν θέατρα & ημερομηνίες
                  if (movie!.datesPerVenue != null &&
                      movie!.datesPerVenue!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Επίλεξε θέατρο',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              value: selectedVenue,
                              iconStyleData: IconStyleData(
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.white),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight:
                                    200, // scrollable μετά από ~4 επιλογές
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedVenue = newValue;
                                });
                              },
                              items: movie!.datesPerVenue!.keys
                                  .map((venue) => DropdownMenuItem<String>(
                                        value: venue,
                                        child: Text(venue),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Ημερομηνίες για το επιλεγμένο θέατρο
                        if (selectedVenue != null)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: movie!.datesPerVenue![selectedVenue]!
                                .map((dateStr) {
                              final parsedDate = DateTime.tryParse(dateStr);
                              final display = parsedDate != null
                                  ? DateFormat('dd/MM/yyyy').format(parsedDate)
                                  : 'Άκυρη ημερομηνία';
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  display,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Δεν υπάρχουν διαθέσιμες ημερομηνίες για αυτή την παράσταση.',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Κουμπί αγοράς εισιτηρίου (αν υπάρχει link)
                  if (movie!.ticketUrl != null &&
                      movie!.ticketUrl!.trim().isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(movie!.ticketUrl!)),
                      icon: Icon(Icons.local_activity_outlined),
                      label: Text('Αγορά Εισιτηρίου'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Συντελεστές / Παρουσιαστές
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
}
