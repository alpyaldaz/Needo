import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';
import 'package:needo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:needo/features/chat/presentation/bloc/chat_event.dart';
import 'package:needo/features/chat/presentation/bloc/chat_state.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_bloc.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_event.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_state.dart';

class ProviderPublicProfileScreen extends StatefulWidget {
  final UserEntity provider;
  final String? requestId;
  final String? bidId;
  final double? bidPrice;

  const ProviderPublicProfileScreen({
    super.key,
    required this.provider,
    this.requestId,
    this.bidId,
    this.bidPrice,
  });

  @override
  State<ProviderPublicProfileScreen> createState() =>
      _ProviderPublicProfileScreenState();
}

class _ProviderPublicProfileScreenState
    extends State<ProviderPublicProfileScreen> {
  /// Whether this screen has bid context (navigated from a bid card).
  bool get hasBidContext => widget.requestId != null && widget.bidId != null;

  @override
  void initState() {
    super.initState();
    // Fetch the list of ReviewEntity for this provider when screen loads.
    context.read<ServiceRequestBloc>().add(
      LoadProviderReviewsEvent(widget.provider.id),
    );
  }

  /// Returns initials from the provider's name (e.g., "Alex Johnson" -> "AJ")
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              _buildProfileHeader(),
              _buildAboutSection(),
              _buildReviewsSection(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Space for bottom CTA
              ),
            ],
          ),
          _buildStickyFooter(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Profile Details',
        style: GoogleFonts.inter(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatRoomIdLoaded) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.chat,
                  arguments: {
                    'roomId': state.roomId,
                    'currentUserId': authState.user.id,
                    'otherUserName': widget.provider.name.isNotEmpty
                        ? widget.provider.name
                        : widget.provider.email,
                  },
                );
              }
            } else if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final authState = context.read<AuthBloc>().state;
            final isCurrentUser =
                authState is AuthAuthenticated &&
                authState.user.id == widget.provider.id;

            // Don't show message button if it's their own profile
            if (isCurrentUser) return const SizedBox.shrink();

            return IconButton(
              icon: state is ChatLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.message_outlined, color: Colors.black87),
              onPressed: state is ChatLoading
                  ? null
                  : () {
                      if (authState is AuthAuthenticated) {
                        context.read<ChatBloc>().add(
                          CreateRoomEvent(
                            currentUserId: authState.user.id,
                            otherUserId: widget.provider.id,
                          ),
                        );
                      }
                    },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final provider = widget.provider;
    final displayName = provider.name.isNotEmpty
        ? provider.name
        : provider.email;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar with verified badge
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
                      provider.profileImageUrl != null &&
                          provider.profileImageUrl!.isNotEmpty
                      ? CircleAvatar(
                          radius: 56,
                          backgroundImage: NetworkImage(
                            provider.profileImageUrl!,
                          ),
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
            const SizedBox(height: 4),
            Text(
              provider.providerCategory ?? 'Service Provider',
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
                  '${provider.averageRating.toStringAsFixed(1)} ⭐',
                  'Rating',
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildStatColumn('${provider.reviewCount}', 'Reviews'),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildStatColumn(
                  provider.hourlyRate != null
                      ? '${provider.hourlyRate!.toStringAsFixed(0)} PLN/hr'
                      : 'N/A',
                  'Rate',
                  subtitle: 'Paid directly',
                ),
              ],
            ),
            if (provider.googleBusinessUrl != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  // Launch URL logic here later
                },
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

  Widget _buildStatColumn(String value, String label, {String? subtitle}) {
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
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAboutSection() {
    final provider = widget.provider;
    final aboutText =
        (provider.about != null && provider.about!.trim().isNotEmpty)
        ? provider.about!
        : 'No description provided.';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final provider = widget.provider;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviews',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Rating Summary Card — uses real data
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Score
                  Column(
                    children: [
                      Text(
                        provider.averageRating.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          if (provider.averageRating >= starValue) {
                            return const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            );
                          } else if (provider.averageRating >=
                              starValue - 0.5) {
                            return const Icon(
                              Icons.star_half,
                              color: Colors.amber,
                              size: 16,
                            );
                          } else {
                            return const Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.reviewCount} ratings',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Rating distribution bars — uses real data
                  Expanded(
                    child: provider.reviewCount == 0
                        ? Center(
                            child: Text(
                              'No reviews yet',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          )
                        : Column(
                            children: List.generate(5, (index) {
                              final star = 5 - index;
                              final count =
                                  provider.ratingDistribution[star] ?? 0;
                              final percent = provider.reviewCount > 0
                                  ? count / provider.reviewCount
                                  : 0.0;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index < 4 ? 4 : 0,
                                ),
                                child: _buildRatingBar(star, percent),
                              );
                            }),
                          ),
                  ),
                ],
              ),
            ),
            if (provider.reviewCount > 0) ...[
              const SizedBox(height: 24),
              // Reviews List using BLoC state
              BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
                builder: (context, state) {
                  if (state is ProviderReviewsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProviderReviewsLoaded) {
                    final reviews = state.reviews;
                    if (reviews.isEmpty) {
                      return Center(
                        child: Text(
                          "No written reviews yet.",
                          style: GoogleFonts.inter(color: Colors.grey.shade500),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 32),
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                review.customerAvatarUrl != null &&
                                        review.customerAvatarUrl!.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          review.customerAvatarUrl!,
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Colors.blueGrey.shade100,
                                        child: Text(
                                          _getInitials(review.customerName),
                                          style: GoogleFonts.inter(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.customerName,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMd().format(
                                          review.timestamp.toLocal(),
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Star row
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            if (review.comment.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  review.comment,
                                  style: GoogleFonts.inter(
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            if (review.photos.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: SizedBox(
                                  height: 80,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: review.photos.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          review.photos[index],
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  } else if (state is ProviderReviewsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int star, double percent) {
    return Row(
      children: [
        Text(
          '$star',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    // Only show footer when there is bid context
    if (!hasBidContext) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BID PRICE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${widget.bidPrice?.toStringAsFixed(2) ?? '--'} PLN',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ServiceRequestBloc>().add(
                      AcceptBidEvent(
                        requestId: widget.requestId!,
                        bidId: widget.bidId!,
                        providerId: widget.provider.id,
                        price: widget.bidPrice ?? 0,
                      ),
                    );
                    // Pop back to RequestDetailScreen — its listener
                    // handles BidAcceptedSuccess (snackbar + final pop)
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Accept Bid',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
