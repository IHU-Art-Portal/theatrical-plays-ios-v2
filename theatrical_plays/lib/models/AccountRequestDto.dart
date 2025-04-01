class AccountRequestDto {
  final int id;
  final int personId;
  final String? status;
  final String? documentUrl;
  final String? userEmail;
  final String? username;
  final int? userId;

  AccountRequestDto({
    required this.id,
    required this.personId,
    required this.status,
    this.documentUrl,
    this.userEmail,
    this.username,
    this.userId,
  });

  factory AccountRequestDto.fromJson(Map<String, dynamic> json) {
    return AccountRequestDto(
      id: json['id'],
      personId: json['personId'],
      status: json['confirmationStatus'], // ← Εδώ ήταν το λάθος
      documentUrl: json['identificationDocument'], // ← Εδώ επίσης
      userEmail: json['userEmail'], // μπορεί να είναι null
      username: json['username'],
      userId: json['userId'],
    );
  }
}
