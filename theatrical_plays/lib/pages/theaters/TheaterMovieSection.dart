import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MovieInfo.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class TheaterMovieSection extends StatefulWidget {
  final int theaterId;

  TheaterMovieSection({Key? key, required this.theaterId}) : super(key: key);

  @override
  State<TheaterMovieSection> createState() =>
      _TheaterMovieSectionState(theaterId);
}

class _TheaterMovieSectionState extends State<TheaterMovieSection> {
  final int theaterId;
  List<Movie> relatedMovies = [];

  _TheaterMovieSectionState(this.theaterId);

  Future<List<Movie>?> loadRelatedMovies() async {
    try {
      Uri uri = Uri.parse(
          "http://${Constants().hostName}:8080/api/venues/$theaterId/productions");
      Response data = await get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });
      var jsonData = jsonDecode(data.body);

      for (var oldRelatedMovie in jsonData['data']['content']) {
        if (oldRelatedMovie['mediaURL'] == null ||
            oldRelatedMovie['mediaURL'] == '') {
          oldRelatedMovie['mediaURL'] =
              'https://thumbs.dreamstime.com/z/print-178440812.jpg';
        }
        Movie relatedMovie = Movie(
          id: oldRelatedMovie['id'] ?? 0,
          title: oldRelatedMovie['title'] ?? 'Unknown Title',
          ticketUrl: oldRelatedMovie['url'], // Nullable
          producer: oldRelatedMovie['producer'] ?? 'Unknown Producer',
          mediaUrl: oldRelatedMovie['mediaURL'], // Nullable
          duration: oldRelatedMovie['duration'], // Nullable
          description:
              oldRelatedMovie['description'] ?? 'No description available',
          isSelected: false,
        );
        relatedMovies.add(relatedMovie);
      }
      return relatedMovies;
    } catch (e) {
      print('Error fetching related movies: $e');
      return null; // Return null on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return FutureBuilder<List<Movie>?>(
        future: loadRelatedMovies(),
        builder: (BuildContext context, AsyncSnapshot<List<Movie>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error loading data",
                  style: TextStyle(color: colors.accent, fontSize: 22)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'There are no available movies',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          } else {
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: relatedMovies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieInfo(relatedMovies[index].id),
                      ),
                    );
                  },
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundImage:
                          NetworkImage(relatedMovies[index].mediaUrl ?? ''),
                    ),
                  ),
                  title: Text(
                    relatedMovies[index].title,
                    style: TextStyle(color: colors.accent),
                  ),
                );
              },
            );
          }
        });
  }
}
