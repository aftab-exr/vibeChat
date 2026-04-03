class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
  });

  // 🔐 NEW: Added fromJson to match what auth_session.dart is looking for
  factory AuthUser.fromJson(Map<String, dynamic> map) {
    return AuthUser(
      // Safely handle the MongoDB String
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '', 
      username: map['username'] as String? ?? 'Unknown',
    );
  }

  // 🔐 NEW: Added toJson to match what auth_session.dart is looking for
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }

  final String id;
  final String username;
}