import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/SearchWidget.dart';
import 'package:theatrical_plays/using/ActorsService.dart';
import 'package:theatrical_plays/pages/actors/ActorProfilePgae.dart';

// Actors page - shows a list of actors with search functionality
class Actors extends StatefulWidget {
  final List<Actor> actorList; // Renamed to sound more casual
  Actors(this.actorList);

  @override
  _ActorsState createState() => _ActorsState(actorList: actorList);
}

class _ActorsState extends State<Actors> {
  List<Actor> actorList; // Keeping it simple
  String searchTxt = ''; // More casual name
  List<Actor> searchPool = []; // Sounds more "human"

  _ActorsState({required this.actorList});

  @override
  void initState() {
    super.initState();
    searchPool = List.from(actorList);
    // Sorting alphabetically - gotta keep things tidy!
    actorList.sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkMode = theme.brightness == Brightness.dark; // Shortened name
    final clr =
        darkMode ? MyColors.dark : MyColors.light; // Casual abbreviation

    return Scaffold(
      backgroundColor: clr.background,
      body: Column(
        children: [
          buildSearch(),
          Expanded(
            child: ListView.builder(
              itemCount: actorList.length,
              itemBuilder: (ctx, idx) {
                // Shortened context and index
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (ctx) =>
                            ActorProfilePage(actor: actorList[idx]),
                      ),
                    );
                  },
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.grey[800], // Fallback color
                      child: ClipOval(
                        child: Image.network(
                          actorList[idx].image,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) {
                            return Image.asset(
                              "images/avatar.jpg",
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    actorList[idx].fullName,
                    style: TextStyle(color: clr.accent),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // Search bar widget
  Widget buildSearch() => SearchWidget(
        text: searchTxt,
        hintText: 'Actor name',
        onChanged: searchActors,
      );

  // Search logic - filters actors based on input
  Future<void> searchActors(String txt) async {
    final filtered = searchPool.where((actor) {
      final name = actor.fullName.toLowerCase();
      final input = txt.toLowerCase();
      return name.contains(input);
    }).toList();

    setState(() {
      searchTxt = txt; // Update the search text
      if (txt.isEmpty) {
        actorList = searchPool; // Reset to full list
      } else {
        actorList = filtered; // Show filtered results
      }
    });
  }
}
