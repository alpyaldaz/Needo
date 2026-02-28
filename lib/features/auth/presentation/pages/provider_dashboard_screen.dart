import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_bloc.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_event.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_state.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/config/routes.dart';
import 'package:intl/intl.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch provider jobs immediately upon entering
    _fetchJobs();
  }

  void _fetchJobs() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.isProvider) {
      final categoryId = authState.user.providerCategory;
      if (categoryId != null && categoryId.isNotEmpty) {
        context.read<ServiceRequestBloc>().add(
          FetchOpenRequestsByCategoryEvent(categoryId),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Feed'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchJobs),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text("Please login first"));
          }
          final currentUser = authState.user;

          return BlocConsumer<ServiceRequestBloc, ServiceRequestState>(
            listener: (context, reqState) {
              if (reqState is RequestDetailLoaded ||
                  reqState is JobCompletedSuccess ||
                  reqState is ProviderRatedSuccess ||
                  reqState is BidAcceptedSuccess) {
                _fetchJobs();
              }
            },
            buildWhen: (previous, current) {
              return current is ServiceRequestsLoaded ||
                  current is ServiceRequestLoading ||
                  current is ServiceRequestError;
            },
            builder: (context, reqState) {
              debugPrint("ProviderDashboardScreen State: $reqState");
              if (reqState is ServiceRequestsLoaded) {
                // For testing purposes, allow viewing your own requests
                final availableJobs = reqState.requests.toList();

                if (availableJobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs available for ${currentUser.providerCategory ?? 'your category'} right now.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: availableJobs.length,
                  itemBuilder: (context, index) {
                    final job = availableJobs[index];
                    return _JobCard(job: job, onRefresh: _fetchJobs);
                  },
                );
              } else if (reqState is ServiceRequestError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        reqState.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: _fetchJobs,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final ServiceRequestEntity job;
  final VoidCallback onRefresh;

  const _JobCard({required this.job, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            AppRoutes.providerJobDetail,
            arguments: job,
          );
          if (context.mounted) {
            onRefresh();
          }
        },
        borderRadius: BorderRadius.circular(12),
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
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${job.priceRange}',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: TextStyle(color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(job.date.toLocal()),
                    style: TextStyle(color: Colors.grey.shade600),
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
