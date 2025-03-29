import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? nativeLanguage;
  final String? learningLevel;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.nativeLanguage,
    this.learningLevel,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      nativeLanguage: json['nativeLanguage'] as String?,
      learningLevel: json['learningLevel'] as String?,
      createdAt: (json['createdAt'] as Map<String, dynamic>?)?.let((it) =>
              DateTime.fromMillisecondsSinceEpoch(it['seconds'] * 1000)) ??
          DateTime.now(),
      lastLogin: (json['lastLogin'] as Map<String, dynamic>?)?.let(
          (it) => DateTime.fromMillisecondsSinceEpoch(it['seconds'] * 1000)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'nativeLanguage': nativeLanguage,
      'learningLevel': learningLevel,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? nativeLanguage,
    String? learningLevel,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningLevel: learningLevel ?? this.learningLevel,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        nativeLanguage,
        learningLevel,
        createdAt,
        lastLogin,
      ];
}

// Helper extension to handle nullable maps conversion
extension MapNullableExt<K, V> on Map<K, V>? {
  R let<R>(R Function(Map<K, V>) block) {
    if (this == null) {
      throw Exception('Map is null');
    }
    return block(this!);
  }
}
