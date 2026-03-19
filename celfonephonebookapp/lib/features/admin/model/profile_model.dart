class Profile {
  final String id;
  final String? businessName;
  final String? personName;
  final String? mobileNumber;
  final String? landlineNumber;

  /// 🔥 Optional fields (add more as needed)
  final String? city;
  final String? keywords;
  final bool? isBusiness;
  final bool? isPrime;
  final int? priority;
  final int? normalList;
  final String? coverImage;
  final String? createdAt;

  /// 🔍 For search UI only (not DB)
  String? matchedName;

  Profile({
    required this.id,
    this.businessName,
    this.personName,
    this.mobileNumber,
    this.landlineNumber,
    this.city,
    this.keywords,
    this.isBusiness,
    this.isPrime,
    this.priority,
    this.normalList,
    this.coverImage,
    this.createdAt,
    this.matchedName,
  });

  /// ✅ FROM JSON (DB → App)
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id']?.toString() ?? '',
      businessName: json['business_name'],
      personName: json['person_name'],
      mobileNumber: json['mobile_number'],
      landlineNumber: json['landline_number'],
      city: json['city'],
      keywords: json['keywords'],
      isBusiness: json['is_business'],
      isPrime: json['is_prime'],
      priority: json['priority'],
      normalList: json['normal_list'],
      coverImage: json['cover_image'],
      createdAt: json['created_at'],
    );
  }

  /// ✅ TO JSON (App → DB)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'person_name': personName,
      'mobile_number': mobileNumber,
      'landline_number': landlineNumber,
      'city': city,
      'keywords': keywords,
      'is_business': isBusiness,
      'is_prime': isPrime,
      'priority': priority,
      'normal_list': normalList,
      'cover_image': coverImage,
      'created_at': createdAt,
    };
  }

  /// 🔥 OPTIONAL: CopyWith (VERY useful for updates)
  Profile copyWith({
    String? businessName,
    String? personName,
    String? mobileNumber,
    String? landlineNumber,
    String? city,
    String? keywords,
    bool? isBusiness,
    bool? isPrime,
    int? priority,
    int? normalList,
    String? coverImage,
    String? createdAt,
  }) {
    return Profile(
      id: id,
      businessName: businessName ?? this.businessName,
      personName: personName ?? this.personName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      landlineNumber: landlineNumber ?? this.landlineNumber,
      city: city ?? this.city,
      keywords: keywords ?? this.keywords,
      isBusiness: isBusiness ?? this.isBusiness,
      isPrime: isPrime ?? this.isPrime,
      priority: priority ?? this.priority,
      normalList: normalList ?? this.normalList,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      matchedName: matchedName,
    );
  }
}