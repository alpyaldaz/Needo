import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/domain/usecases/get_top_providers_usecase.dart';
import 'package:needo/features/home/domain/entities/category_entity.dart';
import 'package:needo/features/home/presentation/bloc/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetTopProvidersUseCase getTopProvidersUseCase;

  HomeCubit({required this.getTopProvidersUseCase}) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    try {
      // Static categories (these drive the UI categories grid)
      final categories = [
        const CategoryEntity(
          id: '1',
          name: 'Cleaning',
          icon: Icons.cleaning_services,
          color: Color(0xFFACC8A2),
        ),
        const CategoryEntity(
          id: '2',
          name: 'Repair',
          icon: Icons.build,
          color: Colors.orangeAccent,
        ),
        const CategoryEntity(
          id: '3',
          name: 'Painting',
          icon: Icons.format_paint,
          color: Colors.pinkAccent,
        ),
        const CategoryEntity(
          id: '4',
          name: 'Moving',
          icon: Icons.local_shipping,
          color: Colors.purpleAccent,
        ),
        const CategoryEntity(
          id: '5',
          name: 'Plumbing',
          icon: Icons.plumbing,
          color: Colors.teal,
        ),
        const CategoryEntity(
          id: '6',
          name: 'Electrical',
          icon: Icons.electrical_services,
          color: Colors.amber,
        ),
        const CategoryEntity(
          id: '7',
          name: 'Pest Control',
          icon: Icons.pest_control,
          color: Colors.redAccent,
        ),
        const CategoryEntity(
          id: '8',
          name: 'Gardening',
          icon: Icons.yard,
          color: Colors.green,
        ),
      ];

      // Fetch real providers from Firestore
      final providerResult = await getTopProvidersUseCase();
      final topProviders = providerResult.fold<List<UserEntity>>(
        (_) => [], // On failure, simply show no providers
        (providers) => providers,
      );

      emit(HomeLoaded(categories: categories, topProviders: topProviders));
    } catch (e) {
      emit(const HomeError("Failed to load home data"));
    }
  }
}
