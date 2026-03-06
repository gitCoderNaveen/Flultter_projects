class MediaPartnerModel {
  final String? personName;
  final String? businessName;
  final String? mobileNumber;
  final String? landline;
  final String prefix;
  final String city;
  final String pincode;
  final String address;
  final String? email;
  final String? profession;
  final String? description;
  final String? profileImage;
  final String userType;

  MediaPartnerModel({
    required this.userType,
    required this.prefix,
    required this.city,
    required this.pincode,
    required this.address,
    this.personName,
    this.businessName,
    this.mobileNumber,
    this.landline,
    this.email,
    this.profession,
    this.description,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_type': userType,
      'person_name': personName,
      'business_name': businessName,
      'mobile_number': mobileNumber,
      'landline': landline,
      'person_prefix': prefix,
      'city': city,
      'pincode': pincode,
      'address': address,
      'email': email,
      'keywords': profession,
      'description': description,
      'profile_image': profileImage,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
