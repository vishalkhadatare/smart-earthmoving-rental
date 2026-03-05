import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/favorites_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/screens/create_booking_screen.dart';
import '../../equipment/screens/rc_verification_screen.dart';
import '../models/equipment_model.dart';

class EquipmentDetailsScreen extends StatefulWidget {
  final EquipmentModel equipment;
  const EquipmentDetailsScreen({super.key, required this.equipment});

  @override
  State<EquipmentDetailsScreen> createState() => _EquipmentDetailsScreenState();
}

class _EquipmentDetailsScreenState extends State<EquipmentDetailsScreen> {
  late final EquipmentModel equipment = widget.equipment;
  int _currentPage = 0;

  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _accentLight = Color(0xFFFFF3E8);
  static const Color _dark = Color.fromARGB(255, 190, 241, 185);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildImageSection(),
                    _buildInfoCard(),
                    _buildSpecsSection(),
                    _buildProviderCard(context),
                    _buildDescriptionSection(),
                    _buildReviewsSection(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _dark,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                tr('equipment_details'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Share on WhatsApp with app link
              const appLink = 'https://equippro.app';
              final text = Uri.encodeComponent(
                '${equipment.name} (${equipment.model}) - ₹${equipment.pricePerHour.toStringAsFixed(0)}/hr\n'
                '${equipment.description.isNotEmpty ? "${equipment.description}\n" : ""}'
                'Book now: $appLink',
              );
              launchUrl(
                Uri.parse('https://wa.me/?text=$text'),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.share_outlined, size: 20, color: _dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final hasMultiple = equipment.imageUrls.length > 1;
    return Container(
      width: double.infinity,
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ---- Image carousel / single image ----
          if (equipment.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: PageView.builder(
                itemCount: equipment.imageUrls.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _showZoomedImage(i),
                  child: CachedNetworkImage(
                    imageUrl: equipment.imageUrls[i],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 240,
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accent,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => _assetFallback(),
                  ),
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _assetFallback(),
            ),
          // Page indicator dots
          if (hasMultiple)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  equipment.imageUrls.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? _accent
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          // Availability badge
          if (equipment.isAvailable)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C853).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tr('available_now'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Favorite
          Positioned(
            top: 14,
            right: 14,
            child: GestureDetector(
              onTap: () {
                context.read<FavoritesProvider>().toggleFavorite(equipment.id);
              },
              child: Consumer<FavoritesProvider>(
                builder: (context, favProvider, _) {
                  final isFav = favProvider.isFavorite(equipment.id);
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: isFav ? Colors.redAccent : _dark,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showZoomedImage(int startIndex) {
    showDialog(
      context: context,
      builder: (_) => _ZoomedImageGallery(
        imageUrls: equipment.imageUrls,
        initialIndex: startIndex,
      ),
    );
  }

  Widget _assetFallback() {
    return SizedBox(
      width: double.infinity,
      height: 240,
      child: Image.asset(
        equipment.imageAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.construction_rounded,
            size: 80,
            color: _accent.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      equipment.model,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _sub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  equipment.category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price and rating row
          Row(
            children: [
              // Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₹${equipment.pricePerHour.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '/hr',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: Color(0xFFFFB800),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      equipment.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _dark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${equipment.reviewCount})',
                      style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsSection() {
    final eq = equipment;
    // Check if any spec parameter is filled
    final hasStructuredSpecs =
        eq.company.isNotEmpty ||
        eq.soilType.isNotEmpty ||
        eq.depth.isNotEmpty ||
        eq.enginePower.isNotEmpty ||
        eq.bucketCapacity.isNotEmpty ||
        eq.area.isNotEmpty ||
        eq.operatingWeight.isNotEmpty;

    if (!hasStructuredSpecs && eq.specs.isEmpty) return const SizedBox.shrink();

    // Build spec rows from structured fields
    final specRows = <_SpecRow>[
      if (eq.company.isNotEmpty)
        _SpecRow(Icons.business_outlined, 'Company', eq.company),
      if (eq.soilType.isNotEmpty)
        _SpecRow(Icons.landscape_outlined, 'Soil Type', eq.soilType),
      if (eq.depth.isNotEmpty)
        _SpecRow(Icons.vertical_align_bottom_rounded, 'Depth', eq.depth),
      if (eq.enginePower.isNotEmpty)
        _SpecRow(Icons.bolt_rounded, 'Engine Power', eq.enginePower),
      if (eq.bucketCapacity.isNotEmpty)
        _SpecRow(Icons.water_outlined, 'Bucket Capacity', eq.bucketCapacity),
      if (eq.area.isNotEmpty)
        _SpecRow(Icons.crop_square_rounded, 'Area', eq.area),
      if (eq.operatingWeight.isNotEmpty)
        _SpecRow(Icons.scale_rounded, 'Operating Weight', eq.operatingWeight),
    ];

    // Fallback to generic specs list if no structured specs
    if (specRows.isEmpty) {
      final specIcons = [
        Icons.scale_rounded,
        Icons.speed_rounded,
        Icons.local_gas_station_rounded,
        Icons.straighten_rounded,
      ];
      final specLabels = [tr('weight'), tr('power'), tr('fuel'), tr('reach')];
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('specifications'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(
                eq.specs.length.clamp(0, 4),
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: i < eq.specs.length - 1 ? 10 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          i < specIcons.length
                              ? specIcons[i]
                              : Icons.info_outline,
                          size: 22,
                          color: _accent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          eq.specs[i],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          i < specLabels.length ? specLabels[i] : '',
                          style: GoogleFonts.poppins(fontSize: 10, color: _sub),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20, color: _accent),
              const SizedBox(width: 8),
              Text(
                tr('specifications'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...specRows.map((s) => _buildSpecRow(s)),
        ],
      ),
    );
  }

  Widget _buildSpecRow(_SpecRow s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(s.icon, size: 20, color: _accent),
          const SizedBox(width: 12),
          Text(
            '${s.label}:',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _sub,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s.value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('equipment_provider'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Provider photo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    equipment.provider.name.isNotEmpty
                        ? equipment.provider.name[0].toUpperCase()
                        : 'P',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.provider.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
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
                          equipment.provider.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _dark,
                          ),
                        ),
                        Text(
                          ' ${tr('provider_rating')}',
                          style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: _sub,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            equipment.provider.location,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _sub,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Contact info
          if (equipment.provider.phone.isNotEmpty)
            GestureDetector(
              onTap: () {
                final phone = equipment.provider.phone.replaceAll(
                  RegExp(r'[\s\-]'),
                  '',
                );
                if (phone.isNotEmpty) {
                  launchUrl(Uri.parse('tel:$phone'));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 18, color: _accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.provider.phone,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _accent,
                              decoration: TextDecoration.underline,
                              decorationColor: _accent,
                            ),
                          ),
                          Text(
                            tr('tap_to_call'),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: _sub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tr('call'),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    if (equipment.description.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('about_equipment'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            equipment.description,
            style: GoogleFonts.poppins(fontSize: 13, color: _sub, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Reviews section ─────────────────────────────────────────
  Widget _buildReviewsSection(BuildContext context) {
    final db = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userName = context.read<AuthProvider>().userName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB800),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Write a review card ──────────────────────────────
          if (uid != null)
            _ReviewInputCard(
              equipment: equipment,
              uid: uid,
              userName: userName,
            ),

          const SizedBox(height: 16),

          // ── Live list of reviews ─────────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream: db
                .collection('reviews')
                .where('equipmentId', isEqualTo: equipment.id)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
                  ),
                );
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No reviews yet. Be the first!',
                      style: GoogleFonts.poppins(fontSize: 13, color: _sub),
                    ),
                  ),
                );
              }
              final reviews = docs
                  .map(
                    (d) => _ReviewModel.fromMap(
                      d.id,
                      d.data()! as Map<String, dynamic>,
                    ),
                  )
                  .toList();
              return Column(
                children: reviews.map((r) => _ReviewTile(review: r)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: _card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Chat button
          GestureDetector(
            onTap: () {
              final phone = equipment.provider.phone.replaceAll(
                RegExp(r'[\s\-]'),
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: _accent,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Verify RC button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RCVerificationScreen()),
            ),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: _accent,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Book now button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateBookingScreen(
                        equipmentId: equipment.id,
                        equipmentName: equipment.name,
                        machineType: equipment.category,
                        providerId: equipment.provider.id,
                        providerName: equipment.provider.name,
                        hourlyRate: equipment.pricePerHour,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadowColor: _accent.withValues(alpha: 0.3),
                ),
                child: Text(
                  tr('book_equipment'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper class for spec rows ───────────────────────────────
class _SpecRow {
  final IconData icon;
  final String label;
  final String value;
  const _SpecRow(this.icon, this.label, this.value);
}

// ─── Review model ──────────────────────────────────────────────
class _ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  _ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
  factory _ReviewModel.fromMap(String id, Map<String, dynamic> m) =>
      _ReviewModel(
        id: id,
        userId: m['userId'] as String? ?? '',
        userName: m['userName'] as String? ?? 'User',
        rating: (m['rating'] as num?)?.toDouble() ?? 0,
        comment: m['comment'] as String? ?? '',
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}

// ─── Full-screen zoomable image gallery ───────────────────────
class _ZoomedImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const _ZoomedImageGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_ZoomedImageGallery> createState() => _ZoomedImageGalleryState();
}

class _ZoomedImageGalleryState extends State<_ZoomedImageGallery> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 0.8,
              maxScale: 5.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[i],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          // Page indicator
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _current == i
                          ? const Color(0xFFFF6B00)
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Review input card (write a review) ───────────────────────
class _ReviewInputCard extends StatefulWidget {
  final EquipmentModel equipment;
  final String uid;
  final String userName;
  const _ReviewInputCard({
    required this.equipment,
    required this.uid,
    required this.userName,
  });
  @override
  State<_ReviewInputCard> createState() => _ReviewInputCardState();
}

class _ReviewInputCardState extends State<_ReviewInputCard> {
  int _stars = 0;
  final _ctrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a star rating',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final db = FirebaseFirestore.instance;
      final existing = await db
          .collection('reviews')
          .where('equipmentId', isEqualTo: widget.equipment.id)
          .where('userId', isEqualTo: widget.uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You have already reviewed this equipment.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _submitting = false);
        return;
      }
      await db.collection('reviews').add({
        'equipmentId': widget.equipment.id,
        'equipmentName': widget.equipment.name,
        'providerId': widget.equipment.provider.id,
        'userId': widget.uid,
        'userName': widget.userName,
        'rating': _stars.toDouble(),
        'comment': _ctrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Recalculate avg rating on equipment doc
      final allReviews = await db
          .collection('reviews')
          .where('equipmentId', isEqualTo: widget.equipment.id)
          .get();
      final count = allReviews.docs.length;
      final avg =
          allReviews.docs
              .map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 0)
              .fold(0.0, (a, b) => a + b) /
          count;
      await db.collection('equipment').doc(widget.equipment.id).update({
        'rating': avg,
        'reviewCount': count,
      });
      if (!mounted) return;
      setState(() {
        _stars = 0;
        _ctrl.clear();
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit review.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write a Review',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    i < _stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFB800),
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF8F90A6),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit Review',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single review tile ────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final _ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFFF3E8),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF6B00),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: const Color(0xFFFFB800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF8F90A6),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF555555),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
