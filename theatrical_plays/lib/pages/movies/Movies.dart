import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MovieInfo.dart';
import 'package:theatrical_plays/pages/movies/MovieGrid.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'CompareMovies.dart';

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

  @override
  void initState() {
    super.initState();
    moviesToSearch = List.from(widget.movies);
  }

  List<Movie> _filterMovies() {
    return widget.movies.where((movie) {
      // Φιλτράρισμα ημερομηνίας
      bool dateMatches = widget.selectedDate == null ||
          movie.dates.any((dateStr) {
            final date = DateTime.tryParse(dateStr);
            return date != null &&
                date.year == widget.selectedDate!.year &&
                date.month == widget.selectedDate!.month &&
                date.day == widget.selectedDate!.day;
          });

      // Φιλτράρισμα χώρου
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
            context,
            MaterialPageRoute(builder: (_) => MovieInfo(movie.id)),
          ),
          noItemsFoundBuilder: (_) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Δεν βρέθηκαν αποτελέσματα'),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: OutlinedButton.icon(
        onPressed: () => _showFilterDialog(colors),
        icon: Icon(Icons.calendar_today, color: Colors.red),
        label: Text(
          'Επιλογή Ημερομηνίας',
          style: TextStyle(color: Colors.red),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Φίλτρα Αναζήτησης',
          style: TextStyle(color: Colors.red, fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Φίλτρο Ημερομηνίας
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: tempDate ?? DateTime(2021, 7, 1),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2022),
                  );
                  if (picked != null) {
                    setState(() {
                      tempDate = picked;
                    });
                  }
                },
                icon: Icon(Icons.calendar_today, color: Colors.red),
                label: Text(
                  tempDate == null
                      ? 'Επιλογή Ημερομηνίας'
                      : '${tempDate!.day}/${tempDate!.month}/${tempDate!.year}',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Φίλτρο Χώρου
              Text(
                'Χώρος Διεξαγωγής',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempVenue,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Όλοι οι Χώροι',
                        style: TextStyle(color: Colors.red)),
                  ),
                  ...uniqueVenues.map(
                    (venue) => DropdownMenuItem(
                      value: venue,
                      child: Text(venue, style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    tempVenue = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onFilterChanged(null, null);
              Navigator.pop(context);
            },
            child: Text('Καθαρισμός', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              widget.onFilterChanged(tempDate, tempVenue);
              Navigator.pop(context);
            },
            child: Text('Εφαρμογή', style: TextStyle(color: Colors.red)),
          ),
        ],
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
