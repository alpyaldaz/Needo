import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/features/auth/domain/repositories/auth_repository.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';
import 'package:needo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:needo/features/chat/presentation/bloc/chat_event.dart';
import 'package:needo/features/chat/presentation/bloc/chat_state.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_bloc.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_event.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_state.dart';

class RequestDetailScreen extends StatefulWidget {
  final ServiceRequestEntity request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late ServiceRequestEntity currentRequest;
  bool _isActionLoading = false;

  /// Formats a DateTime to local timezone string.
  String _formatDate(DateTime dt) {
    return DateFormat('MMM dd, yyyy – HH:mm').format(dt.toLocal());
  }

  @override
  void initState() {
    super.initState();
    currentRequest = widget.request;
    context.read<ServiceRequestBloc>().add(
      LoadBidsForRequestEvent(currentRequest.id),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
          'Are you sure you want to cancel this request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ServiceRequestBloc>().add(
                CancelRequestEvent(currentRequest.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: BlocConsumer<ServiceRequestBloc, ServiceRequestState>(
        listenWhen: (previous, current) {
          return current is ServiceRequestCancelled ||
              current is ServiceRequestError ||
              current is BidAcceptedSuccess ||
              current is JobCompletedSuccess ||
              current is ProviderRatedSuccess ||
              current is RequestDetailLoaded ||
              current is ServiceRequestActionLoading;
        },
        listener: (context, state) {
          if (state is ServiceRequestActionLoading) {
            setState(() => _isActionLoading = true);
          } else {
            if (_isActionLoading) {
              setState(() => _isActionLoading = false);
            }
          }

          if (state is ServiceRequestCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is ServiceRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BidAcceptedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is BidDeclinedSuccess) {
            // Added this block
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is JobCompletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProviderRatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is RequestDetailLoaded) {
            setState(() {
              currentRequest = state.request;
            });
          }
        },
        buildWhen: (previous, current) {
          return current is RequestDetailLoaded ||
              current is ServiceRequestError;
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + Status ──
                Text(
                  currentRequest.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(currentRequest.status),
                    const SizedBox(width: 12),
                    Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      currentRequest.categoryId,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),

                // ── Description ──
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  currentRequest.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),

                // ── Details ──
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Scheduled Date',
                  _formatDate(currentRequest.date),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  Icons.monetization_on_outlined,
                  'Budget Range',
                  currentRequest.priceRange,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Payment Method: Direct to Provider (Cash / Transfer)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Status Timeline ──
                const SizedBox(height: 32),
                _buildTimeline(),

                // ── Status-specific sections ──
                if (currentRequest.status == 'Open') ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isActionLoading
                          ? null
                          : () => _showCancelConfirmation(context),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('CANCEL REQUEST'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Received Bids',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildBidsList(),
                ] else if (currentRequest.status == 'In Progress') ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFACC8A2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFACC8A2).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFACC8A2),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'A provider has been assigned to this request.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                              'otherUserName':
                                  'Chat', // Since we don't have the other user's name easily accessible here without fetching, we use a placeholder or could fetch it.
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
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: state is ChatLoading
                              ? null
                              : () {
                                  final authState = context
                                      .read<AuthBloc>()
                                      .state;
                                  if (authState is AuthAuthenticated) {
                                    final currentUserId = authState.user.id;
                                    // Determine the OTHER user ID based on who is logged in
                                    final otherUserId =
                                        currentUserId == currentRequest.userId
                                        ? currentRequest.providerId!
                                        : currentRequest.userId;

                                    context.read<ChatBloc>().add(
                                      CreateRoomEvent(
                                        currentUserId: currentUserId,
                                        otherUserId: otherUserId,
                                      ),
                                    );
                                  }
                                },
                          icon: state is ChatLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.chat_bubble_outline),
                          label: Text(
                            state is ChatLoading
                                ? 'OPENING CHAT...'
                                : 'MESSAGE',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFACC8A2)),
                            foregroundColor: const Color(0xFFACC8A2),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isActionLoading
                          ? null
                          : () => _showRatingDialog(context),
                      icon: _isActionLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isActionLoading ? 'PROCESSING...' : 'COMPLETE JOB',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFACC8A2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ] else if (currentRequest.status == 'Completed') ...[
                  _buildCompletedSection(),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Status Timeline
  // ──────────────────────────────────────────────

  Widget _buildTimeline() {
    final events = <_TimelineEvent>[];

    // Always show creation
    events.add(
      _TimelineEvent(
        icon: Icons.send_rounded,
        label: 'Request Created',
        date: currentRequest.createdAt,
        color: Theme.of(context).primaryColor,
        isCompleted: true,
      ),
    );

    // Accepted
    final isAccepted =
        currentRequest.acceptedAt != null ||
        currentRequest.status == 'In Progress' ||
        currentRequest.status == 'Completed';
    events.add(
      _TimelineEvent(
        icon: Icons.handshake_outlined,
        label: 'Bid Accepted',
        date: currentRequest.acceptedAt,
        color: Colors.orange,
        isCompleted: isAccepted,
      ),
    );

    // Completed
    final isCompleted =
        currentRequest.completedAt != null ||
        currentRequest.status == 'Completed';
    events.add(
      _TimelineEvent(
        icon: Icons.verified_rounded,
        label: 'Job Completed',
        date: currentRequest.completedAt,
        color: Colors.green,
        isCompleted: isCompleted,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Timeline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(events.length, (index) {
            final event = events[index];
            final isLast = index == events.length - 1;
            return _buildTimelineRow(event, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(_TimelineEvent event, bool isLast) {
    final activeColor = event.isCompleted ? event.color : Colors.grey.shade300;
    final textColor = event.isCompleted ? Colors.black87 : Colors.grey.shade400;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: event.isCompleted
                        ? activeColor.withAlpha(26)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: activeColor, width: 2),
                  ),
                  child: Icon(
                    event.isCompleted ? Icons.check : event.icon,
                    size: 12,
                    color: activeColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: activeColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  if (event.date != null)
                    Text(
                      _formatDate(event.date!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    )
                  else if (event.isCompleted)
                    Text(
                      'Date not recorded',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Completed Section with Rating/Review
  // ──────────────────────────────────────────────

  Widget _buildCompletedSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.green.shade700, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Job Completed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              // ── Rating/Review display ──
              if (currentRequest.providerRating != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Your Rating',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < currentRequest.providerRating!
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                ),
                if (currentRequest.providerReview != null &&
                    currentRequest.providerReview!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '"${currentRequest.providerReview!}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 12),
                Text(
                  'No rating provided yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Bids List
  // ──────────────────────────────────────────────

  Widget _buildBidsList() {
    return BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
      buildWhen: (previous, current) {
        return current is ServiceRequestBidsLoading ||
            current is ServiceRequestBidsLoaded ||
            current is ServiceRequestBidsError;
      },
      builder: (context, state) {
        if (state is ServiceRequestBidsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ServiceRequestBidsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading bids',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        } else if (state is ServiceRequestBidsLoaded) {
          final bids = state.bids;
          if (bids.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.hourglass_empty_rounded,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No bids received yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Providers will bid on your request soon. Check back later!',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bids.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bid = bids[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final authRepo = context.read<AuthRepository>();
                              final result = await authRepo.getUserById(
                                bid.providerId,
                              );
                              result.fold(
                                (failure) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Could not load provider profile.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                (user) {
                                  if (context.mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.providerPublicProfile,
                                      arguments: {
                                        'provider': user,
                                        'requestId': currentRequest.id,
                                        'bidId': bid.id,
                                        'bidPrice': bid.amount,
                                      },
                                    );
                                  }
                                },
                              );
                            },
                            child: Text(
                              bid.providerName.trim().isEmpty
                                  ? 'Provider'
                                  : bid.providerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFACC8A2),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            '${bid.amount.toStringAsFixed(2)} PLN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bid.note,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isActionLoading
                                  ? null
                                  : () {
                                      context.read<ServiceRequestBloc>().add(
                                        DeclineBidEvent(
                                          requestId: currentRequest.id,
                                          bidId: bid.id,
                                        ),
                                      );
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('DECLINE'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isActionLoading
                                  ? null
                                  : () {
                                      context.read<ServiceRequestBloc>().add(
                                        AcceptBidEvent(
                                          requestId: currentRequest.id,
                                          bidId: bid.id,
                                          providerId: bid.providerId,
                                          price: bid.amount,
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.green.shade200,
                              ),
                              child: _isActionLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('ACCEPT BID'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFACC8A2), size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'in progress':
        return const Color(0xFFACC8A2);
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showRatingDialog(BuildContext context) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Complete Job & Rate Provider'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How was your experience with this provider?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          rating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Leave a review (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<ServiceRequestBloc>().add(
                    CompleteJobEvent(
                      requestId: currentRequest.id,
                      providerId: currentRequest.providerId,
                      rating: rating,
                      comment: commentController.text,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFACC8A2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('SUBMIT'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Internal helper for timeline events.
class _TimelineEvent {
  final IconData icon;
  final String label;
  final DateTime? date;
  final Color color;
  final bool isCompleted;

  const _TimelineEvent({
    required this.icon,
    required this.label,
    this.date,
    required this.color,
    required this.isCompleted,
  });
}
