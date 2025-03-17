import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/pages/actors/ActorInfo.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/SearchWidget.dart';

class Actors extends StatefulWidget {
  final List<Actor> actors;
  Actors(this.actors);

  @override
  _ActorsState createState() => _ActorsState(actors: actors);
}

class _ActorsState extends State<Actors> {
  List<Actor> actors;
  String query = '';
  List<Actor> actorsToSearch = [];

  _ActorsState({required this.actors});

  @override
  void initState() {
    actorsToSearch = List.from(actors);
    //Ταξινομηση με αλφαβητικη σειρα
    actors.sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          buildSearch(),
          Expanded(
            child: ListView.builder(
                itemCount: actors.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ActorInfo(actors[index].id)));
                    },
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors
                            .grey[800], // Background αν δεν φορτώσει εικόνα
                        child: ClipOval(
                          child: Image.network(
                            actors[index].image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset("images/avatar.jpg",
                                  fit: BoxFit.cover);
                            },
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      actors[index].fullName,
                      style: TextStyle(color: colors.accent),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Actor name',
        onChanged: searchActors,
      );

  Future<void> searchActors(String query) async {
    final search = actorsToSearch.where((actor) {
      final searchActors = actor.fullName.toLowerCase();
      final searchLower = query.toLowerCase();
      return searchActors.contains(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      if (query.isEmpty) {
        this.actors = actorsToSearch;
      } else {
        this.actors = search;
      }
    });
  }
}
