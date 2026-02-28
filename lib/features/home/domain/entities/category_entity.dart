import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final IconData icon; // Using IconData for dummy data setup
  final Color color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  List<Object> get props => [id, name, icon, color];
}

class ServiceProviderEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviews;
  final String profileImageUrl; // Using empty string for dummy data

  const ServiceProviderEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.profileImageUrl,
  });

  @override
  List<Object> get props => [
    id,
    name,
    category,
    rating,
    reviews,
    profileImageUrl,
  ];
}
