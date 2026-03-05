import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as legacy;
import 'core/services/favorites_service.dart';
import 'core/services/stats_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/booking/services/booking_service.dart';
import 'features/equipment/services/equipment_service.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase BEFORE first frame so splash is instant
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (_) {}

  // Allow google_fonts to fetch on first launch (cached afterwards)
  GoogleFonts.config.allowRuntimeFetching = true;

  // Edge-to-edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );

  final authProvider = AuthProvider();

  runApp(
    ProviderScope(
      child: legacy.MultiProvider(
        providers: [
          legacy.ChangeNotifierProvider<AuthProvider>.value(
            value: authProvider,
          ),
          legacy.ChangeNotifierProvider<EquipmentProvider>(
            create: (_) => EquipmentProvider(),
          ),
          legacy.ChangeNotifierProvider<BookingProvider>(
            create: (_) => BookingProvider(),
          ),
          legacy.ChangeNotifierProvider<FavoritesProvider>(
            create: (_) => FavoritesProvider(),
          ),
          legacy.ChangeNotifierProvider<StatsProvider>(
            create: (_) => StatsProvider(),
          ),
        ],
        child: const EquipProApp(),
      ),
    ),
  );
}

class EquipProApp extends ConsumerWidget {  const EquipProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EquipPro',
      theme: AppTheme.lightTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
