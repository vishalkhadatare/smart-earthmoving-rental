import 'package:flutter/material.dart';
import '../../../core/utils/safe_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class _OnboardingData {
  final String title;
  final String highlight;
  final String description;
  final String svgPath;

  const _OnboardingData({
    required this.title,
    required this.highlight,
    required this.description,
    required this.svgPath,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends SafeState<OnboardingScreen> {
  static const _accent = Color(0xFFFF6B00);
  static const _accentLight = Color(0xFFFFF3E0);
  static const _textDark = Color(0xFF1A1A1A);
  static const _textSub = Color(0xFF888888);

  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_OnboardingData>[
    _OnboardingData(
      title: 'Find Equipment ',
      highlight: 'Instantly',
      description:
          'Browse thousands of construction machines near you.\nFilter by type, location, and price.',
      svgPath: 'assets/images/onboard_find.svg',
    ),
    _OnboardingData(
      title: 'Compare & ',
      highlight: 'Save Money',
      description:
          'Compare rates from multiple owners.\nTransparent pricing, no hidden charges.',
      svgPath: 'assets/images/onboard_compare.svg',
    ),
    _OnboardingData(
      title: 'Book & Rent ',
      highlight: 'Hassle-Free',
      description:
          'One-tap booking with instant confirmation.\nTrack and manage everything in one place.',
      svgPath: 'assets/images/onboard_book.svg',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<AuthProvider>().goToLogin();
    }
  }

  void _skip() => context.read<AuthProvider>().goToLogin();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    // Logo
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.precision_manufacturing_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'EquipPro',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _accent,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _skip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Page view ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => _buildPage(_pages[index]),
                ),
              ),

              // ── Bottom section ──
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPad),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 8,
                          width: active ? 28 : 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: active ? _accent : const Color(0xFFE0E0E0),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // ── Illustration ──
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _accentLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SvgPicture.asset(page.svgPath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 32),

          // ── Text content ──
          Expanded(
            flex: 3,
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: page.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: page.highlight,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _accent,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textSub,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
