import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/models/RelatedActor.dart';
import 'package:theatrical_plays/models/EventDto.dart';

class MoviesService {
  // Φέρνει όλες τις παραστάσεις από το backend (Productions)
  static Future<List<Movie>> fetchMovies() async {
    try {
      final headers = {
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
      };

      // Φέρνουμε όλα τα events για να πάρουμε ημερομηνίες, χώρους και τιμές
      final eventsUri = Uri.parse(
          "http://${Constants().hostName}/api/events?page=1&size=9999");
      final eventsResponse = await http.get(eventsUri, headers: headers);

      Map<int, List<DateTime>> productionDates = {};
      Map<int, int?> productionVenues = {};
      Map<int, Map<int, List<DateTime>>> productionVenueDates = {};
      Map<int, String> priceRanges = {};
      Map<int, bool> productionClaimedStatus =
          {}; // 👉 Track claimed per production

      if (eventsResponse.statusCode == 200) {
        final eventsJson = jsonDecode(eventsResponse.body);
        final List<dynamic> eventResults = eventsJson['data']['results'];
        Map<int, bool> productionClaimedStatus =
            {}; // Κρατάει ποια productions έχουν claimed event

        for (var event in eventResults) {
          final int? productionId = event['productionId'];
          final bool isEventClaimed = event['isClaimed'] == true;
          if (isEventClaimed && productionId != null) {
            productionClaimedStatus[productionId] = true;
          }
          final String? dateStr = event['dateEvent'];
          final int? venueId = event['venueId'];
          final String? price = event['priceRange'];
          final DateTime? date = DateTime.tryParse(dateStr ?? '');

          if (productionId != null && date != null && venueId != null) {
            productionDates.putIfAbsent(productionId, () => []).add(date);
            productionVenues[productionId] = venueId;

            if (!priceRanges.containsKey(productionId) && price != null) {
              priceRanges[productionId] = price;
            }

            productionVenueDates.putIfAbsent(productionId, () => {});
            productionVenueDates[productionId]!
                .putIfAbsent(venueId, () => [])
                .add(date);

            final bool isEventClaimed = event['claimed'] == true;
            if (isEventClaimed) {
              productionClaimedStatus[productionId] = true;
            }
          }
        }
      } else {
        print("Failed to fetch events: ${eventsResponse.statusCode}");
        return [];
      }

      // Φέρνουμε τα venues για να έχουμε τα ονόματά τους
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

      // Τώρα φέρνουμε τις ίδιες τις παραστάσεις
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

        if (!productionDates.containsKey(id)) {
          // print("Skipping production $id: No associated events found");
          continue;
        }

        final int? organizerId = item['organizerId'];
        final String rawUrl = item['mediaUrl'] ?? '';
        final String mediaUrl =
            (rawUrl.trim().isEmpty || rawUrl.contains('no-image'))
                ? 'https://i.imgur.com/TV0Qzjz.png'
                : rawUrl;

        // Εικασία για το είδος (π.χ. stand-up, μουσική, θέατρο)
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

        final Movie movie = Movie(
          id: id,
          title: item['title'] ?? 'Χωρίς τίτλο',
          ticketUrl: item['ticketUrl'] ??
              (item['url']?.contains('viva.gr') == true ||
                      item['url']?.contains('ticketservices.gr') == true
                  ? item['url']
                  : null),
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
          priceRange: priceRanges[id],
          isClaimed: productionClaimedStatus[id] ?? false,
        );
        print(
            'Production ${item['title']} - isClaimed: ${productionClaimedStatus[id] ?? false}');

        movies.add(movie);
      }

      print("✅ Φορτώθηκαν ${movies.length} παραστάσεις.");
      return movies;
    } catch (e) {
      print("❌ Σφάλμα στο fetchMovies: $e");
      return [];
    }
  }

  static Future<bool> isProductionClaimedLive(int productionId) async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final uri =
        Uri.parse("http://${Constants().hostName}/api/events?page=1&size=9999");
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> events = json['data']['results'];

      final productionEvents =
          events.where((e) => e['productionId'] == productionId).toList();
      print(
          "🔍 Found ${productionEvents.length} events for production $productionId");

      for (var event in productionEvents) {
        print("🔍 Event ${event['id']} isClaimed: ${event['isClaimed']}");
        if (event['isClaimed'] == true) {
          return true;
        }
      }
    }
    return false;
  }

  // Φέρνει τον τίτλο για κάθε organizer
  static Future<Map<int, String>> fetchOrganizerNames() async {
    Map<int, String> organizerNames = {};

    try {
      final uri = Uri.parse("http://${Constants().hostName}/api/Organizers");
      final headers = {
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
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
        "Authorization":
            "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
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

  static Future<List<RelatedActor>> fetchActorsForProduction(
      int productionId) async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final uri =
        Uri.parse("http://${Constants().hostName}/api/Productions/update");

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> results = jsonData['data'];
      return results
          .map((actorJson) => RelatedActor.fromJson(actorJson))
          .toList();
    } else {
      print(
          "❌ Failed to fetch actors for production $productionId: ${response.statusCode}");
      return [];
    }
  }

  static Future<bool> updateProduction({
    required int productionId,
    required String title,
    required String description,
    required String ticketUrl,
    String? producer,
    String? mediaUrl,
    String? duration,
  }) async {
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final body = jsonEncode({
      "id": productionId,
      "title": title,
      "description": description,
      "url": ticketUrl,
      "producer": producer,
      "mediaUrl": mediaUrl,
      "duration": duration,
    });

    final uri =
        Uri.parse("http://${Constants().hostName}/api/Productions/update");

    final response = await http.put(uri, headers: headers, body: body);

    print("📤 Update Production Request: $body");
    print("📩 Response: ${response.statusCode} ${response.body}");

    return response.statusCode == 200;
  }

  static Future<bool> updateEvent({
    required int eventId,
    String? priceRange,
    String? eventDate,
    int? productionId,
    int? venueId,
  }) async {
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final body = jsonEncode({
      "eventId": eventId,
      "priceRange": priceRange,
      "eventDate": eventDate,
      "productionId": productionId,
      "venueId": venueId,
      "systemId": 1 // Προσαρμόστε αναλόγως αν έχετε πολλαπλά συστήματα
    });

    final uri = Uri.parse("http://${Constants().hostName}/api/events/update");

    final response = await http.put(uri, headers: headers, body: body);

    print("📤 Update Event Request: $body");
    print("📩 Response: ${response.statusCode} ${response.body}");

    return response.statusCode == 200;
  }

  static Future<List<EventDto>> getEventsForProduction(int productionId) async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final uri = Uri.parse(
        "http://${Constants().hostName}/api/events/production/$productionId");

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'];
      final results = data != null ? data['results'] as List<dynamic>? : null;

      if (results == null || results.isEmpty) {
        return [];
      }

      return results.map((e) => EventDto.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  static Future<List<int>> getPeopleIdsForProduction(int productionId) async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final uri = Uri.parse("http://${Constants().hostName}/api/Contributions");
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body)['data']['results'] as List<dynamic>;

      final filteredPeopleIds = data
          .where((e) => e['productionId'] == productionId)
          .map<int>((e) => e['peopleId'] as int)
          .toSet()
          .toList();

      return filteredPeopleIds;
    } else {
      print("❌ Failed to fetch contributions: ${response.statusCode}");
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getPersonById(int peopleId) async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final uri =
        Uri.parse("http://${Constants().hostName}/api/People/$peopleId");

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      print("❌ Failed to fetch person $peopleId: ${response.statusCode}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchOrganizerById(
      int organizerId) async {
    try {
      final uri = Uri.parse(
          "http://${Constants().hostName}/api/Organizers?page=1&size=9999");
      final headers = {
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
      };
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final organizers = json['data']['results'];
        final found = organizers.firstWhere((org) => org['id'] == organizerId,
            orElse: () => null);
        return found;
      }
    } catch (e) {
      print("❌ Σφάλμα στην ανάκτηση διοργανωτή: $e");
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getRawContributions() async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final uri = Uri.parse("http://${Constants().hostName}/api/Contributions");
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['data']['results']);
    } else {
      print("❌ Failed to fetch raw contributions");
      return [];
    }
  }

  static Future<Map<int, String>> fetchRolesDictionary() async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final uri =
        Uri.parse("http://${Constants().hostName}/api/Roles?page=1&size=9999");
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final results =
          jsonDecode(response.body)['data']['results'] as List<dynamic>;
      return {
        for (var role in results) role['id']: role['role1'] ?? 'Άγνωστος ρόλος'
      };
    } else {
      print("❌ Failed to fetch roles: ${response.statusCode}");
      return {};
    }
  }

  static Future<Map<int, String>> getAllRoles() async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}"
    };

    final uri = Uri.parse("http://${Constants().hostName}/api/Roles");
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data =
          jsonDecode(response.body)['data']['results'] as List<dynamic>;
      return {
        for (var item in data)
          if (item['id'] != null && item['role'] != null)
            item['id']: item['role']
      };
    } else {
      print("❌ Αποτυχία στη φόρτωση ρόλων: ${response.statusCode}");
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getVenues() async {
    final headers = {
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}",
    };

    final uri =
        Uri.parse("http://${Constants().hostName}/api/Venues?page=1&size=100");
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData['data']['results']);
    } else {
      print("Failed to fetch venues: ${response.statusCode}");
      return [];
    }
  }

  static Future<bool> createEvent({
    required int productionId,
    required int venueId,
    required String eventDate,
    required String priceRange,
  }) async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization":
          "Bearer ${await AuthorizationStore.getStoreValue("authorization")}",
    };

    final body = jsonEncode({
      "productionId": productionId,
      "venueId": venueId,
      "dateEvent": eventDate,
      "priceRange": priceRange,
      "systemId": 14, // βάλε το δικό σου ID συστήματος αν διαφέρει
    });

    final uri = Uri.parse("http://${Constants().hostName}/api/events");
    final response = await http.post(uri, headers: headers, body: body);

    print("📨 createEvent: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
