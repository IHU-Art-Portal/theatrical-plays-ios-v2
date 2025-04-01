import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Actor.dart';

class ActorCard extends StatelessWidget {
  final Actor actor;

  const ActorCard({Key? key, required this.actor}) : super(key: key);

  bool get hasValidImage =>
      actor.image.isNotEmpty && !actor.image.contains("example.com");

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // μικρότερο για να χωράει σε όλες τις οθόνες
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: hasValidImage
                        ? Image.network(
                            actor.image,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _defaultImage();
                            },
                          )
                        : _defaultImage(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _splitName(actor.fullName),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          )
        ],
      ),
    );
  }

  Widget _defaultImage() {
    return Image.asset(
      'assets/test_files/default_actor.png',
      height: 60,
      width: 60,
      fit: BoxFit.cover,
    );
  }

  String _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first}\n${parts.sublist(1).join(' ')}';
    }
    return fullName;
  }
}
