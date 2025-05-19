import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/models/Production.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/pages/actors/widgets/ActorHeaderWidget.dart';
import 'package:theatrical_plays/pages/actors/widgets/KnownForCarousel.dart';
import 'package:theatrical_plays/pages/actors/widgets/BiographySection.dart';
import 'package:theatrical_plays/pages/actors/widgets/ActorDetailsSection.dart';

class ActorProfileBody extends StatelessWidget {
  final Actor actor;
  final List<Production> productions;
  final List<Movie> movies;
  final VoidCallback onClaimPressed; //  Προσθήκη callback για το κουμπί
  final bool isClaimed;

  const ActorProfileBody({
    Key? key,
    required this.actor,
    required this.productions,
    required this.movies,
    required this.onClaimPressed,
    required this.isClaimed, // Για έλεγχο κατάστασης
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        ActorHeaderWidget(
          fullName: actor.fullName,
          imageUrl: actor.image,
          birthdate: actor.birthdate,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: isClaimed ? null : onClaimPressed,
            icon: Icon(isClaimed ? Icons.verified : Icons.verified_outlined),
            label: Text(isClaimed ? 'Ήδη Διεκδικημένο' : 'Αίτημα Διεκδίκησης'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isClaimed ? Colors.grey : Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        KnownForCarousel(
          productions: productions,
          movies: movies,
        ),
        BiographySection(
          bio: actor.bio,
        ),
        ActorDetailsSection(
          birthdate: actor.birthdate,
          height: actor.height,
          weight: actor.weight,
          eyeColor: actor.eyeColor,
          hairColor: actor.hairColor,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
