import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/pages/Home.dart';
import 'package:theatrical_plays/pages/actors/ActorInfo.dart';
import 'package:theatrical_plays/pages/movies/MovieInfo.dart';
import 'package:theatrical_plays/pages/theaters/TheaterInfo.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class HomeScreen extends StatefulWidget {
  final List<Movie> homeMovies;
  final List<Actor> homeActors;
  final List<Theater> homeTheaters;

  HomeScreen({
    required this.homeMovies,
    required this.homeActors,
    required this.homeTheaters,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState(
      homeMovies: homeMovies,
      homeActors: homeActors,
      homeTheaters: homeTheaters);
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Movie> homeMovies;
  final List<Actor> homeActors;
  final List<Theater> homeTheaters;

  _HomeScreenState({
    required this.homeMovies,
    required this.homeActors,
    required this.homeTheaters,
  });

  List<Actor> homescreenActors = [
    Actor(
      id: 6911,
      fullName: 'Γιώργος Καραμίχος',
      image: 'https://image.tmdb.org/t/p/w300/nv5TR9NiELEGPJUQqVLEqZzcGZb.jpg',
      birthdate: null,
      height: null,
      weight: null,
      eyeColor: null,
      hairColor: null,
      bio: null,
      images: [],
    ),
    Actor(
      id: 5044,
      fullName: 'Γιώργος Νινιός',
      image: 'https://image.tmdb.org/t/p/w300/mR3QlGx3y68uVZriNzoOLOnwPy.jpg',
      birthdate: null,
      height: null,
      weight: null,
      eyeColor: null,
      hairColor: null,
      bio: null,
      images: [],
    ),
    Actor(
      id: 7544,
      fullName: 'Γιώργος Παπαγεωργίου',
      image: 'https://image.tmdb.org/t/p/w300/oiectxNJB7ctBwRKY45ChonEbjw.jpg',
      birthdate: null,
      height: null,
      weight: null,
      eyeColor: null,
      hairColor: null,
      bio: null,
      images: [],
    ),
  ];

  // List<Movie> homescreenMovies = [
  //   Movie(509, 'Το δικό μας Σινεμά', null, 'ΑΛΣΟΣ ΠΕΔΙΟΝ ΤΟΥ ΑΡΕΩΣ Ι.Κ.Ε',
  //       'https://www.viva.gr/tickets/getattachment/d8b548e8-490c-488f-9939-afd8ed7e821c/%ce%a4%ce%9f-%ce%94%ce%99%ce%9a%ce%9f-%ce%9c%ce%91%ce%A3-%ce%a3%ce%99%ce%9d%ce%95%ce%9c%ce%91---Online-Streaminfc370b491-a9e4.png', null,
  //       "Το θεατρικό μιούζικαλ, με ρεκόρ εισιτήριων..."),
  //   Movie(530, 'Τέλος του Παιχνιδιού', null, 'ΝΑΜΑ – ΛΥΚΟΦΩΣ Ι.Κ.Ε.',
  //       'https://www.viva.gr/tickets/getattachment/232be7ca-c7d2-4c0f-be82-88fab33836b6/%ce%a4%ce%b5%ce%bb%ce%bf%cf%82-%cf%84%ce%bf%cf%85-%ce%a0%ce%b1%ce%b9%cf%87%ce%bd%ce%b9%ce%b4%ce%b9%ce%bf%cf%8505040124-543c-4bde-a969-920f2d.png', null,
  //       "Το Σύγχρονο Θέατρο εγκαινιάζει την συνεργασία του με..."),
  //   Movie(507, 'Ο Απρόσκλητος Επισκέπτης', null, 'ΕΛΙΑΡΤ ΠΟΛΙΤΙΣΤΙΚΕΣ ΕΚΔΗΛΩΣΕΙΣ',
  //       'https://www.viva.gr/tickets/getattachment/36631a29-305c-438a-b596-4a2208d250aa/%ce%9f-%ce%91%cf%80%cf%81%ce%bf%cf%83%ce%ba%ce%bb%ce%b7%cf%84%ce%bf%cf%82-%ce%95%cf%80%ce%b9%cf%83%ce%ba%ce%b5%cf%80%cf%84%ce%b7%cf%82ebab1a2c-bbdc-439a-937a-6c.png', null,
  //       "Ο Απρόσκλητος Επισκέπτης της Άγκαθα Κρίστι (1957)..."),
  // ];
  List<Movie> homescreenMovies = [
    Movie(
      id: 509,
      title: 'Το δικό μας Σινεμά',
      ticketUrl: null, // Nullable field
      producer: 'ΑΛΣΟΣ ΠΕΔΙΟΝ ΤΟΥ ΑΡΕΩΣ Ι.Κ.Ε',
      mediaUrl:
          'https://www.viva.gr/tickets/getattachment/d8b548e8-490c-488f-9939-afd8ed7e821c/%ce%a4%ce%9f-%ce%94%ce%99%ce%9a%ce%9f-%ce%9c%ce%91%ce%A3-%ce%a3%ce%99%ce%9d%ce%95%ce%9c%ce%91---Online-Streaminfc370b491-a9e4.png',
      duration: null, // Nullable field
      description: "Το θεατρικό μιούζικαλ, με ρεκόρ εισιτήριων...",
      isSelected: false, // Default value, can be omitted
    ),
    Movie(
      id: 530,
      title: 'Τέλος του Παιχνιδιού',
      ticketUrl: null, // Nullable field
      producer: 'ΝΑΜΑ – ΛΥΚΟΦΩΣ Ι.Κ.Ε.',
      mediaUrl:
          'https://www.viva.gr/tickets/getattachment/232be7ca-c7d2-4c0f-be82-88fab33836b6/%ce%a4%ce%b5%ce%bb%ce%bf%cf%82-%cf%84%ce%bf%cf%85-%ce%a0%ce%b1%ce%b9%cf%87%ce%bd%ce%b9%ce%b4%ce%b9%ce%bf%cf%8505040124-543c-4bde-a969-920f2d.png',
      duration: null, // Nullable field
      description: "Το Σύγχρονο Θέατρο εγκαινιάζει την συνεργασία του με...",
      isSelected: false, // Default value, can be omitted
    ),
    Movie(
      id: 507,
      title: 'Ο Απρόσκλητος Επισκέπτης',
      ticketUrl: null, // Nullable field
      producer: 'ΕΛΙΑΡΤ ΠΟΛΙΤΙΣΤΙΚΕΣ ΕΚΔΗΛΩΣΕΙΣ',
      mediaUrl:
          'https://www.viva.gr/tickets/getattachment/36631a29-305c-438a-b596-4a2208d250aa/%ce%9f-%ce%91%cf%80%cf%81%ce%bf%cf%83%ce%ba%ce%bb%ce%b7%cf%84%ce%bf%cf%82-%ce%95%cf%80%cf%83%ce%ba%ce%b5%cf%80%cf%84%ce%b7%cf%82ebab1a2c-bbdc-439a-937a-6c.png',
      duration: null, // Nullable field
      description: "Ο Απρόσκλητος Επισκέπτης της Άγκαθα Κρίστι (1957)...",
      isSelected: false, // Default value, can be omitted
    ),
  ];

  List<Theater> homescreenTheaters = [
    Theater(
      id: 302,
      title: 'Νέος Ακάδημος',
      address: 'Athens, Αττική',
      isSelected: false,
    ),
    Theater(
        id: 305,
        title: 'Σύγχρονο Θέατρο',
        address: 'Κεραμεικός, Αττική',
        isSelected: false),
    Theater(
        id: 303,
        title: 'Θέατρο Μικρο Χορν',
        address: 'Κολωνάκι, Αττική',
        isSelected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors().black,
      body: Container(
        color: MyColors().black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 205,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return buildActorTile(index);
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 20);
                },
                itemCount: homescreenActors.length,
              ),
            ),
            SizedBox(
              height: 20,
              width: 10,
              child: FloatingActionButton.extended(
                heroTag: "btn1",
                label: Text('See more actors',
                    style: TextStyle(color: MyColors().cyan)),
                backgroundColor: MyColors().gray,
                onPressed: () {
                  Home.of(context)?.setBottomNav('Actors');
                },
              ),
            ),
            Divider(color: MyColors().gray),
            SizedBox(
              height: 205,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return buildMovieTile(index);
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 20);
                },
                itemCount: homescreenMovies.length,
              ),
            ),
            SizedBox(
              height: 20,
              width: 10,
              child: FloatingActionButton.extended(
                heroTag: "btn2",
                label: Text('See more movies',
                    style: TextStyle(color: MyColors().cyan)),
                backgroundColor: MyColors().gray,
                onPressed: () {
                  Home.of(context)?.setBottomNav('Movies');
                },
              ),
            ),
            Divider(color: MyColors().gray),
            SizedBox(
              height: 205,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return buildTheaterTile(index);
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 20);
                },
                itemCount: homescreenTheaters.length,
              ),
            ),
            SizedBox(
              height: 20,
              width: 10,
              child: FloatingActionButton.extended(
                heroTag: "btn3",
                label: Text('See more theaters',
                    style: TextStyle(color: MyColors().cyan)),
                backgroundColor: MyColors().gray,
                onPressed: () {
                  Home.of(context)?.setBottomNav('Theaters');
                },
              ),
            ),
            Divider(color: MyColors().gray),
          ],
        ),
      ),
    );
  }

  Widget buildActorTile(int index) => Container(
      width: 130,
      color: MyColors().black,
      child: Card(
        color: MyColors().black,
        child: Wrap(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(homescreenActors[index].image),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActorInfo(homescreenActors[index].id),
                  ),
                );
              },
              title: Center(
                child: Text(
                  homescreenActors[index].fullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MyColors().cyan, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ));

  Widget buildMovieTile(int index) => Container(
      width: 130,
      color: MyColors().black,
      child: Card(
        color: MyColors().black,
        child: Wrap(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage:
                      NetworkImage(homescreenMovies[index].mediaUrl ?? ''),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieInfo(homescreenMovies[index].id),
                  ),
                );
              },
              title: Center(
                child: Text(
                  homescreenMovies[index].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MyColors().cyan, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ));

  Widget buildTheaterTile(int index) => Container(
      width: 130,
      color: MyColors().black,
      child: Card(
        color: MyColors().black,
        child: Wrap(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(
                      'https://thumbs.dreamstime.com/z/location-pin-icon-165980583.jpg'),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TheaterInfo(theaterId: homescreenTheaters[index].id),
                  ),
                );
              },
              title: Center(
                child: Text(
                  homescreenTheaters[index].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MyColors().cyan, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ));
}
