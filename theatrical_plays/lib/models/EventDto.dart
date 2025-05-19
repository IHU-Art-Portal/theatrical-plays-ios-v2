class EventDto {
  final int id;
  final String? dateEvent;
  final String? priceRange;
  final int productionId;
  final int venueId;
  final bool isClaimed;

  EventDto({
    required this.id,
    this.dateEvent,
    this.priceRange,
    required this.productionId,
    required this.venueId,
    required this.isClaimed,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'],
      dateEvent: json['dateEvent'],
      priceRange: json['priceRange'],
      productionId: json['productionId'],
      venueId: json['venueId'],
      isClaimed: json['isClaimed'] ?? false,
    );
  }
}
