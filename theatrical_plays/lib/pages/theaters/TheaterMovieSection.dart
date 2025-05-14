import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MovieInfo.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/pages/theaters/ProductionGrid.dart';
import 'package:theatrical_plays/using/Loading.dart';

class TheaterMovieSection extends StatefulWidget {
  final int theaterId;

  TheaterMovieSection({Key? key, required this.theaterId}) : super(key: key);

  @override
  State<TheaterMovieSection> createState() =>
      _TheaterMovieSectionState(theaterId);
}

class _TheaterMovieSectionState extends State<TheaterMovieSection> {
  final int theaterId;
  List<Movie> relatedMovies = [];

  _TheaterMovieSectionState(this.theaterId);

  Future<List<Map<String, dynamic>>> loadRelatedMovies() async {
    try {
      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/shows?venueId=$theaterId");

      print("🔍 Φόρτωση παραστάσεων για venueId: $theaterId");

      final response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });

      var jsonData = jsonDecode(response.body);
      var shows = jsonData['data']['results'] ?? [];

      Set<int> uniqueProductionIds = {};
      List<Map<String, dynamic>> productions = [];

      for (var item in shows) {
        var productionId = item['production']?['id'];
        if (productionId != null &&
            !uniqueProductionIds.contains(productionId)) {
          uniqueProductionIds.add(productionId);
          var productionDetails = await fetchProductionDetails(productionId);
          if (productionDetails != null) {
            productions.add(productionDetails);
          }
        }
      }

      return productions;
    } catch (e) {
      print('❌ Σφάλμα κατά τη φόρτωση παραστάσεων: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadRelatedMovies(),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: TheaterSeatsLoading());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error loading data",
                style: TextStyle(color: colors.accent, fontSize: 22)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Δεν υπάρχουν διαθέσιμες παραστάσεις',
              style: TextStyle(color: colors.accent, fontSize: 18),
            ),
          );
        } else {
          final productions = snapshot.data!;
          return ProductionGrid(productions: productions);
        }
      },
    );
  }

  Future<Map<String, dynamic>?> fetchProductionDetails(int productionId) async {
    try {
      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/productions/$productionId");

      final response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data'];
        return {
          'id': data['id'],
          'title': data['title'] ?? 'Χωρίς τίτλο',
          'mediaUrl': data['mediaUrl'] ?? '',
          'description': data['description'] ?? '',
        };
      } else {
        print('⚠️ Αποτυχία λήψης λεπτομερειών για παραγωγή $productionId');
        return null;
      }
    } catch (e) {
      print('❌ Σφάλμα στη λήψη παραγωγής $productionId: $e');
      return null;
    }
  }
}
