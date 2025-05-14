import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/pages/theaters/TheaterMovieSection.dart';
import 'package:theatrical_plays/pages/theaters/TheaterProfile.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/Loading.dart';
import 'package:theatrical_plays/using/VenueService.dart';
import 'package:theatrical_plays/pages/theaters/EditVenuePage.dart';
import 'package:theatrical_plays/using/UserService.dart';

class TheaterInfo extends StatefulWidget {
  final int theaterId;

  const TheaterInfo({Key? key, required this.theaterId}) : super(key: key);

  @override
  State<TheaterInfo> createState() => _TheaterInfoState();
}

class _TheaterInfoState extends State<TheaterInfo> {
  Theater? theater;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await UserService.fetchUserProfile();
    final loadedTheater = await loadTheater();
    setState(() {
      userProfile = profile;
      theater = loadedTheater;
    });
  }

  Future<Theater?> loadTheater() async {
    try {
      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/venues/${widget.theaterId}");
      Response data = await get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });

      var jsonData = jsonDecode(data.body);

      return Theater(
        id: jsonData['data']['id'] ?? 0,
        title: jsonData['data']['title'] ?? 'Unknown Title',
        address: jsonData['data']['address'] ?? 'Unknown Address',
        isSelected: false,
      );
    } catch (e) {
      print('Error fetching theater data: $e');
      return null;
    }
  }

  bool userOwnsVenue() {
    if (userProfile == null || theater == null) return false;
    final claimedVenues = userProfile!['claimedVenues'] ?? [];
    return claimedVenues.any((venue) => venue['venueId'] == theater!.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Theater Info', style: TextStyle(color: colors.accent)),
        backgroundColor: colors.background,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: colors.background,
      body: FutureBuilder<Theater?>(
        future: loadTheater(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const TheaterSeatsLoading();
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error loading data",
                    style: TextStyle(color: colors.accent)));
          } else if (!snapshot.hasData) {
            return Center(
                child: Text("No data available",
                    style: TextStyle(color: colors.accent)));
          } else {
            final theater = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Theater Info Card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TheaterProfile(theater: theater),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Claim Section
                    userOwnsVenue()
                        ? ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditVenuePage(theater: theater!)),
                              );
                            },
                            child: const Text('Επεξεργασία Χώρου'),
                          )
                        : theater!.isClaimed
                            ? const Text(
                                'Αυτός ο χώρος είναι ήδη κατοχυρωμένος',
                                style: TextStyle(color: Colors.green),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  final success = await VenueService.claimVenue(
                                      theater!.id);
                                  if (success) {
                                    await _loadData(); // ΞΑΝΑΦΟΡΤΩΝΕΙ ΠΡΟΦΙΛ & THEATER
                                  }
                                },
                                child: const Text('Διεκδίκηση Χώρου'),
                              ),

                    // Section Divider with Label
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.accent)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Related Movies",
                            style: TextStyle(
                                color: colors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(child: Divider(color: colors.accent)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TheaterMovieSection(theaterId: theater.id),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
