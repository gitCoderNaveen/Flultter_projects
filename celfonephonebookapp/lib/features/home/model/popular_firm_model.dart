class PopularFirmModel {
  final String title;
  final String imageUrl;
  final String redirectUrl;

  PopularFirmModel({
    required this.title,
    required this.imageUrl,
    required this.redirectUrl,
  });

  factory PopularFirmModel.fromJson(Map<String, dynamic> json) {
    return PopularFirmModel(
      title: json['name'],
      imageUrl: json['icon_url'],
      redirectUrl: json['redirect_url'],
    );
  }
}
