import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/models/Production.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/Loading.dart';
import 'package:theatrical_plays/pages/actors/widgets/ActorProfileBody.dart';

class ActorProfilePage extends StatefulWidget {
  final Actor actor;
  const ActorProfilePage({Key? key, required this.actor}) : super(key: key);

  @override
  State<ActorProfilePage> createState() => _ActorProfilePageState();
}

class _ActorProfilePageState extends State<ActorProfilePage> {
  List<Production> productions = [];
  List<Movie> movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProductions();
  }

  Future<void> loadProductions() async {
    try {
      final token =
          await AuthorizationStore.getStoreValue("authorization") ?? '';
      final url = Uri.parse(
          "http://${Constants().hostName}/api/people/${widget.actor.id}/productions");

      final response = await http.get(url, headers: {
        "Authorization": token,
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['data']['results'];

        productions = results.map((item) {
          final p = item['production'];
          final role = item['role'] ?? '';
          return Production.fromJson(p, role: role);
        }).toList();

        movies = results.map((item) {
          final p = item['production'];
          return Movie.fromJson(p);
        }).toList();
      } else {
        print('Failed to load productions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.accent),
        title: Text(
          widget.actor.fullName,
          style: TextStyle(color: colors.accent),
        ),
      ),
      body: isLoading
          ? Center(child: Loading())
          : ActorProfileBody(
              actor: widget.actor,
              productions: productions,
              movies: movies,
            ),
    );
  }
}
