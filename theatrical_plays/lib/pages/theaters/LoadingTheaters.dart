import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/Loading.dart';
import 'Theaters.dart';

class LoadingTheaters extends StatefulWidget {
  @override
  _LoadingTheatersState createState() => _LoadingTheatersState();
}

class _LoadingTheatersState extends State<LoadingTheaters> {
  List<Theater> theaters = [];

  Future<List<Theater>?> loadTheaters() async {
    Uri uri = Uri.parse("http://${Constants().hostName}/api/venues");
    try {
      Response data = await get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });

      var jsonData = jsonDecode(data.body);
      List<dynamic> results = jsonData['data']['results'];

      List<Theater> loadedTheaters = results.map((venue) {
        return Theater(
          id: venue['id'] ?? 0,
          title: venue['title'] ?? 'Άγνωστο Όνομα',
          address: venue['address'] ?? 'Άγνωστη Διεύθυνση',
          isSelected: false,
        );
      }).toList();

      return loadedTheaters;
    } catch (e) {
      print('❌ Σφάλμα κατά τη φόρτωση των χώρων: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Theater>?>(
        future: loadTheaters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return TheaterSeatsLoading();
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Σφάλμα φόρτωσης δεδομένων"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Δεν υπάρχουν διαθέσιμοι χώροι"));
          } else {
            return Theaters(snapshot.data!);
          }
        },
      ),
    );
  }
}
