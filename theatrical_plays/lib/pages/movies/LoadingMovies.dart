import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/Movies.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/Loading.dart';

class LoadingMovies extends StatefulWidget {
  @override
  _LoadingMoviesState createState() => _LoadingMoviesState();
}

class _LoadingMoviesState extends State<LoadingMovies> {
  List<Movie> movies = [];
  Map<int, String> productionVenueMap = {};

  Future<void> fetchAllEventVenues() async {
    try {
      final uri = Uri.parse(
          "http://${Constants().hostName}/api/events?page=1&size=1000");
      final headers = {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      };

      final response = await get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['data']['results'];
        for (var item in results) {
          final productionId = item['production']?['id'];
          final venueTitle = item['venueResponseDto']?['title'];
          if (productionId != null && venueTitle != null) {
            productionVenueMap[productionId] = venueTitle;
          }
        }
      }
    } catch (e) {
      print("❌ Error fetching event venues: $e");
    }
  }

  Future<List<Movie>> loadMovies() async {
    try {
      await fetchAllEventVenues();

      Uri uri = Uri.parse("http://${Constants().hostName}/api/productions");
      final headers = {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      };

      Response data = await get(uri, headers: headers);

      if (data.statusCode == 200) {
        var jsonData = jsonDecode(data.body);
        List<dynamic> results = jsonData['data']['results'];

        for (var oldMovie in results) {
          String rawUrl = oldMovie['mediaUrl'] ?? '';
          String mediaUrl =
              (rawUrl.trim().isEmpty || rawUrl.contains('no-image'))
                  ? 'https://i.imgur.com/TV0Qzjz.png'
                  : rawUrl;

          int id = oldMovie['id'];
          String? venue = productionVenueMap[id];

          // Optional type inference from title
          String? inferredType;
          final title = (oldMovie['title'] ?? '').toString().toLowerCase();
          if (title.contains("stand")) {
            inferredType = "Stand-up";
          } else if (title.contains("μουσικ") || title.contains("concert")) {
            inferredType = "Μουσική";
          } else if (title.contains("θέατρο") || title.contains("παράσταση")) {
            inferredType = "Θέατρο";
          }

          Movie movie = Movie(
            id: id,
            title: oldMovie['title'] ?? 'Χωρίς τίτλο',
            ticketUrl: oldMovie['ticketUrl'],
            producer: oldMovie['producer'] ?? 'Άγνωστος παραγωγός',
            mediaUrl: mediaUrl,
            duration: oldMovie['duration'],
            description: oldMovie['description'] ?? 'Δεν υπάρχει περιγραφή',
            isSelected: false,
            venue: venue,
            type: inferredType,
            startDate: oldMovie['startDate'],
          );

          movies.add(movie);
        }

        print("✅ Loaded movies: ${movies.length}");
        return movies;
      } else {
        print("API error: ${data.statusCode}");
        return [];
      }
    } catch (e) {
      print('Σφάλμα κατά τη φόρτωση δεδομένων: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Movie>>(
        future: loadMovies(),
        builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Σφάλμα κατά τη φόρτωση των παραστάσεων"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Δεν υπάρχουν διαθέσιμες παραστάσεις"));
          } else {
            return Movies(snapshot.data!);
          }
        },
      ),
    );
  }
}
