class Production {
  final String role;
  final int id;
  final String title;
  final String ticketUrl;
  final String producer;
  final String mediaUrl;
  final String duration;
  final String description;

  Production(
    this.role,
    this.id,
    this.title,
    this.ticketUrl,
    this.producer,
    this.mediaUrl,
    this.duration,
    this.description,
  );

  factory Production.fromJson(Map<String, dynamic> json,
      {required String role}) {
    return Production(
      role,
      json['id'] ?? 0,
      json['title'] ?? '',
      json['ticketUrl'] ?? '',
      json['producer'] ?? '',
      json['mediaURL'] ?? '',
      json['duration'] ?? '',
      json['description'] ?? '',
    );
  }
}
