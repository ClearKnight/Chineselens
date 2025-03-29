import 'package:equatable/equatable.dart';

/// 学习卡片实体
/// 表示用户保存的中文学习卡片，包含识别的文字和相关信息
class LearningCard extends Equatable {
  /// 卡片唯一ID
  final String id;

  /// 所属用户ID
  final String userId;

  /// 图片URL
  final String imageUrl;

  /// 中文文本
  final String chineseText;

  /// 拼音
  final String? pinyin;

  /// 翻译
  final String? translation;

  /// 分类
  final String? category;

  /// 创建时间
  final DateTime createdAt;

  /// 复习次数
  final int reviewCount;

  /// 最后复习时间
  final DateTime? lastReviewed;

  /// 熟练度 (0-100)
  final int mastery;

  /// 创建一个学习卡片
  const LearningCard({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.chineseText,
    this.pinyin,
    this.translation,
    this.category,
    required this.createdAt,
    this.reviewCount = 0,
    this.lastReviewed,
    this.mastery = 0,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        imageUrl,
        chineseText,
        pinyin,
        translation,
        category,
        createdAt,
        reviewCount,
        lastReviewed,
        mastery,
      ];

  /// 创建具有新属性的卡片副本
  LearningCard copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? chineseText,
    String? pinyin,
    String? translation,
    String? category,
    DateTime? createdAt,
    int? reviewCount,
    DateTime? lastReviewed,
    int? mastery,
  }) {
    return LearningCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      chineseText: chineseText ?? this.chineseText,
      pinyin: pinyin ?? this.pinyin,
      translation: translation ?? this.translation,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      mastery: mastery ?? this.mastery,
    );
  }

  /// 将实体转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'chineseText': chineseText,
      'pinyin': pinyin,
      'translation': translation,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'reviewCount': reviewCount,
      'lastReviewed': lastReviewed?.millisecondsSinceEpoch,
      'mastery': mastery,
    };
  }

  /// 从Map创建实体
  factory LearningCard.fromMap(Map<String, dynamic> map) {
    return LearningCard(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      chineseText: map['chineseText'] ?? '',
      pinyin: map['pinyin'],
      translation: map['translation'],
      category: map['category'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      reviewCount: map['reviewCount'] ?? 0,
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReviewed'])
          : null,
      mastery: map['mastery'] ?? 0,
    );
  }

  /// 创建空卡片
  factory LearningCard.empty() {
    return LearningCard(
      id: '',
      userId: '',
      imageUrl: '',
      chineseText: '',
      createdAt: DateTime.now(),
    );
  }
}
