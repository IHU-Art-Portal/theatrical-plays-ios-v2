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

      // Assign default image if null or empty
      if (jsonData['data']['image'] == null ||
          jsonData['data']['image'] == '') {
        jsonData['data']['image'] =
            'http://www.macunepimedium.com/wp-content/uploads/2019/04/male-icon.jpg';
      }

      actor = Actor(jsonData['data']['image'], jsonData['data']['id'],
          jsonData['data']['fullName']);
      return actor;
    } on Exception {
      print('Error fetching actor data');
      return null; // Return null in case of an error
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
          // brightness: Brightness.dark,
          title: Text(
            'Actor Info',
            style: TextStyle(color: MyColors().cyan),
          ),
          backgroundColor: MyColors().black,
        ),
        backgroundColor: MyColors().black,
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
                        actorName: actorData.fullName),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
                      child: Text('Biography',
                          style:
                              TextStyle(color: MyColors().cyan, fontSize: 18)),
                    )),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 15),
                        child: Text(
                          "${actorData.fullName} γεννήθηκε το 1959 στην Ορεστιάδα. " +
                              "Σπούδασε Πολιτικές Επιστήμες στο Πάντειο Πανεπιστήμιο (χωρίς όμως να αποφοιτήσει) και στη Σχολή Κινηματογράφου και Τηλεόρασης του Λυκούργου Σταυράκου. Πριν ασχοληθεί με τη συγγραφή ήθελε να γίνει αθλητικογράφος.",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    Divider(color: MyColors().gray),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
                      child: Text('Related Productions',
                          style:
                              TextStyle(color: MyColors().cyan, fontSize: 18)),
                    )),
                    BodyProfileWidget(actorData.id)
                  ],
                );
              }
            }));
  }
}
