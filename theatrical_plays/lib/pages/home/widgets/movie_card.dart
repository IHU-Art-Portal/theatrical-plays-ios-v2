import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 170,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: movie.mediaUrl != null && movie.mediaUrl!.isNotEmpty
                    ? Image.network(
                        movie.mediaUrl!,
                        height: 75,
                        width: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _defaultImage(),
                      )
                    : _defaultImage(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  movie.title,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultImage() {
    return Container(
      height: 75,
      width: 75,
      color: Colors.grey.shade800,
      child: Icon(Icons.movie, size: 26, color: Colors.grey.shade400),
    );
  }
}
