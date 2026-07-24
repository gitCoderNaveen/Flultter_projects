class ReferralModel {
  final String id;
  final String referrerId;
  final String referredName;
  final String referredPhone;
  final String referralCode;
  final bool smsSent;
  final bool joined;
  final bool couponGenerated;
  final DateTime createdAt;

  ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredName,
    required this.referredPhone,
    required this.referralCode,
    required this.smsSent,
    required this.joined,
    required this.couponGenerated,
    required this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'],
      referrerId: json['referrer_id'],
      referredName: json['referred_name'],
      referredPhone: json['referred_phone'],
      referralCode: json['referral_code'],
      smsSent: json['sms_sent'] ?? false,
      joined: json['joined'] ?? false,
      couponGenerated: json['coupon_generated'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referrer_id': referrerId,
      'referred_name': referredName,
      'referred_phone': referredPhone,
      'referral_code': referralCode,
      'sms_sent': smsSent,
      'joined': joined,
      'coupon_generated': couponGenerated,
    };
  }
}