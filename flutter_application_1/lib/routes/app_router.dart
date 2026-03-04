// EquipPro – GoRouter navigation configuration.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/auth_router.dart';

/// Named route paths.
abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const equipmentDetail = '/equipment/:id';
  static const addEquipment = '/equipment/add';
  static const bookings = '/bookings';
  static const profile = '/profile';
}

/// GoRouter provider.
/// The initial route uses the legacy AuthRouter widget which handles
/// splash → onboarding → login → signup → home transitions via
/// the old Provider-based AuthProvider state machine.
/// Individual GoRouter routes will be wired as screens are migrated to Riverpod.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const AuthRouter(),
      ),
    ],
  );
});
