class User {
  final int? id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
  });

  // Convert from Map (from database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // CopyWith method for updating
  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
