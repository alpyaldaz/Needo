import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';
import 'package:needo/features/auth/domain/usecases/get_top_providers_usecase.dart';
import 'package:needo/features/home/domain/entities/category_entity.dart';
import 'package:needo/features/home/presentation/bloc/home_cubit.dart';
import 'package:needo/features/home/presentation/bloc/home_state.dart';
import 'package:needo/features/home/presentation/bloc/location_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        getTopProvidersUseCase: GetTopProvidersUseCase(
          context.read<AuthRepository>(),
        ),
      )..loadHomeData(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    final locationCubit = context.read<LocationCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final cities = [
          'Warsaw, Poland',
          'Krakow, Poland',
          'Wroclaw, Poland',
          'Poznan, Poland',
          'Gdansk, Poland',
        ];
        return BlocBuilder<LocationCubit, String>(
          bloc: locationCubit,
          builder: (context, currentLocation) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Select Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...cities.map(
                    (city) => ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(city),
                      trailing: currentLocation == city
                          ? const Icon(Icons.check, color: Color(0xFFACC8A2))
                          : null,
                      onTap: () {
                        locationCubit.selectLocation(city);
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeError) {
              return Center(child: Text(state.message));
            } else if (state is HomeLoaded) {
              return CustomScrollView(
                slivers: [
                  // 1. Custom AppBar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _showLocationPicker,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Color(0xFFACC8A2),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.watch<LocationCubit>().state,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Sticky Search Bar
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickySearchBarDelegate(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F6F8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value.trim().toLowerCase();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'What service do you need?',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey.shade500,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 18,
                                            ),
                                            color: Colors.grey.shade500,
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() => _searchQuery = '');
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Categories Grid
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildModernCategoriesGrid(
                            state.categories,
                            context,
                            _searchQuery,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // 4. Top Rated Providers Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Top Rated Providers',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFACC8A2,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Live 🟢',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFACC8A2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Providers Horizontal List
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: state.topProviders.isEmpty
                          ? Center(
                              child: Text(
                                'More providers joining soon! 🌟',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: state.topProviders.length,
                              itemBuilder: (context, index) {
                                return _buildProviderCard(
                                  state.topProviders[index],
                                  context,
                                );
                              },
                            ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildModernCategoriesGrid(
    List<CategoryEntity> categories,
    BuildContext context,
    String searchQuery,
  ) {
    // We override icons and colors here to perfectly match the Stitch design.
    // In a real app, these would come directly from the CategoryEntity or backend.
    final List<Map<String, dynamic>> stitchCategories = [
      {
        'name': 'Cleaning',
        'icon': Icons.cleaning_services,
        'color': const Color(0xFFACC8A2),
        'bg': const Color(0xFFACC8A2).withValues(alpha: 0.15),
      },
      {
        'name': 'Plumbing',
        'icon': Icons.plumbing,
        'color': const Color(0xFFF27B35),
        'bg': const Color(0xFFFEF2E9),
      },
      {
        'name': 'Repair',
        'icon': Icons.build,
        'color': const Color(0xFF9E54D4),
        'bg': const Color(0xFFF5EAFC),
      },
      {
        'name': 'Electrical',
        'icon': Icons.bolt,
        'color': const Color(0xFFF2C94C),
        'bg': const Color(0xFFFEF8E6),
      },
      {
        'name': 'Painting',
        'icon': Icons.format_paint,
        'color': const Color(0xFFEC5588),
        'bg': const Color(0xFFFDEAF0),
      },
      {
        'name': 'Moving',
        'icon': Icons.local_shipping,
        'color': const Color(0xFF23B5D3),
        'bg': const Color(0xFFE5F7FA),
      },
      {
        'name': 'Beauty',
        'icon': Icons.spa,
        'color': const Color(0xFFF06292),
        'bg': const Color(0xFFFCE4EC),
      },
      {
        'name': 'Gardening',
        'icon': Icons.yard,
        'color': const Color(0xFF4CAF50),
        'bg': const Color(0xFFE8F5E9),
      },
    ];

    // Filter based on search query
    final filtered = searchQuery.isEmpty
        ? stitchCategories
        : stitchCategories
              .where(
                (c) => c['name'].toString().toLowerCase().contains(searchQuery),
              )
              .toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No categories match "$searchQuery"',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: List.generate(filtered.length, (index) {
        final cat = filtered[index];
        return GestureDetector(
          onTap: () {
            // Finding matching category ID from the Bloc
            final matchingCategory = categories.firstWhere(
              (c) =>
                  c.name.toLowerCase() == cat['name'].toString().toLowerCase(),
              orElse: () => categories.first,
            );
            Navigator.pushNamed(
              context,
              '/create-request',
              arguments: matchingCategory.name,
            );
          },
          child: SizedBox(
            width:
                (MediaQuery.of(context).size.width - 48 - 16) /
                2, // 2 items per row
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1, // Make it square
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cat['bg'],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(
                          20,
                        ), // Padding inside the white circle
                        decoration: const BoxDecoration(
                          color: Colors.white, // White circle background
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cat['icon'],
                          color: cat['color'],
                          size: 40, // Larger icon size
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProviderCard(UserEntity provider, BuildContext context) {
    final displayName = provider.name.isNotEmpty
        ? provider.name
        : provider.email;
    final initials = () {
      final parts = displayName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    }();

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.providerPublicProfile,
          arguments: provider,
        );
      },
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            provider.profileImageUrl != null &&
                    provider.profileImageUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(provider.profileImageUrl!),
                  )
                : CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFACC8A2),
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
            const SizedBox(height: 10),
            // Name
            Text(
              displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            // Category
            Text(
              provider.providerCategory ?? 'Provider',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                const SizedBox(width: 3),
                Text(
                  provider.averageRating.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchBarDelegate({required this.child});

  @override
  double get minExtent => 74.0;
  @override
  double get maxExtent => 74.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickySearchBarDelegate oldDelegate) {
    return false;
  }
}
