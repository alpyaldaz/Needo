import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_bloc.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_event.dart';
import 'package:needo/features/service_requests/presentation/bloc/service_request_state.dart';
import 'package:needo/features/service_requests/presentation/pages/request_detail_screen.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          _loadHistory();
        }
      },
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text("Please login first")),
          );
        }

        final isProvider = authState.user.isProvider;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(isProvider ? 'My Jobs' : 'My Requests'),
              bottom: const TabBar(
                indicatorColor: Color(0xFF135BEC),
                labelColor: Color(0xFF135BEC),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: "Active"),
                  Tab(text: "History"),
                ],
              ),
            ),
            body: BlocConsumer<ServiceRequestBloc, ServiceRequestState>(
              listener: (context, state) {
                if (state is RequestDetailLoaded ||
                    state is JobCompletedSuccess ||
                    state is ProviderRatedSuccess ||
                    state is BidAcceptedSuccess) {
                  _loadHistory();
                }
              },
              buildWhen: (previous, current) {
                return current is ServiceRequestsLoaded ||
                    current is ServiceRequestLoading ||
                    current is ServiceRequestError;
              },
              builder: (context, state) {
                if (state is ServiceRequestsLoaded) {
                  final allReqs = state.requests;
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
                      _buildList(activeReqs, isProvider),
                      _buildList(historyReqs, isProvider),
                    ],
                  );
                } else if (state is ServiceRequestError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadHistory,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<ServiceRequestEntity> requests, bool isProvider) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          isProvider ? "No jobs found." : "No requests found.",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                      builder: (context) =>
                          RequestDetailScreen(request: request),
                    ),
                  );
                }
                if (context.mounted) {
                  _loadHistory();
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
                            color: statusColor.withOpacity(0.1),
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
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(request.date.toLocal()),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.attach_money,
                          size: 14,
                          color: Colors.green,
                        ),
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
        },
      ),
    );
  }
}
