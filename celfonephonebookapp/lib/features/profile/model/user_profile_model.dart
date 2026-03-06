class UserProfile {
  final String id;
  final String? personName;
  final String? mobileNumber;
  final String? personPrefix;
  final String? profession;
  final String? city;
  final String? pincode;
  final String? email;
  final String? landlineCode;
  final String? landlineNumber;
  final String? whatsApp;
  final String? address;
  final String? businessAddress;
  String? profileImage;
  final String? businessName;
  final String? description;
  final String? promoCode;
  final String? webSite;
  final String? userType;
  final bool? isBusiness;
  final String? keywords;
  String? productImages;

  UserProfile({
    required this.id,
    this.personName,
    this.mobileNumber,
    this.personPrefix,
    this.profession,
    this.city,
    this.pincode,
    this.email,
    this.landlineCode,
    this.landlineNumber,
    this.whatsApp,
    this.address,
    this.businessAddress,
    this.profileImage,
    this.businessName,
    this.description,
    this.promoCode,
    this.webSite,
    this.productImages,
    this.userType,
    this.isBusiness,
    this.keywords,
  });

  factory UserProfile.fromSupabase(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id']?.toString() ?? '',
      personName: data['person_name'],
      mobileNumber: data['mobile_number'],
      personPrefix: data['person_prefix'],
      profession: data['keywords'],
      city: data['city'],
      pincode: data['pincode'],
      email: data['email'],
      landlineCode: data['landline_code'],
      landlineNumber: data['landline_number'],
      whatsApp: data['whats_app'],
      address: data['address'],
      businessAddress: data['bussiness_address'], // DB spelling
      profileImage: data['profile_image'],
      businessName: data['business_name'],
      description: data['description'],
      promoCode: data['promo_code'],
      webSite: data['web_site'],
      productImages: data['product_images'],
      userType: data['user_type'],
      isBusiness: data['is_business'] as bool?,
      keywords: data['keywords'],
    );
  }
}
