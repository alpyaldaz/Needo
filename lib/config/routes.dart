import 'package:flutter/material.dart';
import 'package:needo/features/auth/presentation/pages/login_screen.dart';
import 'package:needo/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:needo/features/auth/presentation/pages/provider_registration_screen.dart';
import 'package:needo/features/auth/presentation/pages/provider_dashboard_screen.dart';
import 'package:needo/features/home/presentation/pages/main_layout.dart';
import 'package:needo/features/service_requests/presentation/pages/requests_screen.dart';
import 'package:needo/features/service_requests/presentation/pages/create_request_screen.dart';
import 'package:needo/features/service_requests/presentation/pages/provider_job_detail_screen.dart';
import 'package:needo/features/service_requests/domain/entities/service_request_entity.dart';
import 'package:needo/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:needo/features/profile/presentation/pages/provider_public_profile_screen.dart';
import 'package:needo/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:needo/features/auth/domain/entities/user_entity.dart';
import 'package:needo/features/chat/presentation/pages/chat_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerDashboard = '/customer-dashboard';
  static const String createRequest = '/create-request';
  static const String providerRegistration = '/provider-registration';
  static const String providerDashboard = '/provider-dashboard';
  static const String providerJobDetail = '/provider-job-detail';
  static const String providerPublicProfile = '/provider-profile';
  static const String chat = '/chat';
  static const String editProfile = '/edit-profile';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
    onboarding: (context) => const OnboardingScreen(),
    home: (context) => const MainLayout(),
    login: (context) => const LoginScreen(),
    register: (context) => const SignUpScreen(),
    customerDashboard: (context) => const RequestsScreen(),
    providerRegistration: (context) => const ProviderRegistrationScreen(),
    providerDashboard: (context) => const ProviderDashboardScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == createRequest) {
      final categoryId = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (context) =>
            CreateServiceRequestScreen(categoryId: categoryId ?? 'unknown'),
      );
    }

    if (settings.name == providerJobDetail) {
      final job = settings.arguments as ServiceRequestEntity;
      return MaterialPageRoute(
        builder: (context) => ProviderJobDetailScreen(job: job),
      );
    }

    if (settings.name == providerPublicProfile) {
      final args = settings.arguments;
      if (args is UserEntity) {
        // Direct navigation without bid context
        return MaterialPageRoute(
          builder: (context) => ProviderPublicProfileScreen(provider: args),
        );
      } else if (args is Map<String, dynamic>) {
        // Navigation with bid context
        final provider = args['provider'] as UserEntity;
        return MaterialPageRoute(
          builder: (context) => ProviderPublicProfileScreen(
            provider: provider,
            requestId: args['requestId'] as String?,
            bidId: args['bidId'] as String?,
            bidPrice: args['bidPrice'] as double?,
          ),
        );
      }
    }

    if (settings.name == chat) {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ChatScreen(
          roomId: args['roomId'] as String,
          currentUserId: args['currentUserId'] as String,
          otherUserName: args['otherUserName'] as String,
        ),
      );
    }

    if (settings.name == editProfile) {
      final user = settings.arguments as UserEntity;
      return MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: user),
      );
    }

    // Fallback for unknown routes
    return MaterialPageRoute(
      builder: (context) =>
          const Scaffold(body: Center(child: Text("Route not found"))),
    );
  }
}
