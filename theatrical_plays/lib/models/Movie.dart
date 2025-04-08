class Movie {
  final int id;
  final String title;
  final String? ticketUrl;
  final String producer;
  final String? mediaUrl;
  final String? duration;
  final String description;
  bool isSelected;
  final int? organizerId;
  final String? type; // Είδος
  final String? venue; // Χώρος
  final List<String> dates; // Λίστα ημερομηνιών

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
    this.organizerId,
    this.dates = const [], // Default to empty list if not provided
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      ticketUrl: json['ticketUrl'] ?? json['url'], // Support both fields
      producer: json['producer'] ?? 'Unknown Producer',
      mediaUrl: json['mediaUrl'] ??
          json['mediaURL'] ?? // Support both 'mediaUrl' and 'mediaURL'
          'https://thumbs.dreamstime.com/z/print-178440812.jpg',
      duration: json['duration'] ?? 'Unknown Duration',
      description: json['description'] ?? 'No description available',
      isSelected: json['isSelected'] ?? false,
      type: json['type'],
      venue: json['venue'],
      organizerId: json['organizerId'],
      dates: (json['dates'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
