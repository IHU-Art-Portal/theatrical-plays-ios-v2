import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MovieInfo.dart';
import 'package:theatrical_plays/pages/movies/MovieGrid.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'CompareMovies.dart';
import 'dart:async';
import 'dart:convert';
import 'package:theatrical_plays/using/GreekTransliterator.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/using/Constants.dart';

class Movies extends StatefulWidget {
  final List<Movie> movies;
  final DateTime? selectedDate;
  final String? selectedVenue;
  final Function(DateTime?, String?) onFilterChanged;

  Movies({
    required this.movies,
    required this.selectedDate,
    required this.selectedVenue,
    required this.onFilterChanged,
  });

  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  late List<Movie> moviesToSearch;
  List<Movie> selectedMovies = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    moviesToSearch = List.from(widget.movies);
  }

  List<Movie> _filterMovies() {
    return moviesToSearch.where((movie) {
      bool dateMatches = widget.selectedDate == null ||
          movie.dates.any((dateStr) {
            final date = DateTime.tryParse(dateStr);
            return date != null &&
                date.year == widget.selectedDate!.year &&
                date.month == widget.selectedDate!.month &&
                date.day == widget.selectedDate!.day;
          });

      bool venueMatches =
          widget.selectedVenue == null || movie.venue == widget.selectedVenue;

      return dateMatches && venueMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? MyColors.dark
        : MyColors.light;
    final filteredMovies = _filterMovies();

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildSearchBar(colors),
          _buildFilterButton(colors),
          SizedBox(height: 10),
          Expanded(child: MovieGrid(movies: filteredMovies)),
          if (selectedMovies.isNotEmpty) _buildSelectionActions(colors),
        ],
      ),
    );
  }

  Widget _buildSearchBar(dynamic colors) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        width: screenWidth > 500 ? 450 : screenWidth * 0.95,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Αναζήτηση παράστασης',
            prefixIcon: Icon(Icons.search, color: colors.accent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: colors.background,
          ),
          onChanged: _onSearchChanged,
          style: TextStyle(color: colors.accent),
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        // ✅ Αν ο χρήστης το καθάρισε, επαναφέρουμε τα αρχικά δεδομένα
        setState(() {
          moviesToSearch = List.from(widget.movies);
        });
      } else {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    print('🔍 Αναζήτηση για: $query');

    final transliteratedQuery = GreekTransliterator.transliterate(query);
    final apiQuery = query;

    final url = Uri.parse(
        'http://${Constants().hostName}/api/productions/search?query=$apiQuery');

    try {
      final response = await http.get(url, headers: {
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          moviesToSearch = (data['results'] as List)
              .map((json) => Movie.fromJson(json))
              .toList();
        });
      } else {
        print('❌ Σφάλμα API, fallback σε τοπική αναζήτηση');
        _localSearchFallback(query, transliteratedQuery);
      }
    } catch (e) {
      print('❌ Σφάλμα Δικτύου, fallback σε τοπική αναζήτηση');
      _localSearchFallback(query, transliteratedQuery);
    }
  }

  void _localSearchFallback(String query, String transliteratedQuery) {
    final lowerQuery = query.toLowerCase();
    final filtered = widget.movies.where((m) {
      final titleLower = m.title.toLowerCase();
      final titleTransliterated = GreekTransliterator.transliterate(titleLower);
      return titleLower.contains(lowerQuery) ||
          titleTransliterated.contains(transliteratedQuery);
    }).toList();

    setState(() {
      moviesToSearch = filtered;
    });
  }

  Widget _buildFilterButton(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onTap: () => _showFilterDialog(colors),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.background.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.accent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 18, color: colors.accent),
              SizedBox(width: 6),
              Text(
                'Φίλτρα',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(dynamic colors) {
    DateTime? tempDate = widget.selectedDate;
    String? tempVenue = widget.selectedVenue;
    final uniqueVenues =
        widget.movies.map((m) => m.venue).whereType<String>().toSet();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Φίλτρα',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.accent)),
            SizedBox(height: 16),

            // Ημερομηνία
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: tempDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => tempDate = picked);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.accent.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                  color: colors.background.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: colors.accent, size: 20),
                    SizedBox(width: 12),
                    Text(
                      tempDate == null
                          ? 'Επιλογή ημερομηνίας'
                          : '${tempDate!.day}/${tempDate!.month}/${tempDate!.year}',
                      style: TextStyle(fontSize: 16, color: colors.accent),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Χώρος
            Text('Χώρος Διεξαγωγής',
                style: TextStyle(fontSize: 16, color: colors.accent)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tempVenue,
              isExpanded: true,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              dropdownColor: colors.background,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('Όλοι οι Χώροι'),
                ),
                ...uniqueVenues.map(
                  (venue) => DropdownMenuItem(
                    value: venue,
                    child: Text(venue),
                  ),
                ),
              ],
              onChanged: (value) => tempVenue = value,
            ),
            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onFilterChanged(null, null);
                    Navigator.pop(context);
                  },
                  child: Text('Καθαρισμός',
                      style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    widget.onFilterChanged(tempDate, tempVenue);
                    Navigator.pop(context);
                  },
                  child: Text('Εφαρμογή'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionActions(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ElevatedButton(
            child: Text('Σύγκριση τιμών (${selectedMovies.length})'),
            onPressed: () {
              if (selectedMovies.length <= 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CompareMovies(selectedMovies)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Μπορείς να συγκρίνεις μέχρι 4 παραστάσεις.')),
                );
              }
            },
          ),
          ElevatedButton(
            child: Text('Απαλοιφή Επιλογών'),
            onPressed: () => setState(() {
              for (var movie in selectedMovies) movie.isSelected = false;
              selectedMovies.clear();
            }),
          ),
        ],
      ),
    );
  }
}
