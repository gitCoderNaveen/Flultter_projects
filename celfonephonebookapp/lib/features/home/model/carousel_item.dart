class CarouselItem {
  final String imageUrl;
  final String redirectUrl;

  CarouselItem({required this.imageUrl, required this.redirectUrl});

  factory CarouselItem.fromJson(Map<String, dynamic> json) {
    return CarouselItem(
      imageUrl: json['image_url'] as String,
      redirectUrl: json['redirect_url'] as String,
    );
  }
}
