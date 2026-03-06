class ReverseNumberModel {
  final String name;
  final String mobile;
  final String address;
  final String email;
  final String city;
  final String pincode;
  final String landline;

  ReverseNumberModel({
    required this.name,
    required this.mobile,
    required this.address,
    required this.email,
    required this.city,
    required this.pincode,
    required this.landline,
  });

  factory ReverseNumberModel.fromJson(Map<String, dynamic> json) {
    return ReverseNumberModel(
      name: json['business_name'] ?? json['person_name'] ?? '',
      mobile: json['mobile_number'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      landline: json['landline'] ?? '',
    );
  }
}
