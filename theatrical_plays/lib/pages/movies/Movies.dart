// Movies.dart
import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MovieInfo.dart';
import 'package:theatrical_plays/pages/movies/MovieGrid.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';

import 'CompareMovies.dart';

class Movies extends StatefulWidget {
  final List<Movie> movies;
  Movies(this.movies);

  @override
  _MoviesState createState() => _MoviesState(movies: movies);
}

class _MoviesState extends State<Movies> {
  List<Movie> movies = [];
  _MoviesState({required this.movies});

  late List<Movie> moviesToSearch;
  List<Movie> selectedMovies = [];
  String? selectedVenue;
  DateTime? selectedDate;
  bool showFilters = false;
  List<String> venues = [];

  @override
  void initState() {
    super.initState();
    moviesToSearch = List.from(movies);
    fetchVenues();
  }

  Future<void> fetchVenues() async {
    try {
      final uri = Uri.parse(
          'http://${Constants().hostName}/api/Venues?page=1&size=100');
      final headers = {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      };
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> results = json['data']['results'];

        setState(() {
          venues = results
              .map((v) => v['title']?.toString() ?? '')
              .where((v) => v.isNotEmpty)
              .toSet()
              .toList();
        });
      } else {
        print("📛 Venue fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception in fetchVenues: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? MyColors.dark
        : MyColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          buildSearch(),
          buildFilterToggle(colors),
          if (showFilters) buildFilters(colors),
          Expanded(child: MovieGrid(movies: movies)),
          if (selectedMovies.isNotEmpty) buildSelectionActions(colors),
        ],
      ),
    );
  }

  Widget buildSearch() {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? MyColors.dark
        : MyColors.light;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        width: screenWidth > 500 ? 450 : screenWidth * 0.95,
        child: TypeAheadField<Movie>(
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
            constraints: BoxConstraints(maxHeight: 220),
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          textFieldConfiguration: TextFieldConfiguration(
            decoration: InputDecoration(
              hintText: 'Αναζήτηση παράστασης',
              prefixIcon: Icon(Icons.search, color: colors.accent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colors.background,
            ),
            style: TextStyle(color: colors.accent),
          ),
          suggestionsCallback: (pattern) => moviesToSearch.where(
              (m) => m.title.toLowerCase().contains(pattern.toLowerCase())),
          itemBuilder: (context, movie) => ListTile(
            title: Text(movie.title, style: TextStyle(color: colors.accent)),
          ),
          onSuggestionSelected: (movie) => Navigator.push(
              context, MaterialPageRoute(builder: (_) => MovieInfo(movie.id))),
          noItemsFoundBuilder: (_) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Δεν βρέθηκαν αποτελέσματα'),
          ),
        ),
      ),
    );
  }

  Widget buildFilterToggle(dynamic colors) {
    return TextButton.icon(
      onPressed: () => setState(() => showFilters = !showFilters),
      icon: Icon(
        showFilters ? Icons.filter_alt_off : Icons.filter_alt,
        color: colors.accent,
      ),
      label: Text(
        showFilters ? 'Απόκρυψη φίλτρων' : 'Εμφάνιση φίλτρων',
        style: TextStyle(color: colors.accent),
      ),
    );
  }

  Widget buildFilters(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          DropdownButtonFormField<String>(
            value: selectedVenue,
            decoration: InputDecoration(
              labelText: 'Χώρος',
              labelStyle: TextStyle(color: colors.accent),
              border: OutlineInputBorder(),
            ),
            items: venues
                .map((v) => DropdownMenuItem<String>(
                      value: v,
                      child: Text(v),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedVenue = value;
                applyFilters();
              });
            },
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(Duration(days: 1)),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
                applyFilters();
              }
            },
            icon: Icon(Icons.calendar_today, color: colors.accent),
            label: Text(
              selectedDate == null
                  ? 'Ημερομηνία'
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: TextStyle(color: colors.accent),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedDate = null;
                selectedVenue = null;
                movies = List.from(moviesToSearch);
              });
            },
            child: Text('Καθαρισμός φίλτρων',
                style: TextStyle(color: colors.accent)),
          ),
        ],
      ),
    );
  }

  Widget buildSelectionActions(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ElevatedButton(
            child: Text('Compare ticket prices (${selectedMovies.length})'),
            onPressed: () {
              if (selectedMovies.length <= 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CompareMovies(selectedMovies)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You can compare up to 4 movies.')),
                );
              }
            },
          ),
          ElevatedButton(
            child: Text('Clear'),
            onPressed: () => setState(() {
              for (var movie in selectedMovies) movie.isSelected = false;
              selectedMovies.clear();
              applyFilters();
            }),
          ),
        ],
      ),
    );
  }

  void applyFilters() {
    if (venues.isEmpty) return; // ensure venues loaded
    setState(() {
      movies = moviesToSearch.where((movie) {
        final matchesVenue =
            selectedVenue == null || movie.venue == selectedVenue;
        final matchesDate = selectedDate == null ||
            (movie.startDate != null &&
                DateTime.tryParse(movie.startDate!)?.day == selectedDate!.day &&
                DateTime.tryParse(movie.startDate!)?.month ==
                    selectedDate!.month &&
                DateTime.tryParse(movie.startDate!)?.year ==
                    selectedDate!.year);
        return matchesVenue && matchesDate;
      }).toList();
    });
  }
}
