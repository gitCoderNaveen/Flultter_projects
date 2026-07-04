class ProfileModel {
  final String id;
  final String personName;
  final String mobileNumber;
  final String city;
  final String email;
  final String personPrefix;
  final String keywords;
  final String pincode;
  final String landlineCode;
  final String landlineNumber;
  final String whatsApp;
  final String address;
  final String profileImage;
  final String businessName;
  final String description;
  final String promoCode;
  final String webSite;
  final List<String> productImages;
  final String userType;
  final bool isBusiness;

  const ProfileModel({
    this.id = '',
    this.personName = '',
    this.mobileNumber = '',
    this.city = '',
    this.email = '',
    this.personPrefix = '',
    this.keywords = '',
    this.pincode = '',
    this.landlineCode = '',
    this.landlineNumber = '',
    this.whatsApp = '',
    this.address = '',
    this.profileImage = '',
    this.businessName = '',
    this.description = '',
    this.promoCode = '',
    this.webSite = '',
    this.productImages = const [],
    this.userType = '',
    this.isBusiness = false,
  });

  /// Empty Profile
  factory ProfileModel.empty() {
    return const ProfileModel();
  }

  /// Supabase -> Model
  factory ProfileModel.fromMap(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      personName: json['person_name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      city: json['city'] ?? '',
      email: json['email'] ?? '',
      personPrefix: json['person_prefix'] ?? '',
      keywords: (json['keywords'] ?? '').toString(),
      pincode: json['pincode'] ?? '',
      landlineCode: json['landline_code'] ?? '',
      landlineNumber: json['landline_number'] ?? '',
      whatsApp: json['whats_app'] ?? '',
      address: json['address'] ?? '',
      // profileImage: json['profile_image'] ?? '',
      businessName: json['business_name'] ?? '',
      description: json['description'] ?? '',
      promoCode: json['promo_code'] ?? '',
      webSite: json['web_site'] ?? '',
      userType: json['user_type'] ?? '',
      isBusiness: json['is_business'] ?? false,
      // productImages: json['product_images'] == null
      //     ? []
      //     : List<String>.from(json['product_images']),
    );
  }

  /// Model -> Supabase
  Map<String, dynamic> toMap() {
    return {
      'person_name': personName,
      'mobile_number': mobileNumber,
      'city': city,
      'email': email,
      'person_prefix': personPrefix,
      'keywords': keywords,
      'pincode': pincode,
      'landline_code': landlineCode,
      'landline_number': landlineNumber,
      'whats_app': whatsApp,
      'address': address,
      'profile_image': profileImage,
      'business_name': businessName,
      'description': description,
      'promo_code': promoCode,
      'web_site': webSite,
      'product_images': productImages,
      'user_type': userType,
      'is_business': isBusiness,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? personName,
    String? mobileNumber,
    String? city,
    String? email,
    String? personPrefix,
    String? keywords,
    String? pincode,
    String? landlineCode,
    String? landlineNumber,
    String? whatsApp,
    String? address,
    String? profileImage,
    String? businessName,
    String? description,
    String? promoCode,
    String? webSite,
    List<String>? productImages,
    String? userType,
    bool? isBusiness,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      city: city ?? this.city,
      email: email ?? this.email,
      personPrefix: personPrefix ?? this.personPrefix,
      keywords: keywords ?? this.keywords,
      pincode: pincode ?? this.pincode,
      landlineCode: landlineCode ?? this.landlineCode,
      landlineNumber: landlineNumber ?? this.landlineNumber,
      whatsApp: whatsApp ?? this.whatsApp,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      promoCode: promoCode ?? this.promoCode,
      webSite: webSite ?? this.webSite,
      productImages: productImages ?? this.productImages,
      userType: userType ?? this.userType,
      isBusiness: isBusiness ?? this.isBusiness,
    );
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, personName: $personName, businessName: $businessName)';
  }
}