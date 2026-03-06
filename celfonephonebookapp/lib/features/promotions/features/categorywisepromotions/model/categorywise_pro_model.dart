class CategorywiseProModel {
  final String id;
  final String businessName;
  final String keywords;
  final String mobileNumber;
  final String city;

  CategorywiseProModel({
    required this.id,
    required this.businessName,
    required this.keywords,
    required this.mobileNumber,
    required this.city,
  });

  factory CategorywiseProModel.fromMap(Map<String, dynamic> map) {
    return CategorywiseProModel(
      id: map['id'].toString(),
      businessName: map['business_name'] ?? '',
      keywords: map['keywords'] ?? '',
      mobileNumber: map['mobile_number'] ?? '',
      city: map['city'] ?? '',
    );
  }
}
