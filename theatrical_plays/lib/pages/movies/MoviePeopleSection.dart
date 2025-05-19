import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MoviesService.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class MoviePeopleSection extends StatefulWidget {
  final int movieId;

  const MoviePeopleSection({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MoviePeopleSection> createState() => _MoviePeopleSectionState();
}

class _MoviePeopleSectionState extends State<MoviePeopleSection> {
  List<int> peopleIds = [];
  bool isLoading = true;
  List<Map<String, dynamic>> peopleDetails = [];

  @override
  void initState() {
    super.initState();
    loadPeopleForProduction();
  }

  Future<void> loadPeopleForProduction() async {
    final ids = await MoviesService.getPeopleIdsForProduction(widget.movieId);
    List<Map<String, dynamic>> details = [];

    for (final id in ids) {
      final person = await MoviesService.getPersonById(id);
      print("🔍 Person fetched: $person");

      if (person != null) {
        details.add(person);
      }
    }

    setState(() {
      peopleDetails = details;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (peopleDetails.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Δεν υπάρχουν διαθέσιμοι ηθοποιοί.',
          style: TextStyle(
              color: colors.secondaryText, fontStyle: FontStyle.italic),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: peopleDetails.length,
      itemBuilder: (context, index) {
        final person = peopleDetails[index];
        final fullName = person['fullname'] ?? 'Άγνωστο Όνομα';
        final personId = person['id'];
        final roles = (person['roles'] as List<dynamic>?)?.join(', ') ?? '';

        return GestureDetector(
          onTap: () {
            // Μπορείς εδώ να περάσεις το person σε ProfilePage σου αν έχεις
            print("Clicked on $fullName");
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 48, color: Colors.white70),
                const SizedBox(height: 8),
                Text(
                  fullName,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  roles,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
