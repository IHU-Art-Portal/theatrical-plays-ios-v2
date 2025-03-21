import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class TheaterProfile extends StatelessWidget {
  final Theater theater;

  const TheaterProfile({Key? key, required this.theater}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Column(
      children: [
        buildImage(),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Text(
              theater.title, // Assuming title is non-null
              style: TextStyle(color: colors.accent, fontSize: 18),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
          child: Text(
            "Address: " + (theater.address), // Handle nullable address
            style: TextStyle(color: colors.accent, fontSize: 18),
          ),
        ),
        FloatingActionButton.extended(
          label: Text('See on map',
              style: TextStyle(color: colors.accent, fontSize: 18)),
          backgroundColor: colors.background,
          onPressed: () {
            _launchMap(theater.address); // Handle nullable address
          },
        )
      ],
    );
  }

  Widget buildImage() {
    final image = NetworkImage(
        'https://thumbs.dreamstime.com/z/location-pin-icon-165980583.jpg');

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
        ),
      ),
    );
  }

  Future<void> _launchMap(String? address) async {
    if (address != null && address.isNotEmpty) {
      if (Platform.isIOS) {
        try {
          await MapsLauncher.launchQuery(address);
        } catch (e) {
          print('Error launching map: $e');
        }
      }
    } else {
      print('No valid address provided');
    }
  }
}
