import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MoviePeopleSection.dart';
import 'package:theatrical_plays/using/ExpandableDescription.dart';
import 'package:theatrical_plays/using/MoviesService.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:theatrical_plays/pages/movies/EditMoviePage.dart';

class MovieInfo extends StatefulWidget {
  final int movieId;
  const MovieInfo(this.movieId, {super.key});

  @override
  State<MovieInfo> createState() => _MovieInfoState();
}

class _MovieInfoState extends State<MovieInfo> {
  Movie? movie;
  String? selectedVenue;
  Map<String, dynamic>? userProfile;
  bool isProductionClaimedLive = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadMovie();
    _checkProductionClaim();
  }

  Future<void> _checkProductionClaim() async {
    final claimed = await MoviesService.isProductionClaimedLive(widget.movieId);
    setState(() {
      isProductionClaimedLive = claimed;
    });
  }

  Future<void> _loadUser() async {
    final profile = await UserService.fetchUserProfile();
    if (profile != null) {
      print("✅ User Profile Loaded: $profile");
      setState(() {
        userProfile = profile;
      });
    } else {
      print("❌ User Profile Not Loaded");
    }
  }

  bool userOwnsProduction() {
    if (movie == null || userProfile == null) return false;

    final claimedEvents = userProfile!['claimedEvents'] ?? [];
    print(
        "🔍 Checking ownership for production ${movie!.id} in claimedEvents: $claimedEvents");

    final owns =
        claimedEvents.any((event) => event['productionId'] == movie!.id);
    print("🔍 Ownership Check Result: $owns");
    return owns;
  }

  Future<void> _loadMovie() async {
    final result = await MoviesService.fetchMovieById(widget.movieId);
    setState(() {
      movie = result;
      selectedVenue = result?.datesPerVenue?.keys.first;
    });
  }

  Future<void> claimProduction() async {
    if (movie?.datesPerVenue?.isEmpty ?? true) {
      showAwesomeNotification("Δεν υπάρχουν διαθέσιμα events.",
          title: "⚠️ Σφάλμα");
      return;
    }

    final productionId = movie!.id;
    print("🚀 Ξεκινάω claim για productionId: $productionId");

    final eventId =
        await MoviesService.getFirstEventIdForProduction(productionId);

    if (eventId == null) {
      print("❌ Δεν βρέθηκε event για productionId: $productionId");
      showAwesomeNotification("Δεν βρέθηκε διαθέσιμο event",
          title: "⚠️ Σφάλμα");
      return;
    }

    print("👉 Βρέθηκε eventId: $eventId - Προχωράω σε claim...");

    final success = await UserService.claimEvent(eventId);

    print("📩 Αποτέλεσμα claim: ${success ? "Επιτυχία" : "Αποτυχία"}");

    if (success) {
      await _loadUser(); // Φορτώνουμε ξανά το userProfile με το νέο claimed event
      await _loadMovie(); // Φορτώνουμε ξανά το production με το isClaimed ενημερωμένο
      await _checkProductionClaim(); // Κάνουμε live check για σιγουριά
      showAwesomeNotification("Το αίτημα εγκρίθηκε αυτόματα",
          title: "✅ Επιτυχία");
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
                if (userOwnsProduction())
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.edit,
                          color: Colors.greenAccent, size: 30),
                      tooltip: "Επεξεργασία παράστασης",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditMoviePage(movie: movie!)),
                        );
                      },
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
                  const SizedBox(height: 12),
                  if (userOwnsProduction())
                    Container()
                  else if (isProductionClaimedLive)
                    ElevatedButton(
                      onPressed: null,
                      child: const Text('ΗΔΗ ΔΙΕΚΔΙΚΗΜΕΝΟ',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                    )
                  else
                    ElevatedButton(
                      onPressed: claimProduction,
                      child: const Text('ΑΙΤΗΜΑ ΔΙΕΚΔΙΚΗΣΗΣ',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                    )
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
                    buildVenueSection(),
                  const SizedBox(height: 24),
                  if (movie!.ticketUrl != null &&
                      movie!.ticketUrl!.trim().isNotEmpty)
                    ElevatedButton(
                      onPressed: () => launchUrl(Uri.parse(movie!.ticketUrl!)),
                      child: const Text('ΑΓΟΡΑ ΕΙΣΙΤΗΡΙΟΥ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget buildVenueSection() {
    return Column(
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
              onChanged: (val) => setState(() => selectedVenue = val),
              items: movie!.datesPerVenue!.keys
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
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
