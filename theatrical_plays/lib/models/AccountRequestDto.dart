class AccountRequestDto {
  final int id;
  final int personId;
  final String? status;
  final String? documentUrl;
  final String? userEmail;

  AccountRequestDto({
    required this.id,
    required this.personId,
    required this.status,
    this.documentUrl,
    this.userEmail,
  });

  factory AccountRequestDto.fromJson(Map<String, dynamic> json) {
    return AccountRequestDto(
      id: json['id'],
      personId: json['personId'],
      status: json['confirmationStatus'], // ← Εδώ ήταν το λάθος
      documentUrl: json['identificationDocument'], // ← Εδώ επίσης
      userEmail: json['userEmail'], // μπορεί να είναι null
    );
  }
}
