import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/MovieProfile.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/Loading.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'MoviePeopleSection.dart';

class MovieInfo extends StatefulWidget {
  final int movieId;
  MovieInfo(this.movieId);

  @override
  State<MovieInfo> createState() => _MovieInfoState(movieId: movieId);
}

class _MovieInfoState extends State<MovieInfo> {
  final int movieId;
  Movie? movie;

  _MovieInfoState({required this.movieId});

  Future<Movie?> loadMovie() async {
    try {
      Uri uri =
          Uri.parse("http://${Constants().hostName}/api/productions/$movieId");
      http.Response response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });
      var jsonData = jsonDecode(response.body);
      if (jsonData['data'] == null) {
        throw Exception("No data found for movie ID: $movieId");
      }

      movie = Movie.fromJson(jsonData['data']);
      return movie;
    } catch (e) {
      print('Error loading movie: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Movie Info', style: TextStyle(color: colors.accent)),
        backgroundColor: colors.background,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: colors.background,
      body: FutureBuilder<Movie?>(
        future: loadMovie(),
        builder: (BuildContext context, AsyncSnapshot<Movie?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error loading movie",
                    style: TextStyle(color: colors.accent)));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
                child: Text("No movie data available",
                    style: TextStyle(color: colors.accent)));
          } else {
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                MovieProfile(movie: snapshot.data!),
                Divider(color: colors.secondaryText),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
                    child: Text('Related Actors',
                        style: TextStyle(color: colors.accent, fontSize: 20)),
                  ),
                ),
                MoviePeopleSection(snapshot.data!.id),
              ],
            );
          }
        },
      ),
    );
  }
}
