class NearbyPromotionModel {
  final String mobileNumber;

  final String? personPrefix;
  final String? personName;

  final String? businessPrefix;
  final String? businessName;
  final String pincode;

  bool isSent;

  NearbyPromotionModel({
    required this.mobileNumber,
    this.personPrefix,
    this.personName,
    this.businessPrefix,
    this.businessName,
    required this.pincode,
    this.isSent = false,
  });

  factory NearbyPromotionModel.fromJson(Map<String, dynamic> json) {
    return NearbyPromotionModel(
      personPrefix: json['person_prefix'],
      businessPrefix: json['business_prefix'],
      personName: json['person_name'],
      businessName: json['business_name'],
      mobileNumber: json['mobile_number']?.toString() ?? "",
      pincode: json['pincode']?.toString() ?? "",
      isSent: json['isSent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "person_name": personName,
      "business_name": businessName,
      "mobile_number": mobileNumber,
      "person_prefix": personPrefix,
      "business_prefix": businessPrefix,
      "pincode": pincode,
      "isSent": isSent,
    };
  }
}
