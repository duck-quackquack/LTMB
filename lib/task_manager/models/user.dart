class User {
  String id;
  String username;
  String password;
  String email;
  String? avatar;
  String role;
  DateTime createdAt;
  DateTime lastActive;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar,
    required this.role,
    required this.createdAt,
    required this.lastActive,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      avatar: map['avatar'],
      role: map['role'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'avatar': avatar,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }
}
