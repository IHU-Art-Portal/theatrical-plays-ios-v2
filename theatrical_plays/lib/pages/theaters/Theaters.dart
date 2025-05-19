import 'dart:async';
import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/pages/theaters/TheaterGrid.dart';
import 'package:theatrical_plays/using/GreekTransliterator.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class Theaters extends StatefulWidget {
  final List<Theater> theaters;

  const Theaters(this.theaters, {Key? key}) : super(key: key);

  @override
  State<Theaters> createState() => _TheatersState();
}

class _TheatersState extends State<Theaters> {
  late List<Theater> theatersToSearch;
  late List<Theater> filteredTheaters;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    theatersToSearch = List.from(widget.theaters);
    filteredTheaters = List.from(widget.theaters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildSearchBar(colors),
          Expanded(child: TheaterGrid(theaters: filteredTheaters)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Αναζήτηση θεάτρου',
          prefixIcon: Icon(Icons.search, color: colors.accent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: colors.background,
        ),
        onChanged: _onSearchChanged,
        style: TextStyle(color: colors.accent),
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value);
    });
  }

  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    final transliteratedQuery = GreekTransliterator.transliterate(lowerQuery);

    setState(() {
      if (query.trim().isEmpty) {
        filteredTheaters = List.from(theatersToSearch);
      } else {
        filteredTheaters = theatersToSearch.where((theater) {
          final titleLower = theater.title.toLowerCase();
          final titleTransliterated =
              GreekTransliterator.transliterate(titleLower);
          return titleLower.contains(lowerQuery) ||
              titleTransliterated.contains(transliteratedQuery);
        }).toList();
      }
    });
  }
}
