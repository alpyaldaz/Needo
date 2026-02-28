import 'package:equatable/equatable.dart';

/// Enum defining the core roles within Needo.
enum UserRole { customer, provider, admin }

/// The core User entity in the Domain layer.
/// This class represents a User without any database-specific logic (e.g. Firebase).
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final bool isProvider;
  final String? providerCategory;
  final double? hourlyRate;

  // New fields for Advanced Provider Profile
  final String? profileImageUrl;
  final String? googleBusinessUrl;
  final int reviewCount;
  final double averageRating;
  final String? about;
  final String? phone;
  final Map<int, int> ratingDistribution;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isProvider = false,
    this.providerCategory,
    this.hourlyRate,
    this.profileImageUrl,
    this.googleBusinessUrl,
    this.reviewCount = 0,
    this.averageRating = 0.0,
    this.about,
    this.phone,
    this.ratingDistribution = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    isProvider,
    providerCategory,
    hourlyRate,
    profileImageUrl,
    googleBusinessUrl,
    reviewCount,
    averageRating,
    about,
    phone,
    ratingDistribution,
  ];
}
