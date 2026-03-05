import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:equippro/core/services/notifications_service.dart';
import 'package:equippro/features/notifications/notifications_screen.dart';
import 'package:equippro/features/provider/screens/provider_details_screen.dart';
import 'package:equippro/core/widgets/app_logo.dart';
import 'package:equippro/features/home/screens/all_equipments_screen.dart';
import 'package:equippro/core/services/favorites_service.dart';
import 'package:equippro/core/services/stats_service.dart';
import 'package:equippro/features/auth/providers/auth_provider.dart';
import 'package:equippro/features/equipment/services/equipment_service.dart'
    as equip_svc;
import 'package:equippro/features/home/models/equipment_model.dart';
import 'package:equippro/features/home/widgets/equipment_image.dart';
import 'package:equippro/features/home/screens/equipment_details_screen.dart';
import 'package:equippro/features/home/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Brand palette
  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _accentLight = Color(0xFFFFF3E8);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF00C853);

  int _selectedCategoryIndex = 0;
  int _featuredCategoryIndex = 0;
  final PageController _bannerController = PageController(
    viewportFraction: 0.9,
  );
  int _currentBannerPage = 0;

  List<EquipmentModel> get _allEquipmentUI {
    final provider = context.read<equip_svc.EquipmentProvider>();
    return provider.allEquipment
        .map((fs) => EquipmentModel.fromFirestoreModel(fs))
        .toList();
  }

  List<EquipmentModel> get _filteredEquipment {
    final all = _allEquipmentUI;
    final cat = EquipmentModel.categories[_selectedCategoryIndex];
    if (cat == 'All') return all;
    return all.where((e) => e.category == cat).toList();
  }

  List<EquipmentModel> get _filteredFeaturedEquipment {
    final featured = _allEquipmentUI.where((e) => e.rating >= 4.0).toList();
    final cat = EquipmentModel.categories[_featuredCategoryIndex];
    if (cat == 'All') return featured;
    return featured.where((e) => e.category == cat).toList();
  }

  @override
  void initState() {
    super.initState();
    // Load equipment and stats from Firestore only if not already cached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final equipProv = context.read<equip_svc.EquipmentProvider>();
      equipProv.loadAllEquipment();
      final statsProv = context.read<StatsProvider>();
      if (!statsProv.statsLoaded) {
        statsProv.loadPlatformStats();
      }
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
    // Watch provider so UI rebuilds when data loads from Firestore
    context.watch<equip_svc.EquipmentProvider>();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
<<<<<<< HEAD
        child: CustomScrollView(
          slivers: [
            // 1. Header
            SliverToBoxAdapter(child: _buildHeader()),
            // 2. Search bar
            SliverToBoxAdapter(child: _buildSearchBar()),
            // 3. Banner carousel
            SliverToBoxAdapter(child: _buildBannerCarousel()),
            // 4. Quick stats
            SliverToBoxAdapter(child: _buildQuickStats()),
            // 5. Categories
            SliverToBoxAdapter(child: _buildCategoryChips()),
            // 6. Featured equipment with category filters
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Featured Equipment',
                'Top rated',
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllEquipmentsScreen(),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: _buildFeaturedCategoryChips()),
            SliverToBoxAdapter(child: _buildFeaturedEquipment()),
            // 7. Top Providers
            SliverToBoxAdapter(
              child: _buildSectionHeader('Top Providers', 'Trusted'),
            ),
            SliverToBoxAdapter(child: _buildTopProviders()),
            // 8. How it works
            SliverToBoxAdapter(child: _buildHowItWorks()),
            // 9. Recently added (horizontal)
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Recently Added',
                'New',
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllEquipmentsScreen(),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: _buildRecentlyAdded()),
            // 10. Available equipment (vertical feed)
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'All Equipment',
                '${_filteredEquipment.length} found',
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllEquipmentsScreen(),
                    ),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildEquipmentCard(_filteredEquipment[index]),
                  childCount: _filteredEquipment.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
