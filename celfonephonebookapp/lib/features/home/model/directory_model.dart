class DirectoryModel {
  final String title;
  final String city;
  final String imageUrl;

  DirectoryModel({
    required this.title,
    required this.city,
    required this.imageUrl,
  });

  factory DirectoryModel.fromJson(Map<String, dynamic> json) {
    return DirectoryModel(
      title: json['title'],
      city: json['city'],
      imageUrl: json['image_url'],
    );
  }
}