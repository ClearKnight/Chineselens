import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic>? additionalInfo;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.lastLoginAt,
    this.additionalInfo,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        isEmailVerified,
        createdAt,
        lastLoginAt,
        additionalInfo,
      ];

  bool get isAnonymous => id.isEmpty || email.isEmpty;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  factory User.empty() {
    return User(
      id: '',
      email: '',
      name: null,
      photoUrl: null,
      isEmailVerified: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      additionalInfo: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
      'additionalInfo': additionalInfo,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      photoUrl: map['photoUrl'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'])
          : DateTime.now(),
      additionalInfo: map['additionalInfo'],
    );
  }
}
