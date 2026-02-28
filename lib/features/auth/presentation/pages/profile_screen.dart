import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_event.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_bloc.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_event.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_state.dart';
import 'package:needo/features/service_requests/presentation/pages/request_detail_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.isProvider) {
        context.read<ServiceRequestBloc>().add(const FetchProviderJobsEvent());
      } else {
        context.read<ServiceRequestBloc>().add(LoadMyRequestsEvent());
      }
    }
  }

  void _showEditAboutDialog(BuildContext context, dynamic user) {
    final controller = TextEditingController(text: user.about ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit About Me'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tell customers about yourself...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  UpdateUserProfileEvent(
                    userId: user.id,
                    about: controller.text.trim(),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: const Color(0xFFF6F6F8),
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    _buildAppBar(context),
                    _buildProfileHeader(user),
                    if (user.isProvider) _buildAboutSection(user),
                    _buildMenuActions(context, user),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          indicatorColor: Color(0xFF135BEC),
                          labelColor: Color(0xFF135BEC),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: "Active"),
                            Tab(text: "History"),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: BlocConsumer<ServiceRequestBloc, ServiceRequestState>(
                  listener: (context, reqState) {
                    if (reqState is RequestDetailLoaded ||
                        reqState is JobCompletedSuccess ||
                        reqState is ProviderRatedSuccess ||
                        reqState is BidAcceptedSuccess) {
                      _loadHistory();
                    }
                  },
                  buildWhen: (previous, current) {
                    return current is ServiceRequestsLoaded ||
                        current is ServiceRequestLoading ||
                        current is ServiceRequestError;
                  },
                  builder: (context, reqState) {
                    if (reqState is ServiceRequestsLoaded) {
                      final allReqs = reqState.requests;
                      final activeReqs = allReqs
                          .where(
                            (r) =>
                                r.status.toLowerCase() != 'completed' &&
                                r.status.toLowerCase() != 'cancelled',
                          )
                          .toList();
                      final historyReqs = allReqs
                          .where(
                            (r) =>
                                r.status.toLowerCase() == 'completed' ||
                                r.status.toLowerCase() == 'cancelled',
                          )
                          .toList();

                      return TabBarView(
                        children: [
                          _buildList(activeReqs, user.isProvider),
                          _buildList(historyReqs, user.isProvider),
                        ],
                      );
                    } else if (reqState is ServiceRequestError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Error: ${reqState.message}"),
                            TextButton(
                              onPressed: _loadHistory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          );
        } else if (authState is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const Scaffold(body: Center(child: Text('Please log in.')));
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
                          backgroundColor: const Color(0xFF135BEC),
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
                        color: Color(0xFF135BEC),
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
                        ? '\$${user.hourlyRate!.toStringAsFixed(0)}/hr'
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'About Me',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                  onPressed: () => _showEditAboutDialog(context, user),
                ),
              ],
            ),
            const SizedBox(height: 4),
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
        child: Column(
          children: [
            Container(
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
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.providerDashboard,
                        );
                        if (context.mounted) _loadHistory();
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
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile Settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit Profile coming soon!'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildListTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.red.shade400,
                    textColor: Colors.red.shade600,
                    onTap: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
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

  Widget _buildList(List<ServiceRequestEntity> requests, bool isProvider) {
    if (requests.isEmpty) {
      return const Center(child: Text("No requests found."));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _HistoryCard(
            request: request,
            isProvider: isProvider,
            onRefresh: _loadHistory,
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ServiceRequestEntity request;
  final bool isProvider;
  final VoidCallback onRefresh;

  const _HistoryCard({
    required this.request,
    required this.isProvider,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (request.status.toLowerCase()) {
      case 'open':
        statusColor = Colors.orange;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (isProvider) {
            await Navigator.pushNamed(
              context,
              AppRoutes.providerJobDetail,
              arguments: request,
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestDetailScreen(request: request),
              ),
            );
          }
          if (context.mounted) {
            onRefresh();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.description,
                style: TextStyle(color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(request.date.toLocal()),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  const Icon(Icons.attach_money, size: 14, color: Colors.green),
                  Text(
                    request.priceRange,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
