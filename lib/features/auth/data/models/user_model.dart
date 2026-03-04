import 'package:needo/features/auth/domain/entities/user_entity.dart';

/// The Data Layer representation of a User.
/// It extends [UserEntity] but adds JSON serialization logic for Firebase.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.isProvider = false,
    super.providerCategory,
    super.hourlyRate,
    super.profileImageUrl,
    super.googleBusinessUrl,
    super.reviewCount = 0,
    super.averageRating = 0.0,
    super.about,
    super.phone,
    super.ratingDistribution = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  });

  /// Factory constructor to create a UserModel from a Firestore Document snapshot
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: _parseRole(json['role']?.toString()),
      isProvider: json['isProvider'] as bool? ?? false,
      providerCategory: json['providerCategory']?.toString() ?? 'General',
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      googleBusinessUrl: json['googleBusinessUrl']?.toString(),
      reviewCount: json['reviewCount'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      about: json['about']?.toString() ?? '',
      phone: json['phone']?.toString(),
      ratingDistribution: _parseRatingDistribution(json['ratingDistribution']),
    );
  }

  /// Converts the UserModel into a Map for pushing to Firestore
  Map<String, dynamic> toJson() {
    final map = {
      'email': email,
      'name': name,
      'role': role.name,
      'isProvider': isProvider,
      'reviewCount': reviewCount,
      'averageRating': averageRating,
    };

    if (providerCategory != null) map['providerCategory'] = providerCategory!;
    if (hourlyRate != null) map['hourlyRate'] = hourlyRate!;
    if (profileImageUrl != null) map['profileImageUrl'] = profileImageUrl!;
    if (googleBusinessUrl != null) {
      map['googleBusinessUrl'] = googleBusinessUrl!;
    }
    if (about != null) map['about'] = about!;
    if (phone != null) map['phone'] = phone!;
    map['ratingDistribution'] = {
      '1': ratingDistribution[1] ?? 0,
      '2': ratingDistribution[2] ?? 0,
      '3': ratingDistribution[3] ?? 0,
      '4': ratingDistribution[4] ?? 0,
      '5': ratingDistribution[5] ?? 0,
    };

    return map;
  }

  /// Parses the ratingDistribution map from Firestore (String keys → int keys).
  static Map<int, int> _parseRatingDistribution(dynamic raw) {
    if (raw == null || raw is! Map) {
      return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    }
    return {
      1: (raw['1'] as num?)?.toInt() ?? 0,
      2: (raw['2'] as num?)?.toInt() ?? 0,
      3: (raw['3'] as num?)?.toInt() ?? 0,
      4: (raw['4'] as num?)?.toInt() ?? 0,
      5: (raw['5'] as num?)?.toInt() ?? 0,
    };
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr) {
      case 'provider':
        return UserRole.provider;
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }
}
