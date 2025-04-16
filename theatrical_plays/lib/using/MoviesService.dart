import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';

class MoviesService {
  // Φέρνει όλες τις παραστάσεις από το backend (Productions)
  static Future<List<Movie>> fetchMovies() async {
    try {
      final headers = {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}" // Παίρνουμε το token
      };

      // Πρώτα φορτώνουμε τα events για να ξέρουμε ημερομηνίες και venues
      final eventsUri = Uri.parse(
          "http://${Constants().hostName}/api/events?page=1&size=9999");
      final eventsResponse = await http.get(eventsUri, headers: headers);

      Map<int, List<DateTime>> productionDates =
          {}; // Μαζεύουμε ημερομηνίες ανά production
      Map<int, int?> productionVenues = {}; // Μαζεύουμε τα venueIds
      Map<int, Map<int, List<DateTime>>> productionVenueDates =
          {}; // productionId -> venueId -> ημερομηνίες

      if (eventsResponse.statusCode == 200) {
        final eventsJson = jsonDecode(eventsResponse.body);
        final List<dynamic> eventResults = eventsJson['data']['results'];

        for (var event in eventResults) {
          final int? productionId = event['productionId'];
          final String? dateStr = event['dateEvent'];
          final int? venueId = event['venueId'];
          final DateTime? date = DateTime.tryParse(dateStr ?? '');

          if (productionId != null && date != null && venueId != null) {
            productionDates.putIfAbsent(productionId, () => []).add(date);
            productionVenues[productionId] = venueId;

            // Ομαδοποίηση ημερομηνιών ανα venue
            productionVenueDates.putIfAbsent(productionId, () => {});
            productionVenueDates[productionId]!
                .putIfAbsent(venueId, () => [])
                .add(date);
          }
        }
      } else {
        print("Failed to fetch events: ${eventsResponse.statusCode}");
        return [];
      }

      // Μετά φορτώνουμε τους χώρους (venues) για να ξέρουμε ονόματα
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

      // Και στο τέλος φορτώνουμε τις ίδιες τις παραστάσεις
      final productionsUri = Uri.parse(
          "http://${Constants().hostName}/api/productions?page=1&size=1376");
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

        // Αν δεν έχουμε event για την παράσταση, δεν την εμφανίζουμε
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
        // Μικρή λογική για να βρούμε το είδος της παράστασης
        String? inferredType;
        final title = (item['title'] ?? '').toString().toLowerCase();
        if (title.contains("stand")) {
          inferredType = "Stand-up";
        } else if (title.contains("μουσικ") || title.contains("concert")) {
          inferredType = "Μουσική";
        } else if (title.contains("θέατρο") || title.contains("παράσταση")) {
          inferredType = "Θέατρο";
        }

        // Δημιουργία αντικειμένου Movie
        final List<String> dates =
            productionDates[id]!.map((date) => date.toIso8601String()).toList();
        final int? venueId = productionVenues[id];
        final String? venueName = venueId != null ? venueNames[venueId] : null;

        Map<String, List<String>> groupedDates = {};
        if (productionVenueDates.containsKey(id)) {
          productionVenueDates[id]!.forEach((venueId, dateList) {
            final venueTitle = venueNames[venueId];
            if (venueTitle != null) {
              groupedDates[venueTitle] =
                  dateList.map((d) => d.toIso8601String()).toList();
            }
          });
        }

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
          datesPerVenue: groupedDates,
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

  // Φέρνει τον τίτλο για κάθε organizer
  static Future<Map<int, String>> fetchOrganizerNames() async {
    Map<int, String> organizerNames = {};

    try {
      final uri = Uri.parse("http://${Constants().hostName}/api/Organizers");
      final headers = {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}" // Παίρνουμε token
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

  // ✅ Χρήσιμη βοηθητική μέθοδος για να βρούμε μια συγκεκριμένη παράσταση με βάση το ID της
  static Future<Movie?> fetchMovieById(int id) async {
    try {
      final allMovies = await fetchMovies();
      return allMovies.firstWhere(
        (m) => m.id == id,
        orElse: () => null as Movie,
      );
    } catch (e) {
      print("❌ Σφάλμα στο fetchMovieById: $e");
      return null;
    }
  }

  static Future<List<DateTime>> getDatesForProduction(int productionId) async {
    try {
      final headers = {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      };

      final uri = Uri.parse(
          "http://${Constants().hostName}/api/events?page=1&size=9999");
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> events = json['data']['results'];

        // Φιλτράρουμε μόνο τα events της συγκεκριμένης παραγωγής
        final productionEvents = events
            .where((event) => event['productionId'] == productionId)
            .toList();

        // Παίρνουμε τις ημερομηνίες
        final dates = productionEvents
            .map<DateTime>((event) {
              final String? dateStr = event['dateEvent'];
              return DateTime.tryParse(dateStr ?? '')!;
            })
            .where((d) => d != null)
            .cast<DateTime>()
            .toList();

        // Ταξινόμηση για να φαίνονται όμορφα
        dates.sort();
        return dates;
      } else {
        print("❌ Failed to load events: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Σφάλμα στη getDatesForProduction: $e");
      return [];
    }
  }
}
