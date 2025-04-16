import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/RelatedActor.dart';
import 'package:theatrical_plays/pages/actors/ActorProfilePgae.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class MoviePeopleSection extends StatefulWidget {
  final int movieId;

  const MoviePeopleSection({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MoviePeopleSection> createState() => _MoviePeopleSectionState();
}

class _MoviePeopleSectionState extends State<MoviePeopleSection> {
  late final int movieId;

  @override
  void initState() {
    super.initState();
    movieId = widget.movieId;
    print("📥 Fetching actors for movieId: ${widget.movieId}");
  }

  List<RelatedActor> relatedActors = [];

  Future<List<RelatedActor>> loadRelatedActors() async {
    try {
      Uri uri = Uri.parse(
          "http://${Constants().hostName}/api/productions/$movieId/people");
      Response data = await get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });

      if (data.statusCode == 200) {
        print("👀 Actors response: ${data.body}");

        var jsonData = jsonDecode(data.body);
        if (jsonData['data'] is List) {
          return (jsonData['data'] as List)
              .map<RelatedActor>((actor) => RelatedActor.fromJson(actor))
              .toList();
        } else {
          print("❌ data['data'] is not a list: ${jsonData['data']}");
          return [];
        }
      } else {
        print("❌ Response code: ${data.statusCode}");
        print("❌ Response body: ${data.body}");
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print('Error fetching related actors: $e');

      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return FutureBuilder<List<RelatedActor>>(
      future: loadRelatedActors(),
      builder:
          (BuildContext context, AsyncSnapshot<List<RelatedActor>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Πρόβλημα φόρτωσης ηθοποιών",
              style: TextStyle(color: colors.accent, fontSize: 22),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Δεν υπάρχουν διαθέσιμοι ηθοποιοί',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          );
        } else {
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var actor = snapshot.data![index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ActorProfilePage(actor: actor.toActor()),
                    ),
                  );
                },
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(actor.image),
                ),
                title: Text(
                  "${actor.fullName} - ${actor.role}",
                  style: TextStyle(color: colors.accent),
                ),
              );
            },
          );
        }
      },
    );
  }
}
