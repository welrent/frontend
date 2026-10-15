import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/account_screen.dart';
import '../screens/act_screen.dart';
import '../screens/auth_screens.dart';
import '../screens/bookings_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/home_screen.dart';
import '../screens/legal_screen.dart';
import '../screens/location_detail_screen.dart';
import '../screens/locations_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/offerlist_screen.dart';
import '../screens/sponsorship_screen.dart';
import '../screens/vehicle_screen.dart';
import '../state/providers.dart';
import '../widgets/app_shell.dart';

Widget _page(Widget child) => ShellPage(child: child);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    errorBuilder: (context, state) =>
        AppShell(child: _page(const NotFoundScreen())),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => _page(const HomeScreen())),
          GoRoute(
            path: '/offerlist',
            builder: (_, _) => _page(const OfferlistScreen()),
          ),
          GoRoute(
            path: '/vehicle/:slug',
            builder: (_, state) =>
                _page(VehicleScreen(slug: state.pathParameters['slug']!)),
          ),
          GoRoute(
            path: '/locations',
            builder: (_, _) => _page(const LocationsScreen()),
          ),
          GoRoute(
            path: '/locations/:city',
            builder: (_, state) => _page(
              LocationDetailScreen(city: state.pathParameters['city']!),
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (_, _) => _page(const LoginScreen()),
          ),
          GoRoute(
            path: '/register',
            builder: (_, _) => _page(const RegisterScreen()),
          ),
          GoRoute(
            path: '/forgot',
            builder: (_, _) => _page(const ForgotScreen()),
          ),
          GoRoute(
            path: '/account',
            builder: (_, _) => _page(const AccountScreen()),
          ),
          GoRoute(
            path: '/bookings',
            builder: (_, _) => _page(const BookingsScreen()),
          ),
          GoRoute(path: '/chat', builder: (_, _) => const ChatScreen()),
          GoRoute(
            path: '/notifications',
            builder: (_, _) => _page(const NotificationsScreen()),
          ),
          GoRoute(path: '/act', builder: (_, _) => _page(const ActScreen())),
          GoRoute(
            path: '/terms',
            builder: (_, _) => _page(const LegalScreen.terms()),
          ),
          GoRoute(
            path: '/privacy',
            builder: (_, _) => _page(const LegalScreen.privacy()),
          ),
          GoRoute(
            path: '/sponsorship/f1/wr/designed',
            builder: (_, _) => const SponsorshipScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
