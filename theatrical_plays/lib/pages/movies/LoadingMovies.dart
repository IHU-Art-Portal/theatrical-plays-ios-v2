import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/movies/Movies.dart';
import 'package:theatrical_plays/using/MoviesService.dart';
import 'package:theatrical_plays/using/Loading.dart';

class LoadingMovies extends StatefulWidget {
  @override
  _LoadingMoviesState createState() => _LoadingMoviesState();
}

class _LoadingMoviesState extends State<LoadingMovies> {
  DateTime? selectedDate;
  String? selectedVenue;
  List<Movie> allMovies = [];

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    final fetched = await MoviesService.fetchMovies();
    setState(() {
      allMovies = fetched;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: allMovies.isEmpty
          ? TheaterSeatsLoading()
          : Movies(
              movies: allMovies,
              selectedDate: selectedDate,
              selectedVenue: selectedVenue,
              onFilterChanged: (newDate, newVenue) {
                setState(() {
                  selectedDate = newDate;
                  selectedVenue = newVenue;
                });
              },
            ),
    );
  }
}
