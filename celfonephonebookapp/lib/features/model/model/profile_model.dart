class ProfileModel {
  final String id;
  final String businessName;
  final String personName;
  final String mobile;
  final String landline; // NEW
  final String landlineCode; // NEW
  final String city;
  final String pincode; // NEW
  final String coverImage;
  final bool isPrime;
  final String email;
  final String keywords;
  final String description;
  final String address;

  ProfileModel({
    required this.id,
    required this.businessName,
    required this.personName,
    required this.mobile,
    required this.landline,
    required this.landlineCode,
    required this.city,
    required this.pincode, // NEW
    required this.coverImage,
    required this.isPrime,
    required this.email,
    required this.keywords,
    required this.description,
    required this.address,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'].toString(),
      businessName: map['business_name'] ?? '',
      personName: map['person_name'] ?? '',
      mobile: map['mobile_number'] ?? '',
      landline: map['landline'] ?? '', // NEW
      landlineCode: map['landline_code'] ?? '', // NEW
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      pincode: map['pincode'] ?? '', // NEW
      coverImage: map['cover_image'] ?? '',
      isPrime: map['is_prime'] ?? false,
      email: map['email'] ?? '',
      keywords: map['keywords'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
