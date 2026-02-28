import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../../roles/screens/role_shell_screen.dart';

/// Router that handles navigation between auth states
class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.state) {
          case AuthState.splash:
            return const SplashScreen();
          case AuthState.onboarding:
            return const OnboardingScreen();
          case AuthState.login:
            return const LoginScreen();
          case AuthState.signup:
            return const SignupScreen();
          case AuthState.authenticated:
            return const RoleShellScreen();
        }
      },
    );
  }
}
