import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieProfile extends StatefulWidget {
  final Movie movie; // Marked movie as final and non-nullable
  MovieProfile({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieProfile createState() => _MovieProfile(movie: movie);
}

class _MovieProfile extends State<MovieProfile> {
  final Movie movie; // Marked movie as final and non-nullable
  _MovieProfile({required this.movie});

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
              movie.title, // Assuming title is non-nullable
              style: TextStyle(color: colors.accent, fontSize: 20),
            ),
          ),
        ),
        Divider(color: colors.secondaryText),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 0, 15),
          child: Text('Description',
              style: TextStyle(color: colors.accent, fontSize: 20)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
          child: Text(
            movie.description, // Assuming description is non-nullable
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        Divider(color: colors.secondaryText),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (movie.duration != null && movie.duration!.isNotEmpty)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Duration: ",
                          style: TextStyle(color: colors.accent, fontSize: 18)),
                      TextSpan(
                          text: movie.duration,
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
              if (movie.producer.isNotEmpty)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Producer: ",
                          style: TextStyle(color: colors.accent, fontSize: 18)),
                      TextSpan(
                          text: movie.producer.trim(),
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        FloatingActionButton.extended(
          label: Text(
            'Trailer',
            style: TextStyle(color: colors.accent, fontSize: 18),
          ),
          backgroundColor: colors.secondaryText,
          onPressed: () {
            _launchURL(movie.title); // Assuming title is non-nullable
          },
        ),
      ],
    );
  }

  Widget buildImage() {
    final image =
        NetworkImage("https://thumbs.dreamstime.com/z/print-178440812.jpg");

    return FadeInImage(
      placeholder: NetworkImage(
          'https://www.creativefabrica.com/wp-content/uploads/2021/01/14/theater-mask-actor-logo-vector-Graphics-7777527-1-1-580x387.jpg'),
      image:
          NetworkImage(movie.mediaUrl ?? image.url), // Handle nullable mediaUrl
      width: 200, // set the desired width
      height: 200, // set the desired height
    );
  }

  Future<void> _launchURL(String query) async {
    final url = 'https://www.youtube.com/results?search_query=$query';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
