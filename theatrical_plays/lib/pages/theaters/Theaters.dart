import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/SearchWidget.dart';
import 'package:theatrical_plays/pages/theaters/TheaterGrid.dart';

import 'CompareTheaters.dart';
import 'TheaterInfo.dart';

class Theaters extends StatefulWidget {
  final List<Theater> theaters; // Marking as final and non-nullable
  Theaters(this.theaters);

  @override
  _TheatersState createState() => _TheatersState(theaters: theaters);
}

class _TheatersState extends State<Theaters> {
  late final List<Theater> theaters; // Marking as final and non-nullable
  _TheatersState({required this.theaters});

  String query = '';
  late List<Theater> theatersToSearch;
  List<Theater> selectedTheaters = [];

  @override
  void initState() {
    theatersToSearch = List.from(theaters);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        child: Column(
          children: [
            SearchWidget(
                text: query,
                hintText: 'Theater name',
                onChanged: searchTheaters),
            Expanded(
              child: TheaterGrid(theaters: theaters),
            ),
            if (selectedTheaters.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  children: [
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              // backgroundColor: MyColors().gray,
                              ),
                          child: Text(
                            "Compare (${selectedTheaters.length})",
                            style:
                                TextStyle(color: colors.accent, fontSize: 18),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CompareTheaters(selectedTheaters)));
                          },
                        )),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              // backgroundColor: MyColors().gray,
                              ),
                          child: Text(
                            "Clear",
                            style:
                                TextStyle(color: colors.accent, fontSize: 18),
                          ),
                          onPressed: () {
                            setState(() {
                              List<Theater> removeList =
                                  List.from(selectedTheaters);
                              for (var removeItem in removeList) {
                                for (var theater in theaters) {
                                  if (theater.id == removeItem.id) {
                                    theater.isSelected = false;
                                  }
                                }
                              }
                              selectedTheaters.clear();
                            });
                          },
                        ))
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> searchTheaters(String query) async {
    final search = theatersToSearch.where((theater) {
      final searchTheater = theater.title.toLowerCase();
      final searchLower = query.toLowerCase();

      return searchTheater.contains(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      theaters = query.isEmpty ? theatersToSearch : search;
    });
  }
}
