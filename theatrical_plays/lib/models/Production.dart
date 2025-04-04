class Production {
  String role;
  int productionId;
  String title;
  String ticketUrl;
  String producer;
  String mediaUrl;
  String duration;
  String description;

  Production(this.role, this.productionId, this.title, this.ticketUrl,
      this.producer, this.mediaUrl, this.duration, this.description);

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
