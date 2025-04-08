import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';

class MoviesService {
  static Future<List<Movie>> fetchMovies() async {
    try {
      final headers = {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      };

      // Φόρτωση όλων των events
      final eventsUri = Uri.parse(
          "http://${Constants().hostName}/api/events?page=1&size=9999");
      final eventsResponse = await http.get(eventsUri, headers: headers);

      Map<int, List<DateTime>> productionDates = {};
      Map<int, int?> productionVenues = {};

      if (eventsResponse.statusCode == 200) {
        final eventsJson = jsonDecode(eventsResponse.body);
        final List<dynamic> eventResults = eventsJson['data']['results'];

        for (var event in eventResults) {
          final int? productionId = event['productionId'];
          final String? dateStr = event['dateEvent'];
          final int? venueId = event['venueId'];
          final DateTime? date = DateTime.tryParse(dateStr ?? '');

          if (productionId != null && date != null) {
            productionDates.putIfAbsent(productionId, () => []).add(date);
            if (venueId != null) {
              productionVenues[productionId] = venueId;
            }
          }
        }
      } else {
        print("Failed to fetch events: ${eventsResponse.statusCode}");
        return [];
      }

      // Φόρτωση των venues
      final venuesUri = Uri.parse(
          "http://${Constants().hostName}/api/venues?page=1&size=9999");
      final venuesResponse = await http.get(venuesUri, headers: headers);
      Map<int, String> venueNames = {};

      if (venuesResponse.statusCode == 200) {
        final venuesJson = jsonDecode(venuesResponse.body);
        final List<dynamic> venueResults = venuesJson['data']['results'];
        for (var venue in venueResults) {
          final int id = venue['id'];
          final String? title = venue['title'];
          if (title != null) {
            venueNames[id] = title;
          }
        }
      } else {
        print("Failed to fetch venues: ${venuesResponse.statusCode}");
      }

      // Φόρτωση των productions
      final productionsUri = Uri.parse(
          "http://${Constants().hostName}/api/productions?page=1&size=1000");
      final productionsResponse =
          await http.get(productionsUri, headers: headers);

      if (productionsResponse.statusCode != 200) {
        print("Failed to fetch productions: ${productionsResponse.statusCode}");
        return [];
      }

      final productionsJson = jsonDecode(productionsResponse.body);
      final List<dynamic> results = productionsJson['data']['results'];

      List<Movie> movies = [];

      for (var item in results) {
        final int id = item['id'];

        if (!productionDates.containsKey(id)) {
          print("Skipping production $id: No associated events found");
          continue;
        }

        final int? organizerId = item['organizerId'];
        final String rawUrl = item['mediaUrl'] ?? '';
        final String mediaUrl =
            (rawUrl.trim().isEmpty || rawUrl.contains('no-image'))
                ? 'https://i.imgur.com/TV0Qzjz.png'
                : rawUrl;

        String? inferredType;
        final title = (item['title'] ?? '').toString().toLowerCase();
        if (title.contains("stand")) {
          inferredType = "Stand-up";
        } else if (title.contains("μουσικ") || title.contains("concert")) {
          inferredType = "Μουσική";
        } else if (title.contains("θέατρο") || title.contains("παράσταση")) {
          inferredType = "Θέατρο";
        }

        final List<String> dates =
            productionDates[id]!.map((date) => date.toIso8601String()).toList();
        final int? venueId = productionVenues[id];
        final String? venueName = venueId != null ? venueNames[venueId] : null;

        Movie movie = Movie(
          id: id,
          title: item['title'] ?? 'Χωρίς τίτλο',
          ticketUrl: item['ticketUrl'],
          producer: item['producer'] ?? 'Άγνωστος παραγωγός',
          mediaUrl: mediaUrl,
          duration: item['duration'],
          description: item['description'] ?? 'Δεν υπάρχει περιγραφή',
          isSelected: false,
          venue: venueName,
          organizerId: organizerId,
          type: inferredType,
          dates: dates,
        );

        movies.add(movie);
      }

      print("Successfully loaded ${movies.length} productions.");
      return movies;
    } catch (e) {
      print("Error fetching movies: $e");
      return [];
    }
  }

  static Future<Map<int, String>> fetchOrganizerNames() async {
    Map<int, String> organizerNames = {};

    try {
      final uri = Uri.parse("http://${Constants().hostName}/api/Organizers");
      final headers = {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      };

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['data']['results'];

        for (var item in results) {
          final id = item['id'];
          final title = item['name'];
          if (id != null && title != null) {
            organizerNames[id] = title;
          }
        }
      }
    } catch (e) {
      print("Error fetching organizers: $e");
    }

    return organizerNames;
  }
}
