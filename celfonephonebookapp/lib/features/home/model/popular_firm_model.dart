class PopularFirmModel {
  final int id;
  final String name;
  final String logoUrl;

  PopularFirmModel({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory PopularFirmModel.fromJson(Map<String, dynamic> json) {
    return PopularFirmModel(
      id: json['id'],
      name: json['name'],
      logoUrl: json['icon_url'] ?? '',
    );
  }
}
