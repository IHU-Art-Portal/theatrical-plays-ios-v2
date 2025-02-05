import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/pages/actors/Actors.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/Loading.dart';

class LoadingActors extends StatefulWidget {
  @override
  _LoadingActorsState createState() => _LoadingActorsState();
}

class _LoadingActorsState extends State<LoadingActors> {
  List<Actor> actors = [];

  // Load actors data from API
  Future<List<Actor>> loadActors() async {
    try {
      Uri uri = Uri.parse("http://${Constants().hostName}/api/people");
      Response data = await get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });

      if (data.statusCode == 200) {
        var jsonData = jsonDecode(data.body);

        // ✅ Διαβάζουμε τους ηθοποιούς από "data" -> "results"
        List<dynamic> results = jsonData['data']['results'];

        actors.clear(); // Καθαρίζουμε τη λίστα πριν προσθέσουμε νέους ηθοποιούς

        for (var oldActor in results) {
          // ✅ Επιλογή πρώτης εικόνας από τη λίστα "images"
          String imageUrl = oldActor['images'].isNotEmpty
              ? oldActor['images'][0]['imageUrl']
              : 'https://via.placeholder.com/150'; // Default εικόνα αν δεν υπάρχει

          Actor actor = Actor(imageUrl, oldActor['id'], oldActor['fullname']);

          actors.add(actor);
        }
        return actors;
      } else {
        print("API status code error: ${data.statusCode}");
        return [];
      }
    } on Exception catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Actor>>(
        // Call and show the actors
        future: loadActors(),
        builder: (BuildContext context, AsyncSnapshot<List<Actor>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading(); // Show loading while data is fetched
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No actors available"));
          } else {
            return Actors(snapshot.data!); // Pass the loaded actors
          }
        },
      ),
    );
  }
}
