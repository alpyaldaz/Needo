import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';
import 'package:needo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:needo/features/chat/presentation/bloc/chat_event.dart';
import 'package:needo/features/chat/presentation/bloc/chat_state.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_bloc.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_event.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_state.dart';

class ProviderJobDetailScreen extends StatefulWidget {
  final ServiceRequestEntity job;

  const ProviderJobDetailScreen({super.key, required this.job});

  @override
  State<ProviderJobDetailScreen> createState() =>
      _ProviderJobDetailScreenState();
}

class _ProviderJobDetailScreenState extends State<ProviderJobDetailScreen> {
  void _showBidDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _PlaceBidDialog(requestId: widget.job.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: BlocListener<ServiceRequestBloc, ServiceRequestState>(
        listener: (context, state) {
          if (state is BidPlacedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Go back to dashboard on success
          } else if (state is ServiceRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.job.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Budget: \$${widget.job.priceRange}',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 11,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Direct to Provider',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.job.status,
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.job.address.isNotEmpty
                              ? widget.job.address
                              : 'No address provided',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Preferred Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: Colors.blue.shade400,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scheduled Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(widget.job.date),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.job.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              if (widget.job.status == 'Completed') ...[
                Container(
                  padding: const EdgeInsets.all(16),
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
                          Icon(
                            Icons.verified,
                            color: Colors.green.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Job Completed Successfully',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      if (widget.job.providerRating != null) ...[
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          'Your Rating',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < widget.job.providerRating!
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 28,
                            ),
                          ),
                        ),
                        if (widget.job.providerReview != null &&
                            widget.job.providerReview!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              '"${widget.job.providerReview!}"',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
              if (widget.job.status == 'In Progress') ...[
                const SizedBox(height: 24),
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
                            'otherUserName': 'Customer',
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
                                  context.read<ChatBloc>().add(
                                    CreateRoomEvent(
                                      currentUserId: authState.user.id,
                                      otherUserId: widget
                                          .job
                                          .userId, // This is the Customer ID
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
                              : 'MESSAGE CUSTOMER',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.blue.shade700),
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.job.status == 'Open'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _showBidDialog(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Place Bid',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _PlaceBidDialog extends StatefulWidget {
  final String requestId;

  const _PlaceBidDialog({required this.requestId});

  @override
  State<_PlaceBidDialog> createState() => _PlaceBidDialogState();
}

class _PlaceBidDialogState extends State<_PlaceBidDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitBid() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      context.read<ServiceRequestBloc>().add(
        PlaceBidEvent(
          requestId: widget.requestId,
          price: amount,
          note: _noteController.text,
        ),
      );
      Navigator.pop(context); // Close the dialog immediately
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Place a Bid'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Bid Amount (\$)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note to Customer',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submitBid, child: const Text('Submit Bid')),
      ],
    );
  }
}
