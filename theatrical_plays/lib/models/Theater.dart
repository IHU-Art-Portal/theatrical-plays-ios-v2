// class Theater {
//   int id;
//   String title;
//   String address;
//   bool isSelected;
//
//   Theater(this.id, this.title, this.address, this.isSelected);
// }
class Theater {
  final int id;
  final String title;
  final String address;
  bool isSelected;
  final bool isClaimed;

  Theater({
    required this.id,
    required this.title,
    required this.address,
    this.isSelected = false, // Default value for isSelected if not provided
    this.isClaimed = false,
  });

  factory Theater.fromJson(Map<String, dynamic> json) {
    return Theater(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      address: json['address'] ?? 'Unknown Address',
      isClaimed: json['isClaimed'] ?? false, // ✅ Εδώ γεμίζει από το API
    );
  }
}
