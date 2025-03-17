import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/pages/actors/BodyProfileWidget.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/Loading.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/pages/actors/ProfileWidget.dart';

class ActorInfo extends StatefulWidget {
  final int actorId;
  ActorInfo(this.actorId);

  @override
  _ActorInfoState createState() => _ActorInfoState(actorId: actorId);
}

class _ActorInfoState extends State<ActorInfo> {
  final int actorId;
  Actor? actor;

  _ActorInfoState({required this.actorId});

  // method for loading the actor with the id
  Future<Actor?> loadActor() async {
    try {
      Uri uri = Uri.parse("http://${Constants().hostName}/api/people/$actorId");
      Response data = await get(uri, headers: {
        "Accept": "application/json",
        "authorization":
            "${await AuthorizationStore.getStoreValue("authorization")}"
      });

      var jsonData = jsonDecode(data.body);

      if (jsonData['data'] == null) {
        print("No data found for actor ID: $actorId");
        return null;
      }

      // Ελέγχουμε αν υπάρχει λίστα εικόνων
      List<dynamic>? imagesList = jsonData['data']['images'];
      String imageUrl = (imagesList != null && imagesList.isNotEmpty)
          ? imagesList[0]['imageUrl']
          : 'https://www.macunepimedium.com/wp-content/uploads/2019/04/male-icon.jpg';

      actor = Actor(
        id: jsonData['data']['id'] ?? 0,
        fullName: jsonData['data']['fullname'] ?? 'Unknown Name',
        image: imageUrl,
        birthdate: jsonData['data']['birthdate'],
        height: jsonData['data']['height'],
        weight: jsonData['data']['weight'],
        eyeColor: jsonData['data']['eyeColor'],
        hairColor: jsonData['data']['hairColor'],
        bio: jsonData['data']['bio'],
        images: (imagesList != null)
            ? List<String>.from(imagesList.map((img) => img['imageUrl']))
            : [],
      );

      return actor;
    } catch (e) {
      print('Error fetching actor data: $e');
      return null; // Αν υπάρξει σφάλμα, επιστρέφουμε null
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
            icon: Icon(Icons.arrow_back,
                color: colors.accent), // Εικονίδιο "πίσω"
            onPressed: () {
              Navigator.pop(context); // Πηγαίνει πίσω στην προηγούμενη σελίδα
            },
          ),
          // brightness: Brightness.dark,
          title: Text(
            'Actor Info',
            style: TextStyle(color: colors.accent),
          ),
          backgroundColor: colors.background,
        ),
        backgroundColor: colors.background,
        body: FutureBuilder<Actor?>(
            future: loadActor(),
            builder: (BuildContext context, AsyncSnapshot<Actor?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading(); // Show loading while fetching data
              } else if (snapshot.hasError) {
                return Center(child: Text("Error loading data"));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text("No actor data found"));
              } else {
                Actor actorData = snapshot.data!;

                return ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    ProfileWidget(
                      imagePath: actorData.image,
                      actorName: actorData.fullName,
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${actorData.fullName}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Ημερομηνία Γέννησης: ${actorData.birthdate ?? 'Άγνωστη'}",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Ύψος: ${actorData.height ?? 'Άγνωστο'}",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Βάρος: ${actorData.weight ?? 'Άγνωστο'}",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Χρώμα Ματιών: ${actorData.eyeColor ?? 'Άγνωστο'}",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Χρώμα Μαλλιών: ${actorData.hairColor ?? 'Άγνωστο'}",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Βιογραφία: ${actorData.bio ?? 'Δεν υπάρχει διαθέσιμη βιογραφία.'}",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: colors.secondaryText),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
                        child: Text(
                          'Related Productions',
                          style: TextStyle(color: colors.accent, fontSize: 18),
                        ),
                      ),
                    ),
                    BodyProfileWidget(actorData.id)
                  ],
                );
              }
            }));
  }
}
