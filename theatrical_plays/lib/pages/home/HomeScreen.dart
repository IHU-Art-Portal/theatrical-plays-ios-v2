import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/pages/home/widgets/actor_card.dart';
import 'package:theatrical_plays/pages/home/widgets/theater_card.dart';
import 'package:theatrical_plays/pages/home/widgets/movie_card.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';

import 'dart:convert';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = loadAllData();
  }

  Future<List<dynamic>> loadAllData() async {
    return await Future.wait([
      loadActors(),
      loadMovies(),
      loadTheaters(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<List<dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available"));
          } else {
            List<Actor> actors = snapshot.data![0];
            List<Movie> movies = snapshot.data![1];
            List<Theater> theaters = snapshot.data![2];

            List<Actor> randomActors = getRandomItems(actors, 3);
            List<Movie> randomMovies = getRandomItems(movies, 3);
            List<Theater> randomTheaters = getRandomItems(theaters, 3);

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildCategorySection(
                      "Actors",
                      randomActors,
                      (context, actor) => ActorCard(actor: actor as Actor),
                    ),
                    Divider(),
                    buildCategorySection(
                      "Movies",
                      randomMovies,
                      (context, movie) => MovieCard(movie: movie as Movie),
                    ),
                    Divider(),
                    buildCategorySection(
                      "Theaters",
                      randomTheaters,
                      (context, theater) =>
                          TheaterCard(theater: theater as Theater),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildCategorySection<T>(
    String title,
    List<T> items,
    Widget Function(BuildContext, T) itemBuilder,
  ) {
    final isFewItems = items.length <= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: isFewItems
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: items
                        .map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: itemBuilder(context, item),
                            ))
                        .toList(),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) =>
                        itemBuilder(context, items[index] as T),
                  ),
          ),
        ],
      ),
    );
  }

  List<T> getRandomItems<T>(List<T> list, int count) {
    if (list.length <= count) {
      return List.from(list);
    }

    Random random = Random();
    List<T> shuffledList = List.from(list)..shuffle(random);
    return shuffledList.take(count).toList();
  }

  Future<List<Actor>> loadActors() async {
    try {
      Uri uri = Uri.parse("http://localhost:8080/api/people");
      http.Response response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization") ?? ''}"
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Actor> actors = [];

        for (var item in jsonData['data']['results'] ?? []) {
          actors.add(Actor(
            id: item['id'] ?? 0,
            fullName: item['fullname'] ?? 'Unknown Name',
            image: item['images']?.isNotEmpty == true
                ? item['images'][0]['imageUrl']
                : 'https://example.com/default-image.jpg',
            isClaimed: item['isClaimed'] ?? false,
          ));
        }
        return actors;
      } else {
        throw Exception("Failed to load actors");
      }
    } catch (e) {
      print("Error fetching actors: $e");
      return [];
    }
  }

  Future<List<Movie>> loadMovies() async {
    try {
      Uri uri = Uri.parse("http://localhost:8080/api/productions");
      http.Response response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization") ?? ''}"
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Movie> movies = [];

        for (var item in jsonData['data']['results'] ?? []) {
          movies.add(Movie(
            id: item['id'] ?? 0,
            title: item['title'] ?? 'Unknown Title',
            ticketUrl: item['url'] ?? '',
            producer: item['producer'] ?? 'Unknown Producer',
            mediaUrl: item['mediaUrl'] ?? '',
            duration: item['duration'] ?? '',
            description: item['description'] ?? 'No description available',
          ));
        }
        return movies;
      } else {
        throw Exception("Failed to load movies");
      }
    } catch (e) {
      print("Error fetching movies: $e");
      return [];
    }
  }

  Future<List<Theater>> loadTheaters() async {
    try {
      Uri uri = Uri.parse("http://localhost:8080/api/venues");
      http.Response response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization") ?? ''}"
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Theater> theaters = [];

        for (var item in jsonData['data']['results'] ?? []) {
          theaters.add(Theater(
            id: item['id'] ?? 0,
            title: item['title'] ?? 'Unknown Theater',
            address: item['address'] ?? 'No address available',
          ));
        }
        return theaters;
      } else {
        throw Exception("Failed to load theaters");
      }
    } catch (e) {
      print("Error fetching theaters: $e");
      return [];
    }
  }

  Widget buildActorTile(BuildContext context, Actor actor) => Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(actor.image),
          ),
          SizedBox(height: 8),
          Text(actor.fullName, textAlign: TextAlign.center),
        ],
      );

  Widget buildMovieTile(BuildContext context, Movie movie) => Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(movie.mediaUrl ?? ''),
          ),
          SizedBox(height: 8),
          Text(movie.title, textAlign: TextAlign.center),
        ],
      );

  Widget buildTheaterTile(BuildContext context, Theater theater) => Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/default_theater.png'),
          ),
          SizedBox(height: 8),
          Text(theater.title, textAlign: TextAlign.center),
        ],
      );
}