=======
        child: RefreshIndicator(
          color: const Color(0xFFFF6B00),
          onRefresh: () async {
            context.read<equip_svc.EquipmentProvider>().loadAllEquipment();
            context.read<StatsProvider>().loadPlatformStats();
          },
          child: CustomScrollView(
            slivers: [
              // 1. Header
              SliverToBoxAdapter(child: _buildHeader()),
              // 2. Search bar
              SliverToBoxAdapter(child: _buildSearchBar()),
              // 3. Banner carousel
              SliverToBoxAdapter(child: _buildBannerCarousel()),
              // 4. Quick stats
              SliverToBoxAdapter(child: _buildQuickStats()),
              // 5. Categories
              SliverToBoxAdapter(child: _buildCategoryChips()),
              // 6. Featured equipment (horizontal)
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  tr('featured_equipment'),
                  tr('top_rated'),
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildFeaturedEquipment()),
              // 7. Top Providers
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  tr('top_providers'),
                  tr('trusted'),
                  onViewAll: () => _showAllProviders(),
                ),
              ),
              SliverToBoxAdapter(child: _buildTopProviders()),
              // 8. How it works
              SliverToBoxAdapter(child: _buildHowItWorks()),
              // 9. Recently added (horizontal)
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  tr('recently_added'),
                  tr('new_badge'),
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildRecentlyAdded()),
              // 10. Available equipment (vertical feed)
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  tr('all_equipment'),
                  '${_filteredEquipment.length} found',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildEquipmentCard(_filteredEquipment[index]),
                    childCount: _filteredEquipment.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
