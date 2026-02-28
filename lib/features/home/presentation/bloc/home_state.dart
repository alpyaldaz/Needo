import 'package:equatable/equatable.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/home/domain/entities/category_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryEntity> categories;
  final List<UserEntity> topProviders;

  const HomeLoaded({required this.categories, required this.topProviders});

  @override
  List<Object> get props => [categories, topProviders];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
