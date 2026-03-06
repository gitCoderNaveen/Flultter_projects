class PlayBookModel {
  final String title;
  final String imageUrl;
  final String redirectUrl;

  PlayBookModel({
    required this.title,
    required this.imageUrl,
    required this.redirectUrl,
  });

  factory PlayBookModel.fromJson(Map<String, dynamic> json) {
    return PlayBookModel(
      title: json['title'],
      imageUrl: json['image_url'],
      redirectUrl: json['redirect_url'],
    );
  }
}
