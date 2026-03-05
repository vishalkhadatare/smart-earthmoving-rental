import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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
      statusBarColor: Color.fromARGB(0, 114, 144, 122),
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
<<<<<<< HEAD
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
          legacy.ChangeNotifierProvider<NotificationsProvider>(
            create: (_) => NotificationsProvider(),
          ),
        ],
        child: const EquipProApp(),
=======
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('mr'), // Marathi
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: ProviderScope(
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
>>>>>>> 30bced0 (Update project files)
      ),
    ),
  );
}

class EquipProApp extends ConsumerWidget {
  const EquipProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EquipRent',
      theme: AppTheme.lightTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
