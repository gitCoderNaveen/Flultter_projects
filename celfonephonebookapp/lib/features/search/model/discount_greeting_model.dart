class DiscountGreetingCard {
  final String id;
  final String title;
  final String message;
  final String buttonText;
  final String backgroundColor;
  final DateTime expiryDate;
  final DateTime? claimedAt;

  DiscountGreetingCard({
    required this.id,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.backgroundColor,
    required this.expiryDate,
    this.claimedAt,
  });

  factory DiscountGreetingCard.fromJson(Map<String, dynamic> json) {
    return DiscountGreetingCard(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      buttonText: json['button_text'] ?? '',
      backgroundColor: json['background_color'] ?? '#FFFFFF',
      expiryDate: DateTime.parse(json['expiry_date']),
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'])
          : null,
    );
  }
}
