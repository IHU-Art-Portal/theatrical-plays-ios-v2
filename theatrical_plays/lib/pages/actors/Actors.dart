import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/SearchWidget.dart';
import 'package:theatrical_plays/pages/actors/widgets/ActorGrid.dart';
import 'package:theatrical_plays/pages/actors/widgets/ActorFiltersDialog.dart';

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

  _ActorsState({required this.actorList});

  @override
  void initState() {
    super.initState();
    searchPool = List.from(actorList);
    actorList.sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
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

  Widget buildSearch() => SearchWidget(
        text: searchTxt,
        hintText: 'Αναζήτηση ονόματος',
        onChanged: searchActors,
      );

  Future<void> searchActors(String txt) async {
    final lowerTxt = txt.toLowerCase();
    final filtered = searchPool.where((actor) {
      return actor.fullName.toLowerCase().contains(lowerTxt);
    }).toList();

    setState(() {
      searchTxt = txt;
      actorList = txt.isEmpty ? searchPool : filtered;
    });
  }

  Widget _buildFilterButton(dynamic clr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () => _showFilterDialog(),
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
            setState(() {
              actorList = List.from(searchPool);
            });
            return;
          }

          final List<Actor> filtered = searchPool.where((actor) {
            // Αν έχει ενεργό φίλτρο ηλικίας
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

            // Φίλτρο ύψους
            if (filters.containsKey('minHeight') &&
                filters.containsKey('maxHeight')) {
              final h = _parseHeight(actor.height ?? '');
              if (h == null ||
                  h < filters['minHeight'] ||
                  h > filters['maxHeight']) return false;
            }

            // Φίλτρο βάρους
            if (filters.containsKey('minWeight') &&
                filters.containsKey('maxWeight')) {
              final w = _parseWeight(actor.weight ?? '');
              if (w == null ||
                  w < filters['minWeight'] ||
                  w > filters['maxWeight']) return false;
            }

            // Claim filter
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
