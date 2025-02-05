import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/RelatedActor.dart';
import 'package:theatrical_plays/pages/actors/ActorInfo.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class MoviePeopleSection extends StatefulWidget {
  final int movieId;
  MoviePeopleSection(this.movieId);

  @override
  State<MoviePeopleSection> createState() => _MoviePeopleSectionState(movieId);
}

class _MoviePeopleSectionState extends State<MoviePeopleSection> {
  final int movieId; // Marked as final and non-nullable
  _MoviePeopleSectionState(this.movieId);

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
        var jsonData = jsonDecode(data.body);
        return jsonData['data']
            .map<RelatedActor>((actor) => RelatedActor.fromJson(actor))
            .toList();
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print('Error fetching related actors: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RelatedActor>>(
      future: loadRelatedActors(),
      builder:
          (BuildContext context, AsyncSnapshot<List<RelatedActor>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child:
                CircularProgressIndicator(), // Show loading indicator while fetching data
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading actors",
              style: TextStyle(color: MyColors().cyan, fontSize: 22),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            child: Center(
              child: Text(
                'There are no available actors',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
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
                      builder: (context) => ActorInfo(actor.id),
                    ),
                  );
                },
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage(actor.image),
                  ),
                ),
                title: Text(
                  "${actor.fullName} - ${actor.role}",
                  style: TextStyle(color: MyColors().cyan),
                ),
              );
            },
          );
        }
      },
    );
  }
}
