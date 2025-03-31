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

  const ActorProfileBody({
    Key? key,
    required this.actor,
    required this.productions,
    required this.movies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        ActorHeaderWidget(
          fullName: actor.fullName,
          imageUrl: actor.image,
          birthdate: actor.birthdate,
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
        SizedBox(height: 30),
      ],
    );
  }
}
