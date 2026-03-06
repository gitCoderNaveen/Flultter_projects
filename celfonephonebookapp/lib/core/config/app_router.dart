import 'package:celfonephonebookapp/features/admin/ui/admin_dashboard_page.dart';
import 'package:celfonephonebookapp/features/analytics/search_logs_page.dart';
import 'package:celfonephonebookapp/features/analytics/user_sessions_page.dart';
import 'package:celfonephonebookapp/features/combo_offer/view/combo_offer_page.dart';
import 'package:celfonephonebookapp/features/favorites/view/favorite_page.dart';
import 'package:celfonephonebookapp/features/model/ui/business_model_page.dart';
import 'package:celfonephonebookapp/features/model/ui/free_model.dart';
import 'package:celfonephonebookapp/features/model/ui/model_page.dart';
import 'package:celfonephonebookapp/features/partner/features/earning_details/ui/earning_details_page.dart';
import 'package:celfonephonebookapp/features/partner/features/media_partner/ui/media_partner_page.dart';
import 'package:celfonephonebookapp/features/partner/ui/partner_page.dart';
import 'package:celfonephonebookapp/features/profile/ui/profile_page.dart';
import 'package:celfonephonebookapp/features/profile/ui/profile_screen.dart';
import 'package:celfonephonebookapp/features/promotions/features/categorywisepromotions/ui/categorywise_pro_page.dart';
import 'package:celfonephonebookapp/features/promotions/features/nearbypromotions/ui/nearbypromotion_page.dart';
import 'package:celfonephonebookapp/features/promotions/ui/promotion_page.dart';
import 'package:celfonephonebookapp/features/reverse_number_finder/view/reverse_number_finder_page.dart';
import 'package:celfonephonebookapp/features/subscription/ui/subscription_dashboard.dart';
import 'package:celfonephonebookapp/features/subscription/ui/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:celfonephonebookapp/core/config/app_storage.dart';
import 'package:celfonephonebookapp/features/auth/ui/forgot_password_page.dart';
import 'package:celfonephonebookapp/features/auth/ui/signup_page.dart';
import 'package:celfonephonebookapp/features/auth/ui/verify_email_page.dart';
import 'package:celfonephonebookapp/features/home/ui/home_shell.dart';
import 'package:celfonephonebookapp/features/menu/ui/menu_page.dart';
import 'package:celfonephonebookapp/features/onboarding/ui/onboarding_screen.dart';
import 'package:celfonephonebookapp/features/profile/ui/profile_completion_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:celfonephonebookapp/core/enums/user_type.dart';
import '../../features/home/ui/home_page.dart';
import '../../features/search/ui/search_page.dart';
import '../../features/ads/ui/ad_details_page.dart';
import '../../features/auth/ui/login_page.dart';
import '../services/auth_service.dart';
import '../utils/go_router_refresh_stream.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',

    refreshListenable: GoRouterRefreshStream(AuthService.onAuthChange),

    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;
      final location = state.uri.path;

      // 1️⃣ Onboarding check
      final onboardingDone = await AppStorage.isOnboardingCompleted();

      if (!onboardingDone && location != '/onboarding') {
        return '/onboarding';
      }

      // 2️⃣ Public routes (guest allowed)
      final isPublicRoute =
          location == '/home' ||
          location == '/search' ||
          location == '/promotions' ||
          location == '/partner' ||
          location == '/menu' ||
          location == '/onboarding';

      final isAuthRoute =
          location == '/login' ||
          location == '/signup' ||
          location == '/forgot-password';

      // final isVerifyRoute = location == '/verify-email';

      // 3️⃣ Guest user (not logged in)
      if (user == null) {
        // allow guest browsing
        if (isPublicRoute || isAuthRoute) return null;

        // block protected routes
        return '/login';
      }

      // 4️⃣ Logged in but email not verified
      // if (user.emailConfirmedAt == null) {
      //   return isVerifyRoute ? null : '/verify-email';
      // }

      // 5️⃣ Logged in & verified → block auth pages
      // if (isAuthRoute) {
      //   return '/home';
      // }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _slidePage(const LoginPage()),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _slidePage(const HomePage()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => _slidePage(SearchPage()),
          ),
          GoRoute(
            path: '/promotions',
            pageBuilder: (context, state) => _slidePage(PromotionsPage()),
          ),
          GoRoute(
            path: '/partner',
            pageBuilder: (context, state) => _slidePage(PartnerPage()),
          ),
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) => _slidePage(MenuPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(const ProfileScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(const SearchPage()),
          ),
          GoRoute(
            path: '/media-partner',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(const MediaPartnerPage()),
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(const FavoritePage()),
          ),
          GoRoute(
            path: '/nearby-promotion',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(const NearbyPromotionPage()),
          ),
          GoRoute(
            path: '/category-promotion',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(const CategorywiseProPage()),
          ),
          GoRoute(
            path: '/model_page',
            builder: (context, state) {
              final profileId = state.extra as String;

              return ModelPage(profileId: profileId); // ← works now
            },
          ),
          GoRoute(
            path: '/business_model',
            builder: (context, state) {
              final profileId = state.extra as String;

              return BusinessModel(profileId: profileId); // ← works now
            },
          ),
          GoRoute(
            path: '/free_model',
            builder: (context, state) {
              final profileId = state.extra as String;

              return FreeModel(profileId: profileId); // ← works now
            },
          ),
          GoRoute(
            path: '/subscription',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(SubscriptionDashboard()),
          ),
          GoRoute(
            path: '/user_sessions',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(UserSessionsPage()),
          ),
          GoRoute(
            path: '/search_logs',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(SearchLogsPage()),
          ),
          GoRoute(
            path: '/earning_page',
            builder: (context, state) => const EarningDetailsPage(),
          ),
          GoRoute(
            path: '/reverse_number_finder',
            pageBuilder: (context, state) =>
                _slidePage(const ReverseNumberFinderPage()),
          ),
          GoRoute(
            path: '/combo_offers',
            pageBuilder: (context, state) =>
                AppRouter._slidePage(ComboOfferPage()),
          ),
        ],
      ),

      GoRoute(
        path: '/ad/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slidePage(AdDetailsPage(adId: id));
        },
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            AppRouter._slidePage(const SignupPage()),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) => _slidePage(const VerifyEmailPage()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _slidePage(ForgotPasswordPage()),
      ),
      GoRoute(
        path: '/complete-profile',
        pageBuilder: (context, state) {
          // 🔑 Read UserType from extra
          final userType = state.extra as UserType;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ProfileCompletionPage(userType: userType),
            transitionsBuilder: (context, animation, secondary, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _slidePage(const OnboardingScreen()),
      ),
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (context, state) {
          return AppRouter._slidePage(const AdminDashboardPage());
        },
      ),
    ],
  );

  static CustomTransitionPage _slidePage(Widget child) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, _, child) {
        final tween = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
