class FavoriteModel {
  final String? id;
  final String businessName;
  final String personName;
  final String mobileNumber;
  final String groupId;

  FavoriteModel({
    this.id,
    required this.businessName,
    required this.personName,
    required this.mobileNumber,
    required this.groupId,
  });

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'group_id': groupId,
      'business_name': businessName,
      'person_name': personName,
      'mobile_number': mobileNumber,
    };
  }
}
