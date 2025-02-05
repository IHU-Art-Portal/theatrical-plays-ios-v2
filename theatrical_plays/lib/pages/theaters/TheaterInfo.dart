import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/pages/theaters/TheaterMovieSection.dart';
import 'package:theatrical_plays/pages/theaters/TheaterProfile.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/Loading.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class TheaterInfo extends StatefulWidget {
  final int theaterId;

  TheaterInfo({Key? key, required this.theaterId}) : super(key: key);

  @override
  State<TheaterInfo> createState() => _TheaterInfoState(theaterId: theaterId);
}

class _TheaterInfoState extends State<TheaterInfo> {
  final int theaterId;
  Theater? theater; // Marking theater as nullable

  _TheaterInfoState({required this.theaterId});

  Future<Theater?> loadTheater() async {
    try {
      Uri uri =
          Uri.parse("http://${Constants().hostName}/api/venues/$theaterId");
      Response data = await get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });

      var jsonData = jsonDecode(data.body);

      // return Theater(
      //   jsonData['data']['id'] ?? 0,
      //   jsonData['data']['title'] ?? 'Unknown Title',
      //   jsonData['data']['address'] ?? 'Unknown Address',
      //   false,
      // );
      return Theater(
        id: jsonData['data']['id'] ?? 0,
        title: jsonData['data']['title'] ?? 'Unknown Title',
        address: jsonData['data']['address'] ?? 'Unknown Address',
        isSelected: false, // Explicitly setting isSelected to false
      );
    } catch (e) {
      print('Error fetching theater data: $e');
      return null; // Return null on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: MyColors().cyan), // Εικονίδιο "πίσω"
          onPressed: () {
            Navigator.pop(context); // Πηγαίνει πίσω στην προηγούμενη σελίδα
          },
        ),
        title: Text(
          'Theater Info',
          style: TextStyle(color: MyColors().cyan),
        ),
        backgroundColor: MyColors().black,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: MyColors().black,
      body: FutureBuilder<Theater?>(
        future: loadTheater(),
        builder: (BuildContext context, AsyncSnapshot<Theater?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading(); // Show a loading indicator while waiting for data
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading data",
                style: TextStyle(color: MyColors().cyan),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text(
                "No data available",
                style: TextStyle(color: MyColors().cyan),
              ),
            );
          } else {
            final theater =
                snapshot.data!; // Safely access theater since hasData is true
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                TheaterProfile(theater: theater),
                Divider(color: MyColors().gray),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
                    child: Text(
                      'Related Movies',
                      style: TextStyle(color: MyColors().cyan, fontSize: 20),
                    ),
                  ),
                ),
                TheaterMovieSection(theaterId: theaterId),
              ],
            );
          }
        },
      ),
    );
  }
}
