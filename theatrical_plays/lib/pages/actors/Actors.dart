import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/SearchWidget.dart';
import 'package:theatrical_plays/pages/actors/widgets/ActorGrid.dart';
import 'package:theatrical_plays/pages/actors/widgets/ActorFiltersDialog.dart';
import 'package:theatrical_plays/using/GreekTransliterator.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/using/globals.dart';

class Actors extends StatefulWidget {
  final List<Actor> actorList;

  Actors(this.actorList);

  @override
  _ActorsState createState() => _ActorsState(actorList: actorList);
}

class _ActorsState extends State<Actors> {
  List<Actor> actorList;
  List<Actor> searchPool = [];
  String searchTxt = '';
  Timer? _debounce;

  _ActorsState({required this.actorList});

  @override
  void initState() {
    super.initState();
    searchPool = List.from(actorList);
    actorList.sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clr =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: clr.background,
      body: Column(
        children: [
          buildSearch(),
          _buildFilterButton(clr),
          Expanded(child: ActorGrid(actors: actorList)),
        ],
      ),
    );
  }

  // Συνδεδεμένο με το Debounced API Search
  Widget buildSearch() => SearchWidget(
        text: searchTxt,
        hintText: 'Αναζήτηση ονόματος',
        onChanged: onSearchChanged,
      );

  // Debounced Search Handler
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      performSearch(query);
    });
  }

  // Κάνει API call ή fallback σε τοπική αναζήτηση
  Future<void> performSearch(String query) async {
    print('🔍 Αναζήτηση για: $query');

    final transliteratedQuery = GreekTransliterator.transliterate(query);
    final apiQuery = query;

    final url = Uri.parse(
        'http://${Constants().hostName}/api/actors/search?query=$apiQuery');

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $globalAccessToken",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          actorList = data['results'];
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

  // Τοπικό φιλτράρισμα με transliteration
  void _localSearchFallback(String query, String transliteratedQuery) {
    final lowerQuery = query.toLowerCase();
    final filtered = searchPool.where((actor) {
      final actorName = actor.fullName.toLowerCase();
      final actorNameTransliterated =
          GreekTransliterator.transliterate(actorName);
      return actorName.contains(lowerQuery) ||
          actorNameTransliterated.contains(transliteratedQuery);
    }).toList();

    setState(() {
      searchTxt = query;
      actorList = query.isEmpty ? searchPool : filtered;
    });
  }

  // Filter Button and Dialog
  Widget _buildFilterButton(dynamic clr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: _showFilterDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: clr.accent.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 18, color: clr.accent),
              const SizedBox(width: 6),
              Text("Φίλτρα", style: TextStyle(color: clr.accent)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ActorFiltersDialog(
        onApply: (filters) {
          if (filters.isEmpty) {
            setState(() => actorList = List.from(searchPool));
            return;
          }

          final filtered = searchPool.where((actor) {
            if (filters.containsKey('minAge') &&
                filters.containsKey('maxAge')) {
              if (actor.birthdate == null || actor.birthdate!.isEmpty)
                return false;
              try {
                final birth = DateFormat("MM/dd/yyyy HH:mm:ss")
                    .parse(actor.birthdate!, true);
                final age = _calculateAge(birth);
                if (age < filters['minAge'] || age > filters['maxAge'])
                  return false;
              } catch (_) {
                return false;
              }
            }

            if (filters.containsKey('minHeight') &&
                filters.containsKey('maxHeight')) {
              final h = _parseHeight(actor.height ?? '');
              if (h == null ||
                  h < filters['minHeight'] ||
                  h > filters['maxHeight']) return false;
            }

            if (filters.containsKey('minWeight') &&
                filters.containsKey('maxWeight')) {
              final w = _parseWeight(actor.weight ?? '');
              if (w == null ||
                  w < filters['minWeight'] ||
                  w > filters['maxWeight']) return false;
            }

            if (filters['claimStatus'] == 'claimed' && !actor.isClaimed)
              return false;
            if (filters['claimStatus'] == 'available' && actor.isClaimed)
              return false;

            return true;
          }).toList();

          setState(() {
            actorList = filtered;
          });
        },
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double? _parseHeight(String raw) {
    try {
      raw = raw.toLowerCase().replaceAll(' ', '');
      if (raw.contains('cm')) return double.parse(raw.replaceAll('cm', ''));
      if (raw.contains('m')) return double.parse(raw.replaceAll('m', '')) * 100;
      return double.parse(raw);
    } catch (_) {
      return null;
    }
  }

  double? _parseWeight(String raw) {
    try {
      raw = raw.toLowerCase().replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(raw);
    } catch (_) {
      return null;
    }
  }
}
