class Actor {
  final int id;
  final String fullName;
  final String image;
  final String? birthdate;
  final String? height;
  final String? weight;
  final String? eyeColor;
  final String? hairColor;
  final String? bio;
  final List<String> images; // Λίστα με όλες τις εικόνες του ηθοποιού
  final bool isClaimed;

  Actor(
      {required this.id,
      required this.fullName,
      required this.image,
      this.birthdate,
      this.height,
      this.weight,
      this.eyeColor,
      this.hairColor,
      this.bio,
      this.images = const [], // Default κενή λίστα αν δεν υπάρχουν εικόνες
      required this.isClaimed});

  factory Actor.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList =
          List<String>.from(json['images'].map((img) => img['imageUrl']));
    }

    // Παίρνουμε το πρώτο URL αν είναι έγκυρο, αλλιώς βάζουμε κενό
    String firstImage = (imagesList.isNotEmpty &&
            imagesList[0] != null &&
            imagesList[0].toString().isNotEmpty &&
            !imagesList[0].toString().contains("example.com"))
        ? imagesList[0]
        : '';

    return Actor(
      id: json['id'] ?? 0,
      fullName: json['fullname'] ?? 'Άγνωστο Όνομα',
      image: firstImage, // <-- βάζουμε '' αν δεν έχει usable image
      birthdate: json['birthdate'],
      height: json['height'],
      weight: json['weight'],
      eyeColor: json['eyeColor'],
      hairColor: json['hairColor'],
      bio: json['bio'],
      images: imagesList,
      isClaimed: json['isClaimed'] ?? false,
    );
  }
}
