class PopularFirmModel {
  final String title;
  final String imageUrl;

  PopularFirmModel({required this.title, required this.imageUrl});

  factory PopularFirmModel.fromJson(Map<String, dynamic> json) {
    return PopularFirmModel(title: json['name'], imageUrl: json['icon_url']);
  }
}
