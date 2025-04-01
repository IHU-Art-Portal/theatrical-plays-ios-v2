import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MovieInfo.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/SearchWidget.dart';

import 'CompareMovies.dart';

class Movies extends StatefulWidget {
  final List<Movie> movies; // Marked as final and non-nullable
  Movies(this.movies);

  @override
  _MoviesState createState() => _MoviesState(movies: movies);
}

class _MoviesState extends State<Movies> {
  late final List<Movie> movies; // Marked as final and non-nullable
  _MoviesState({required this.movies});

  late List<Movie>
      moviesToSearch; // Declared as late since it’s initialized in initState
  String query = '';
  List<Movie> selectedMovies = [];

  @override
  void initState() {
    moviesToSearch = List.from(movies); // Initializing moviesToSearch
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        child: Column(
          children: [
            buildSearch(),
            Expanded(
              child: ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => MovieInfo(movies[index].id),
                        ),
                      );
                    },
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          movies[index].mediaUrl ??
                              'https://via.placeholder.com/150', // Handle nullable mediaUrl
                        ),
                      ),
                    ),
                    title: Text(
                      movies[index].title,
                      style: TextStyle(color: colors.accent),
                    ),
                    subtitle: Text(
                      "Duration: ${movies[index].duration ?? 'N/A'}", // Handle nullable duration
                      style: TextStyle(color: colors.primaryText),
                    ),
                    trailing: movies[index].isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: colors.accent,
                          )
                        : Icon(
                            Icons.check_circle_outline,
                            color: colors.secondaryText,
                          ),
                    onLongPress: () {
                      setState(() {
                        movies[index].isSelected = !movies[index].isSelected;
                        if (movies[index].isSelected) {
                          selectedMovies.add(movies[index]);
                        } else {
                          selectedMovies.removeWhere(
                              (element) => element.id == movies[index].id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            if (selectedMovies.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            // backgroundColor: MyColors().gray, // Set the background color of the button
                            ),
                        child: Text(
                          "Compare ticket prices (${selectedMovies.length})",
                          style: TextStyle(color: colors.accent, fontSize: 18),
                        ),
                        onPressed: () {
                          selectedMovies.length < 5
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CompareMovies(selectedMovies)),
                                )
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "You can't compare more than 4 movies"),
                                  ),
                                );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            // backgroundColor: MyColors().gray, // Set the background color of the button
                            ),
                        child: Text(
                          "Clear",
                          style: TextStyle(color: colors.accent, fontSize: 18),
                        ),
                        onPressed: () {
                          setState(() {
                            List<Movie> removeList = List.from(selectedMovies);
                            for (var removeItem in removeList) {
                              for (var movie in movies) {
                                if (movie.id == removeItem.id) {
                                  movie.isSelected = false;
                                }
                              }
                            }
                            selectedMovies.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Movie name',
        onChanged: searchMovies,
      );

  Future<void> searchMovies(String query) async {
    final search = moviesToSearch.where((movie) {
      final searchMovies = movie.title.toLowerCase();
      final searchLower = query.toLowerCase();
      return searchMovies.contains(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      this.movies = query.isEmpty ? moviesToSearch : search;
    });
  }
}
