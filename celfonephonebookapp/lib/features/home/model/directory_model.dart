class DirectoryModel {
  final String title;
  final String image;
  final String imageKeywords;

  DirectoryModel({
    required this.title,
    required this.image,
    required this.imageKeywords,
  });

  factory DirectoryModel.fromJson(Map<String, dynamic> json) {
    return DirectoryModel(
      title: json['image_title'] ?? '',
      image: json['image'] ?? '',
      imageKeywords: json['image_keywords'] ?? '',
    );
  }
}
