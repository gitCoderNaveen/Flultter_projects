class PartnerModel {
  final String id;
  final String fullName;
  final String email;
  final String status;

  PartnerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.status,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'inactive',
    );
  }
}
