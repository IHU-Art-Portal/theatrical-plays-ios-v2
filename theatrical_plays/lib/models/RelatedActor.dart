import 'package:theatrical_plays/models/Actor.dart';

class RelatedActor extends Actor {
  final String role;

  RelatedActor({
    required this.role,
    required int id,
    required String fullName,
    required String image,
    String? birthdate,
    String? height,
    String? weight,
    String? eyeColor,
    String? hairColor,
    String? bio,
    List<String> images = const [],
  }) : super(
          id: id,
          fullName: fullName,
          image: image,
          birthdate: birthdate,
          height: height,
          weight: weight,
          eyeColor: eyeColor,
          hairColor: hairColor,
          bio: bio,
          images: images,
        );

  // Factory method για δημιουργία RelatedActor από JSON
  factory RelatedActor.fromJson(Map<String, dynamic> json) {
    return RelatedActor(
      role: json['role'] ?? 'No role found',
      id: json['id'] ?? 0,
      fullName: json['fullname'] ?? 'Unknown Actor',
      image: (json['images'] != null && json['images'].isNotEmpty)
          ? json['images'][0]['imageUrl']
          : 'https://www.macunepimedium.com/wp-content/uploads/2019/04/male-icon.jpg',
      birthdate: json['birthdate'],
      height: json['height'],
      weight: json['weight'],
      eyeColor: json['eyeColor'],
      hairColor: json['hairColor'],
      bio: json['bio'],
      images: json['images'] != null
          ? List<String>.from(json['images'].map((img) => img['imageUrl']))
          : [],
    );
  }

  Actor toActor() {
    return Actor(
      id: id,
      fullName: fullName,
      image: image,
      birthdate: null,
      height: null,
      weight: null,
      eyeColor: null,
      hairColor: null,
      bio: '',
    );
  }
}
