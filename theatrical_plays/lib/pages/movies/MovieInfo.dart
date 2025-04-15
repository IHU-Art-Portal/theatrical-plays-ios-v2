import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    final result = await MoviesService.fetchMovieById(widget.movieId);
    setState(() => movie = result);
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
            // 🔝 Cover image
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

            // 🎬 Movie Title
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

            // 📄 Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExpandableDescription(description: movie!.description),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.white54),
                      const SizedBox(width: 6),
                      Text(
                        movie!.duration ?? 'Άγνωστη διάρκεια',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 📅 Dates Section
                  Text(
                    'Ημερομηνίες παραστάσεων',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie!.dates.isNotEmpty
                        ? movie!.dates.map((dateStr) {
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
                          }).toList()
                        : [
                            Text(
                              'Δεν υπάρχουν διαθέσιμες ημερομηνίες',
                              style: TextStyle(color: Colors.white54),
                            )
                          ],
                  ),
                  const SizedBox(height: 24),

                  // 🎟️ Ticket Button
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

            // 👥 Cast / Crew
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
