class Movie {
  final int id;
  final String title;
  final String? ticketUrl;
  final String producer;
  final String? mediaUrl;
  final String? duration;
  final String description;
  bool isSelected;

  // 👉 Νέα φίλτρα
  final String? type; // Είδος
  final String? venue; // Χώρος
  final String? startDate; // ISO format ημερομηνία

  Movie({
    required this.id,
    required this.title,
    this.ticketUrl,
    required this.producer,
    this.mediaUrl,
    this.duration,
    required this.description,
    this.isSelected = false,
    this.type,
    this.venue,
    this.startDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Χωρίς τίτλο',
      ticketUrl: json['ticketUrl'],
      producer: json['producer'] ?? 'Άγνωστος παραγωγός',
      mediaUrl: json['mediaURL'],
      duration: json['duration'],
      description: json['description'] ?? 'Δεν υπάρχει περιγραφή',
      isSelected: false,
      type: json['type'] ?? '',
      venue: json['venue'] ?? '',
      startDate: json['startDate'],
    );
  }
}
