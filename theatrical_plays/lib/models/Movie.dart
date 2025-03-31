class Movie {
  final int id;
  final String title;
  final String? ticketUrl; // Nullable
  final String producer;
  final String? mediaUrl; // Nullable
  final String? duration; // Nullable
  final String description;
  bool isSelected;

  Movie({
    required this.id,
    required this.title,
    this.ticketUrl,
    required this.producer,
    this.mediaUrl,
    this.duration,
    required this.description,
    this.isSelected = false, // Default value
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      ticketUrl: json['ticketUrl'], // nullable OK
      producer: json['producer'] ?? 'Unknown Producer',
      mediaUrl: json['mediaURL'], // nullable OK
      duration: json['duration'], // nullable OK
      description: json['description'] ?? 'No description available',
      isSelected: false,
    );
  }
}
