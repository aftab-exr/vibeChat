class AuthUser {
  const AuthUser({required this.id, required this.username});

  final int id;
  final String username;

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username};
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
    );
  }
}