>>>>>>> 30bced0 (Update project files)
        ),
      ),
    );
  }

  // ─── 1. HEADER ──────────────────────────────────────────────────
  Widget _buildHeader() {
    final authProvider = Provider.of<AuthProvider>(context);
    final name = authProvider.userName;
    final photoUrl = authProvider.userPhotoUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const AppLogo(size: 44),
          const SizedBox(width: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initial(name),
                    )
                  : _initial(name),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('welcome_back'),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _sub,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to favorites (show favorited equipment)
              final favProvider = context.read<FavoritesProvider>();
              final favIds = favProvider.favoriteIds;
              final favEquipment = _allEquipmentUI
                  .where((e) => favIds.contains(e.id))
                  .toList();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.white,
                builder: (_) => _FavoritesSheet(equipment: favEquipment),
              );
            },
            child: _iconButton(Icons.favorite_border_rounded),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Consumer<NotificationsProvider>(
              builder: (_, notif, __) {
                final count = notif.unseenCount;
                return Stack(
                  children: [
                    _iconButton(Icons.notifications_none_rounded),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _card, width: 1.5),
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _initial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _card,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: _dark, size: 22),
    );
  }

  // ─── 2. SEARCH BAR ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search_rounded,
                color: _sub.withValues(alpha: 0.6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr('search_placeholder'),
                  style: GoogleFonts.poppins(fontSize: 14, color: _sub),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 3. BANNER CAROUSEL ─────────────────────────────────────────
  Widget _buildBannerCarousel() {
    final equipCount = _allEquipmentUI.length;
    final providerCount = _allEquipmentUI
        .map((e) => e.provider.id)
        .toSet()
        .length;
    final banners = [
      _BannerData(
        tr('rent_heavy_equipment'),
        equipCount > 0
            ? tr('machines_available').replaceFirst('{}', '$equipCount')
            : tr('browse_book_instantly'),
        tr('trending'),
        const [Color(0xFFFF6B00), Color(0xFFFF9A44)],
        Icons.construction_rounded,
      ),
      _BannerData(
        tr('post_equipment_earn'),
        providerCount > 0
            ? tr('join_equipment_owners').replaceFirst('{}', '$providerCount')
            : tr('start_earning_today'),
        tr('earn_badge'),
        const [Color(0xFF6C63FF), Color(0xFF8B83FF)],
        Icons.monetization_on_rounded,
      ),
      _BannerData(
        tr('verified_operators'),
        tr('skilled_experienced_crew'),
        tr('new_badge'),
        const [Color(0xFF00B894), Color(0xFF55E6C1)],
        Icons.engineering_rounded,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (i) => setState(() => _currentBannerPage = i),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final b = banners[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(6, 18, 6, 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: b.colors,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: b.colors[0].withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -15,
                        top: -15,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Icon(
                          b.icon,
                          size: 56,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                b.badge,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              b.title,
                              style: GoogleFonts.poppins(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b.subtitle,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final active = i == _currentBannerPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? _accent : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── 4. QUICK STATS ────────────────────────────────────────────
  Widget _buildQuickStats() {
    final statsProvider = context.watch<StatsProvider>();
    final ps = statsProvider.platformStats;
    final stats = [
      _StatData(
        Icons.precision_manufacturing_rounded,
        ps.totalEquipment > 0
            ? '${ps.totalEquipment}+'
            : '${_allEquipmentUI.length}+',
        tr('equipment'),
        const Color(0xFFFF6B00),
      ),
      _StatData(
        Icons.people_rounded,
        ps.totalProviders > 0 ? '${ps.totalProviders}+' : '0',
        tr('providers'),
        const Color(0xFF6C63FF),
      ),
      _StatData(
        Icons.location_city_rounded,
        ps.totalCities > 0
            ? '${ps.totalCities}+'
            : '${_allEquipmentUI.map((e) => e.provider.location).toSet().length}',
        tr('cities'),
        const Color(0xFF00B894),
      ),
      _StatData(
        Icons.verified_rounded,
        ps.avgRating > 0
            ? ps.avgRating.toStringAsFixed(1)
            : _allEquipmentUI.isNotEmpty
            ? (_allEquipmentUI.map((e) => e.rating).reduce((a, b) => a + b) /
                      _allEquipmentUI.length)
                  .toStringAsFixed(1)
            : '0.0',
        tr('avg_rating'),
        const Color(0xFFFFB800),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              child: Container(
                margin: EdgeInsets.only(right: s != stats.last ? 10 : 0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(s.icon, size: 20, color: s.color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.value,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _dark,
                      ),
                    ),
                    Text(
                      s.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _sub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ), // GestureDetector
          );
        }).toList(),
      ),
    );
  }

  // ─── 5. CATEGORY CHIPS ──────────────────────────────────────────
  Widget _buildCategoryChips() {
    final categoryIcons = [
      Icons.apps_rounded,
      Icons.precision_manufacturing_rounded,
      Icons.landscape_rounded,
      Icons.front_loader,
      Icons.height_rounded,
      Icons.local_shipping_rounded,
      Icons.radio_button_checked_rounded,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: EquipmentModel.categories.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? _accent : _card,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE8E8E8)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Icon(
                      index < categoryIcons.length
                          ? categoryIcons[index]
                          : Icons.category,
                      size: 18,
                      color: isSelected ? Colors.white : _sub,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      EquipmentModel.categories[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : _dark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedCategoryChips() {
    final categoryIcons = [
      Icons.apps_rounded,
      Icons.precision_manufacturing_rounded,
      Icons.landscape_rounded,
      Icons.front_loader,
      Icons.height_rounded,
      Icons.local_shipping_rounded,
      Icons.radio_button_checked_rounded,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: EquipmentModel.categories.length,
          itemBuilder: (context, index) {
            final isSelected = _featuredCategoryIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _featuredCategoryIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? _accent : _card,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Center(
                  child: Text(
                    EquipmentModel.categories[index],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : _dark,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── 6. FEATURED EQUIPMENT ──────────────────────────────────────
  Widget _buildFeaturedEquipment() {
    final featured = _filteredFeaturedEquipment;

    if (featured.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No featured equipment in this category',
            style: GoogleFonts.poppins(fontSize: 13, color: _sub),
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final e = featured[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EquipmentDetailsScreen(equipment: e),
              ),
            ),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Container(
                          width: 220,
                          height: 130,
                          color: const Color(0xFFF3F3F3),
                          child: EquipmentImage(
                            imageUrls: e.imageUrls,
                            fallbackAsset: e.imageAsset,
                            fit: BoxFit.contain,
                            width: 220,
                            height: 130,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB800),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                e.rating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.model,
                          style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '₹${e.pricePerHour.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _accent,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/hr',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: _sub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _accentLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: _accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── 7. TOP PROVIDERS ──────────────────────────────────────────
  Widget _buildTopProviders() {
    // Simplified top providers row to avoid deep nesting and parsing issues.
    final providerMap = <String, _ProviderDisplayData>{};
    for (final e in _allEquipmentUI) {
      providerMap.putIfAbsent(
        e.provider.id,
        () => _ProviderDisplayData(e.provider, 1, e.imageAsset),
      );
      providerMap[e.provider.id] = _ProviderDisplayData(
        e.provider,
        (providerMap[e.provider.id]?.count ?? 0) + 1,
        providerMap[e.provider.id]?.sampleImage ?? e.imageAsset,
      );
    }

    final providers = providerMap.values.toList();

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final p = providers[index];
<<<<<<< HEAD
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProviderDetailsScreen(provider: p.provider),
                  ),
                );
              },
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade600,
                      radius: 28,
                      child: Text(
                        p.provider.name.isNotEmpty
                            ? p.provider.name[0].toUpperCase()
                            : 'P',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.provider.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.count} ads',
                      style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                    ),
                  ],
                ),
=======
          final colors = [
            [const Color(0xFFFF6B00), const Color(0xFFFF9A44)],
            [const Color(0xFF6C63FF), const Color(0xFF8B83FF)],
            [const Color(0xFF00B894), const Color(0xFF55E6C1)],
            [const Color(0xFFE17055), const Color(0xFFF19066)],
            [const Color(0xFF0984E3), const Color(0xFF74B9FF)],
            [const Color(0xFF6D214F), const Color(0xFFB33771)],
          ];
          final gradientColors = colors[index % colors.length];

          return GestureDetector(
            onTap: () => _showProviderDetail(p),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: gradientColors),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        p.provider.name[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p.provider.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _dark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        p.provider.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                        ),
                      ),
                      Text(
                        ' · ${p.count} ads',
                        style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: _sub,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          p.provider.location.split(',').first,
                          style: GoogleFonts.poppins(fontSize: 10, color: _sub),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
>>>>>>> 30bced0 (Update project files)
              ),
            ),
          );
        
return null;},
      ),
    );
  }

  void _showProviderDetail(_ProviderDisplayData p) {
    final providerEquipment = _allEquipmentUI
        .where((e) => e.provider.id == p.provider.id)
        .toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProviderDetailSheet(
        provider: p.provider,
        equipment: providerEquipment,
        equipmentCount: p.count,
      ),
    );
  }

  void _showAllProviders() {
    final providerMap = <String, _ProviderDisplayData>{};
    for (final e in _allEquipmentUI) {
      if (!providerMap.containsKey(e.provider.id)) {
        providerMap[e.provider.id] = _ProviderDisplayData(
          e.provider,
          1,
          e.imageAsset,
        );
      } else {
        providerMap[e.provider.id] = _ProviderDisplayData(
          e.provider,
          providerMap[e.provider.id]!.count + 1,
          providerMap[e.provider.id]!.sampleImage,
        );
      }
    }
    final providers = providerMap.values.toList()
      ..sort((a, b) => b.provider.rating.compareTo(a.provider.rating));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F7F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      tr('top_providers'),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _dark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${providers.length} providers',
                      style: GoogleFonts.poppins(fontSize: 13, color: _sub),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  itemCount: providers.length,
                  itemBuilder: (_, i) {
                    final pd = providers[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        _showProviderDetail(pd);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: _accent,
                              child: Text(
                                pd.provider.name[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pd.provider.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _dark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Color(0xFFFFB800),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        pd.provider.rating.toStringAsFixed(1),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: _dark,
                                        ),
                                      ),
                                      Text(
                                        ' · ${pd.count} items',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: _sub,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    pd.provider.location.split(',').first,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: _sub,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFBBBBCC),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      _StepData(
        Icons.search_rounded,
        tr('browse'),
        tr('find_equipment_near'),
        const Color(0xFFFF6B00),
      ),
      _StepData(
        Icons.phone_in_talk_rounded,
        tr('contact'),
        tr('call_provider'),
        const Color(0xFF6C63FF),
      ),
      _StepData(
        Icons.handshake_rounded,
        tr('book'),
        tr('confirm_start_work'),
        const Color(0xFF00B894),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_dark, _dark.withValues(alpha: 0.92)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _dark.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  tr('how_it_works'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tr('three_easy_steps'),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(steps.length, (i) {
                final step = steps[i];
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: step.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                step.icon,
                                size: 24,
                                color: step.color,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              step.title,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              step.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.6),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < steps.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 9. RECENTLY ADDED ──────────────────────────────────────────
  Widget _buildRecentlyAdded() {
    final recent = _allEquipmentUI.take(4).toList();

    return SizedBox(
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final e = recent[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EquipmentDetailsScreen(equipment: e),
              ),
            ),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFF3F3F3),
                      child: EquipmentImage(
                        imageUrls: e.imageUrls,
                        fallbackAsset: e.imageAsset,
                        fit: BoxFit.contain,
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tr('new_badge'),
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _green,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          e.model,
                          style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '₹${e.pricePerHour.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _accent,
                              ),
                            ),
                            Text(
                              '/hr',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _sub,
                              ),
                            ),
                            const Spacer(),
                            // Provider mini
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _accentLight,
                              ),
                              child: Center(
                                child: Text(
                                  e.provider.name[0],
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _accent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── SECTION HEADER ─────────────────────────────────────────────
  Widget _buildSectionHeader(
    String title,
    String trailing, {
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
<<<<<<< HEAD
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _accentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trailing,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
              if (onViewAll != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        color: _accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
=======
          onViewAll != null
              ? GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _accentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailing,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ),
>>>>>>> 30bced0 (Update project files)
        ],
      ),
    );
  }

  // ─── 10. EQUIPMENT CARD (Full width) ────────────────────────────
  Widget _buildEquipmentCard(EquipmentModel equipment) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EquipmentDetailsScreen(equipment: equipment),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    color: const Color(0xFFF0F0F0),
                    child: EquipmentImage(
                      imageUrls: equipment.imageUrls,
                      fallbackAsset: equipment.imageAsset,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 180,
                    ),
                  ),
                ),
                if (equipment.isAvailable)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tr('available_badge'),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          equipment.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '₹${equipment.pricePerHour.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: '/hr',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipment.name,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _dark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              equipment.model,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _sub,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _accentLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          equipment.category,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Specs chips
                  if (equipment.specs.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: equipment.specs.map((spec) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: Text(
                            spec,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _dark.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(height: 1, color: const Color(0xFFF0F0F0)),
                  const SizedBox(height: 14),
                  // Provider row
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [_accent, _accent.withValues(alpha: 0.7)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            equipment.provider.name.isNotEmpty
                                ? equipment.provider.name[0].toUpperCase()
                                : 'P',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  equipment.provider.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _dark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: Color(0xFF0984E3),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 12,
                                  color: _sub,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  equipment.provider.phone,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: _sub,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final phone = equipment.provider.phone.replaceAll(
                            RegExp(r'[\\s-]'),
                            '',
                          );
                          if (phone.isNotEmpty) {
                            launchUrl(Uri.parse('tel:$phone'));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  tr('phone_not_available'),
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: _accent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _green.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.phone_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final phone = equipment.provider.phone.replaceAll(
                            RegExp(r'[\\s-]'),
                            '',
                          );
                          if (phone.isNotEmpty) {
                            final message = Uri.encodeComponent(
                              tr('whatsapp_interest_msg').replaceFirst(
                                '{}',
                                '${equipment.name} (${equipment.model})',
                              ),
                            );
                            launchUrl(
                              Uri.parse(
                                'https://wa.me/${phone.replaceAll('+', '')}?text=$message',
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  tr('contact_not_available'),
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: _accent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DATA CLASSES ────────────────────────────────────────────────
class _BannerData {
  final String title, subtitle, badge;
  final List<Color> colors;
  final IconData icon;
  const _BannerData(
    this.title,
    this.subtitle,
    this.badge,
    this.colors,
    this.icon,
  );
}

class _StatData {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatData(this.icon, this.value, this.label, this.color);
}

class _StepData {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _StepData(this.icon, this.title, this.subtitle, this.color);
}

class _ProviderDisplayData {
  final EquipmentProviderInfo provider;
  final int count;
  final String sampleImage;
  const _ProviderDisplayData(this.provider, this.count, this.sampleImage);
}

/// Bottom sheet showing favorited equipment
class _FavoritesSheet extends StatelessWidget {
  final List<EquipmentModel> equipment;
  const _FavoritesSheet({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: Color(0xFFFF6B00)),
                const SizedBox(width: 10),
                Text(
                  tr('my_favorites'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                Text(
                  '${equipment.length} items',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF8F90A6),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: equipment.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr('no_favorites_yet'),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8F90A6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('tap_heart_to_save'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF8F90A6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: equipment.length,
                    itemBuilder: (context, index) {
                      final e = equipment[index];
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EquipmentDetailsScreen(equipment: e),
                            ),
                          );
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: EquipmentImage(
                              imageUrls: e.imageUrls,
                              fallbackAsset: e.imageAsset,
                              fit: BoxFit.contain,
                              width: 56,
                              height: 56,
                            ),
                          ),
                        ),
                        title: Text(
                          e.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '₹${e.pricePerHour.toStringAsFixed(0)}/hr',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFF6B00),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet showing a provider's profile + equipment list
class _ProviderDetailSheet extends StatelessWidget {
  final EquipmentProviderInfo provider;
  final List<EquipmentModel> equipment;
  final int equipmentCount;

  const _ProviderDetailSheet({
    required this.provider,
    required this.equipment,
    required this.equipmentCount,
  });

  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _bg = Color(0xFFF7F7F7);
  static const _card = Colors.white;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Provider header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            provider.name.isNotEmpty
                                ? provider.name[0].toUpperCase()
                                : 'P',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    provider.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _dark,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 18,
                                  color: Color(0xFF0984E3),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFFFB800),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  provider.rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _dark,
                                  ),
                                ),
                                Text(
                                  '  ·  $equipmentCount equipment',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: _sub,
                                  ),
                                ),
                              ],
                            ),
                            if (provider.location.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 13,
                                      color: _sub,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        provider.location,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: _sub,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                  if (provider.phone.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final phone = provider.phone.replaceAll(
                                RegExp(r'[\s-]'),
                                '',
                              );
                              launchUrl(Uri.parse('tel:$phone'));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.phone_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    provider.phone,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Equipment list header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Equipment',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${equipment.length} listings',
                    style: GoogleFonts.poppins(fontSize: 13, color: _sub),
                  ),
                ],
              ),
            ),
            // Equipment list
            Expanded(
              child: equipment.isEmpty
                  ? Center(
                      child: Text(
                        'No equipment listed yet',
                        style: GoogleFonts.poppins(color: _sub),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      itemCount: equipment.length,
                      itemBuilder: (ctx, i) {
                        final e = equipment[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EquipmentDetailsScreen(equipment: e),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: EquipmentImage(
                                      imageUrls: e.imageUrls,
                                      fallbackAsset: e.imageAsset,
                                      fit: BoxFit.contain,
                                      width: 60,
                                      height: 60,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _dark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        e.model,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: _sub,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${e.pricePerHour.toStringAsFixed(0)}/hr',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: e.isAvailable
                                        ? const Color(
                                            0xFF00C853,
                                          ).withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    e.isAvailable ? 'Available' : 'Unavailable',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: e.isAvailable
                                          ? const Color(0xFF00C853)
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
