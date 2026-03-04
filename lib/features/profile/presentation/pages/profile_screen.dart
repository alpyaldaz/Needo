import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';
import 'package:needo/features/auth/presentation/bloc/auth_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F6F8),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is! AuthAuthenticated) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F6F8),
            body: Center(child: Text('Please log in')),
          );
        }

        final user = state.user;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F8),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              _buildProfileHeader(user),
              if (user.isProvider) _buildAboutSection(user),
              _buildMenuActions(context, user),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'Profile Settings',
        style: GoogleFonts.inter(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    final displayName = user.name.isNotEmpty ? user.name : user.email;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child:
                      user.profileImageUrl != null &&
                          user.profileImageUrl!.isNotEmpty
                      ? CircleAvatar(
                          radius: 56,
                          backgroundImage: NetworkImage(user.profileImageUrl!),
                        )
                      : CircleAvatar(
                          radius: 56,
                          backgroundColor: const Color(0xFFACC8A2),
                          child: Text(
                            _getInitials(displayName),
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                if (user.isProvider)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Color(0xFFACC8A2),
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (user.isProvider) ...[
              const SizedBox(height: 4),
              Text(
                user.providerCategory ?? 'Service Provider',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    '${user.averageRating.toStringAsFixed(1)} ⭐',
                    'Rating',
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _buildStatColumn('${user.reviewCount}', 'Reviews'),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _buildStatColumn(
                    user.hourlyRate != null
                        ? '${user.hourlyRate!.toStringAsFixed(0)} PLN/hr'
                        : 'N/A',
                    'Rate',
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Customer',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            if (user.isProvider && user.googleBusinessUrl != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.business, color: Colors.black87),
                label: Text(
                  'Google Business Profile',
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildAboutSection(UserEntity user) {
    final aboutText = (user.about != null && user.about!.trim().isNotEmpty)
        ? user.about!
        : 'No description provided.';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              aboutText,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuActions(BuildContext context, UserEntity user) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (user.isProvider) ...[
                _buildListTile(
                  icon: Icons.dashboard_outlined,
                  title: 'Provider Dashboard',
                  iconColor: Colors.green,
                  textColor: Colors.green.shade700,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.providerDashboard);
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Icons.person_pin_outlined,
                  title: 'View My Public Profile',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.providerPublicProfile,
                      arguments: {'provider': user},
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
              ],
              _buildListTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editProfile,
                    arguments: user,
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              if (!user.isProvider) ...[
                _buildListTile(
                  icon: Icons.business_center_outlined,
                  title: 'Become a Service Provider',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.providerRegistration,
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
              ],
              _buildListTile(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: Colors.red.shade400,
                textColor: Colors.red.shade600,
                onTap: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: onTap,
    );
  }
}
