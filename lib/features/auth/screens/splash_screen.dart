import 'package:flutter/material.dart';
import '../../../core/utils/safe_state.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends SafeState<SplashScreen> {
  static const _accent = Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    // Firebase is already initialized in main(), just check auth fast
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;
    await context.read<AuthProvider>().initialize().timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        // If auth check hangs, go to onboarding
        if (mounted) {
          context.read<AuthProvider>().goToOnboarding();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.precision_manufacturing_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'EquipPro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _accent,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Smart Earthmoving Management',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  backgroundColor: Color(0xFFF5F5F5),
                  valueColor: AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
