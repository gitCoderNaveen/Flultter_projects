class AppUser {
  final String id;
  final String? email;

  AppUser({required this.id, this.email});

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
    );
  }
}