import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'dart:convert';
import 'dart:math';
import 'package:theatrical_plays/using/Constants.dart';

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
    return Scaffold(
      backgroundColor: MyColors().black,
      appBar: AppBar(
        backgroundColor: MyColors().black,
        elevation: 0,
        title: Text("Home", style: TextStyle(color: MyColors().cyan)),
      ),
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

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCategorySection("Actors", randomActors, buildActorTile),
                Divider(color: MyColors().gray),
                buildCategorySection("Movies", randomMovies, buildMovieTile),
                Divider(color: MyColors().gray),
                buildCategorySection(
                    "Theaters", randomTheaters, buildTheaterTile),
              ],
            );
          }
        },
      ),
    );
  }

  List<T> getRandomItems<T>(List<T> list, int count) {
    if (list.length <= count) {
      return List.from(list); // Αν έχει λιγότερα από count, επιστρέφουμε όλα
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

        if (jsonData['data'] == null || jsonData['data']['results'] == null) {
          print("No actors found in API response");
          return [];
        }

        List<Actor> actors = [];

        for (var item in jsonData['data']['results']) {
          actors.add(Actor(
            id: item['id'] ?? 0,
            fullName: item['fullname'] ?? 'Unknown Name',
            image: (item['images'] != null && item['images'].isNotEmpty)
                ? item['images'][0]['imageUrl']
                : 'https://example.com/default-image.jpg',
          ));
        }

        print("Actors loaded: ${actors.length}");
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

        for (var item in jsonData['data']['results']) {
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

        if (jsonData['data'] == null || jsonData['data']['results'] == null) {
          print("No theaters found in API response");
          return [];
        }

        List<Theater> theaters = [];

        for (var item in jsonData['data']['results']) {
          theaters.add(Theater(
            id: item['id'] ?? 0,
            title: item['title'] ?? 'Unknown Theater',
            address: item['address'] ?? 'No address available',
          ));
        }

        print("Theaters loaded: ${theaters.length}");
        return theaters;
      } else {
        throw Exception("Failed to load theaters");
      }
    } catch (e) {
      print("Error fetching theaters: $e");
      return [];
    }
  }

  Widget buildActorTile(BuildContext context, Actor actor) => Container(
        width: 100, // ✅ Σταθερό πλάτος
        child: Column(
          children: [
            CircleAvatar(
              radius: 40, // ✅ Σταθερό μέγεθος
              backgroundImage: actor.image.isNotEmpty
                  ? NetworkImage(actor.image)
                  : AssetImage('assets/default_avatar.png')
                      as ImageProvider, // ✅ Default εικόνα
            ),
            SizedBox(height: 8),
            Text(
              actor.fullName,
              textAlign: TextAlign.center,
              style: TextStyle(color: MyColors().cyan, fontSize: 14),
            ),
          ],
        ),
      );

  Widget buildMovieTile(BuildContext context, Movie movie) => Container(
        width: 100, // ✅ Σταθερό πλάτος
        child: Column(
          children: [
            CircleAvatar(
              radius: 40, // ✅ Σταθερό μέγεθος
              backgroundImage:
                  (movie.mediaUrl != null && movie.mediaUrl!.isNotEmpty)
                      ? NetworkImage(movie.mediaUrl!)
                      : AssetImage('assets/default_movie.png')
                          as ImageProvider, // ✅ Default εικόνα
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 80, // ✅ Περιορισμός του πλάτους του τίτλου
              child: Text(
                movie.title,
                maxLines: 1, // ✅ Μία μόνο γραμμή
                overflow: TextOverflow
                    .ellipsis, // ✅ Αν είναι πολύ μεγάλο, προσθέτει "..."
                textAlign: TextAlign.center,
                style: TextStyle(color: MyColors().cyan, fontSize: 12),
              ),
            ),
          ],
        ),
      );

  Widget buildTheaterTile(BuildContext context, Theater theater) => Container(
        width: 100, // ✅ Σταθερό πλάτος
        child: Column(
          children: [
            CircleAvatar(
              radius: 40, // ✅ Σταθερό μέγεθος
              backgroundImage:
                  AssetImage('assets/default_theater.png'), // ✅ Default εικόνα
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 80, // ✅ Περιορισμός του πλάτους του τίτλου
              child: Text(
                theater.title,
                maxLines: 1, // ✅ Μία μόνο γραμμή
                overflow: TextOverflow
                    .ellipsis, // ✅ Αν είναι πολύ μεγάλο, προσθέτει "..."
                textAlign: TextAlign.center,
                style: TextStyle(color: MyColors().cyan, fontSize: 12),
              ),
            ),
          ],
        ),
      );

  Widget buildCategorySection<T>(String title, List<T> items,
      Widget Function(BuildContext, T) itemBuilder) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
                color: MyColors().cyan,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items
              .map((item) => Expanded(child: itemBuilder(context, item)))
              .toList(),
        ),
      ],
    );
  }
}
