class EarningModel {
  final String id;
  final String entryName;
  final DateTime createdAt;

  EarningModel({
    required this.id,
    required this.entryName,
    required this.createdAt,
  });

  factory EarningModel.fromMap(Map<String, dynamic> map) {
    return EarningModel(
      id: map['id'].toString(),
      entryName: map['entryname'] ?? 'Entry',
      createdAt: DateTime.parse(map['created_at']).toLocal(),
    );
  }
}
