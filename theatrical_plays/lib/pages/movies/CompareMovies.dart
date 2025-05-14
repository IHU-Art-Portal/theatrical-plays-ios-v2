import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:theatrical_plays/models/ChartCompMovie.dart';
import 'package:theatrical_plays/models/CompMovie.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/Loading.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class CompareMovies extends StatefulWidget {
  final List<Movie> selectedMovies;
  CompareMovies(this.selectedMovies);

  @override
  State<CompareMovies> createState() =>
      _CompareMoviesState(selectedMovies: this.selectedMovies);
}

class _CompareMoviesState extends State<CompareMovies> {
  final List<Movie> selectedMovies;
  _CompareMoviesState({required this.selectedMovies});

  List<CompMovie> compareMovies = [];
  CompMovie? compareMovie;

  List<ChartCompMovie> chartMovies = [];

  Future<List<CompMovie>> loadCompareMovie() async {
    try {
      for (var item in selectedMovies) {
        int movieId = item.id;
        print(item.id);
        Uri uri = Uri.parse(
            "http://${Constants().hostName}:8080/api/productions/$movieId/events");
        Response data = await get(uri, headers: {
          "Accept": "application/json",
          "authorization":
              "${await AuthorizationStore.getStoreValue("authorization")}"
        });
        var jsonData = jsonDecode(data.body);

        if (jsonData['data'].toString() == '[]') {
          print("Null data");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("${item.title} has no event."),
          ));
          break;
        } else {
          compareMovie =
              CompMovie(item.id, item.title, jsonData['data'][0]['priceRange']);
          compareMovies.add(compareMovie!);
        }
      }
      return compareMovies;
    } catch (e) {
      print('Error loading data: $e');
      return []; // Return empty list in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<List<CompMovie>>(
            future: loadCompareMovie(),
            builder: (BuildContext context,
                AsyncSnapshot<List<CompMovie>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return TheaterSeatsLoading();
              } else if (snapshot.hasError) {
                return Text("Error loading movies");
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                castPrice(compareMovies);
                return chartBuilder();
              } else {
                Navigator.pop(context);
                return Container();
              }
            }));
  }

  Widget chartBuilder() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    print(chartMovies[0].title);
    print(chartMovies[0].priceRange.toString());
    print(compareMovies[0].priceRange.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticket prices',
          style: TextStyle(color: colors.accent),
        ),
        backgroundColor: colors.background,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: colors.background,
      body: Container(
        child: SfCartesianChart(
            margin: EdgeInsets.fromLTRB(20, 30, 20, 30),
            series: <CartesianSeries>[
              ColumnSeries<ChartCompMovie, String>(
                  dataSource: chartMovies,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  pointColorMapper: (ChartCompMovie movie, _) =>
                      movie.columnColor,
                  xValueMapper: (ChartCompMovie movie, _) => movie.title,
                  yValueMapper: (ChartCompMovie movie, _) => movie.priceRange)
            ],
            tooltipBehavior: TooltipBehavior(
                enable: true, header: 'Movie', format: 'point.x: point.y€'),
            primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
                maximumLabelWidth: 90.0,
                labelIntersectAction: AxisLabelIntersectAction.wrap),
            backgroundColor: colors.background),
      ),
    );
  }

  void castPrice(List<CompMovie> compareMovies) {
    var doubleRE = RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?");
    double? clearPrice;
    var colors = [Colors.red, Colors.teal, Colors.orange, Colors.brown];
    var colorCounter = 0;

    for (var item in compareMovies) {
      // Clear the number values from priceRange
      item.priceRange = item.priceRange.replaceAll(',', '.');
      var numbers = doubleRE
          .allMatches(item.priceRange)
          .map((m) => double.parse(m[0]!))
          .toList();
      if (numbers.isNotEmpty) {
        clearPrice = numbers.reduce(max);
      } else {
        clearPrice = 12.0; // Default price if none found
      }

      ChartCompMovie chartCompMovie = ChartCompMovie(
          item.id, item.title, clearPrice, item.title, colors[colorCounter]);
      chartMovies.add(chartCompMovie);

      colorCounter = (colorCounter + 1) % colors.length; // Cycle through colors
    }
  }
}
