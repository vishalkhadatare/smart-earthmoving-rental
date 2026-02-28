import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../providers/auth_provider.dart';

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
  });
}

/// Modern onboarding screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Find Equipment',
      subtitle: 'Instantly',
      description:
          'Browse thousands of construction equipment available for rent in your area.',
      imagePath: 'assets/images/backhoe loader.png',
    ),
    OnboardingPage(
      title: 'Compare Prices',
      subtitle: 'Get Best Deals',
      description:
          'Compare rates from multiple suppliers and choose the best option for your project.',
      imagePath: 'assets/images/wheel loader.png',
    ),
    OnboardingPage(
      title: 'Book & Rent',
      subtitle: 'Hassle-Free',
      description:
          'Book equipment with a single tap and get it delivered to your project site.',
      imagePath: 'assets/images/escavator.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _skipOnboarding();
    }
  }

  void _skipOnboarding() {
    context.read<AuthProvider>().goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF2D1810),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2D1810), Color(0xFF1A0E08)],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                children: [
                  // Top Bar + Skip Button
                  Padding(
                    padding: EdgeInsets.only(
                      top: topInset + 8,
                      right: AppSizes.paddingXLarge,
                      left: AppSizes.paddingXLarge,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 60),
                        const Text(
                          'BuildRent',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        TextButton(
                          onPressed: _skipOnboarding,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: const Size(60, 40),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Page View
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() => _currentPage = page);
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return _buildOnboardingPage(page, index);
                      },
                    ),
                  ),

                  // Bottom Section
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSizes.paddingXLarge,
                      right: AppSizes.paddingXLarge,
                      top: AppSizes.paddingXLarge,
                      bottom: AppSizes.paddingXLarge + bottomInset,
                    ),
                    child: Column(
                      children: [
                        // Page Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => Container(
                              height: 9,
                              width: _currentPage == index ? 24 : 9,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXLarge),

                        // Next Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 4,
                              shadowColor: AppColors.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page, int index) {
    final illustrationPath = switch (index) {
      0 => 'assets/images/ai_onboard_find.svg',
      1 => 'assets/images/ai_onboard_compare.svg',
      _ => 'assets/images/ai_onboard_book.svg',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hero vector illustration
          Container(
            height: 280,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
              color: AppColors.surfaceLight.withValues(alpha: 0.92),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.30),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SvgPicture.asset(illustrationPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 50),

          // Title and Subtitle
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: page.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: '\n${page.subtitle}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
