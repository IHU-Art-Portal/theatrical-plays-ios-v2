import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/pages/home/HomeScreen.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/Loading.dart';

class LoadingHomeScreen extends StatefulWidget {
  @override
  _LoadingHomeScreenState createState() => _LoadingHomeScreenState();
}

class _LoadingHomeScreenState extends State<LoadingHomeScreen> {
  List<Movie> movies = [];
  List<Actor> actors = [];
  List<Theater> theaters = [];

  Future<void> loadAllData() async {
    actors = await loadHomeActors();
    theaters = await loadHomeTheaters();
    movies = await loadHomeMovies();
  }

  Future<List<Actor>> loadHomeActors() async {
    try {
      Uri uri = Uri.parse("http://${Constants().hostName}/api/people");
      http.Response response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization") ?? ''}"
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Actor> actors = [];
        int counter = 0;

        for (var item in jsonData['data']['results'] ?? []) {
          if (counter >= 6) break;
          if (item['id'] != 1908 &&
              item['fullname'] != null &&
              RegExp(r"^\s*([A-Za-zα-ωΑ-Ω]{1,}([\.,] |[-']| ))+[A-Za-zΑ-Ωα-ω]+\.?\s*$")
                  .hasMatch(item['fullname'])) {
            actors.add(Actor(
              id: item['id'] ?? 0,
              fullName: item['fullname'] ?? 'Unknown Name',
              image: item['images']?.isNotEmpty == true
                  ? item['images'][0]['imageUrl']
                  : 'https://example.com/default-image.jpg',
              isClaimed: item['isClaimed'] ?? false,
            ));
            counter++;
          }
        }
        return actors;
      }
      return [];
    } catch (e) {
      print('Error fetching actors: $e');
      return [];
    }
  }

  Future<List<Movie>> loadHomeMovies() async {
    try {
      Uri uri = Uri.parse("http://${Constants().hostName}/api/productions");
      http.Response response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization") ?? ''}"
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Movie> movies = [];
        int counter = 0;

        for (var item in jsonData['data']['results'] ?? []) {
          if (counter >= 6) break;
          if (item['mediaUrl'] != null && item['mediaUrl'] != "") {
            movies.add(Movie.fromJson(item));
            counter++;
          }
        }
        return movies;
      }
      return [];
    } catch (e) {
      print('Error fetching movies: $e');
      return [];
    }
  }

  Future<List<Theater>> loadHomeTheaters() async {
    try {
      Uri uri = Uri.parse("http://${Constants().hostName}/api/venues");
      http.Response response = await http.get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization") ?? ''}"
      });

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<Theater> theaters = [];
        int counter = 0;

        for (var item in jsonData['data']['results'] ?? []) {
          if (counter >= 6) break;
          if (item['title'] != null && item['address'] != null) {
            theaters.add(Theater(
              id: item['id'] ?? 0,
              title: item['title'] ?? 'Unknown Theater',
              address: item['address'] ?? 'Unknown Address',
            ));
            counter++;
          }
        }
        return theaters;
      }
      return [];
    } catch (e) {
      print('Error fetching theaters: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: loadAllData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return TheaterSeatsLoading();
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          } else {
            return HomeScreen();
          }
        },
      ),
    );
  }
}
