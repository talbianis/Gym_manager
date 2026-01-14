class User {
  final int? id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;
  bool isLoggedIn; // Add this field

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    this.isLoggedIn = false, // Default to false
  });

  // Convert from Map (from database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      isLoggedIn: (map['is_logged_in'] ?? 0) == 1, // Convert from integer
    );
  }

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'is_logged_in': isLoggedIn ? 1 : 0, // Store as integer
    };
  }

  // CopyWith method for updating
  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    DateTime? createdAt,
    bool? isLoggedIn,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
