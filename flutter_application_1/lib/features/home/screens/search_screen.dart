import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../equipment/services/equipment_service.dart' as equip_svc;
import '../models/equipment_model.dart';
import '../widgets/equipment_image.dart';
import 'equipment_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _accentLight = Color(0xFFFFF3E8);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;

  String _searchQuery = '';
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  List<EquipmentModel> get _filteredEquipment {
    final provider = context.read<equip_svc.EquipmentProvider>();
    var items = provider.allEquipment
        .map((fs) => EquipmentModel.fromFirestoreModel(fs))
        .toList();
    final cat = EquipmentModel.categories[_selectedCategoryIndex];
    if (cat != 'All') {
      items = items.where((e) => e.category == cat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      items = items
          .where(
            (e) =>
                e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.provider.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<equip_svc.EquipmentProvider>();
      if (provider.allEquipment.isEmpty) {
        provider.loadAllEquipment();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
    // Watch provider so UI rebuilds when Firestore data loads
    context.watch<equip_svc.EquipmentProvider>();
    final equipment = _filteredEquipment;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildCategoryChips(),
            // Results count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('results'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  Text(
                    '${equipment.length} equipment',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _sub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Grid
            Expanded(
              child: equipment.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: equipment.length,
                      itemBuilder: (context, index) =>
                          _buildEquipmentCard(equipment[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
                tr('browse_equipment'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
            ),
          ),
          Container(
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
              Icons.filter_list_rounded,
              size: 20,
              color: _dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
          cursorColor: _accent,
          decoration: InputDecoration(
<<<<<<< HEAD
            hintText: 'Search equipment, model, provider...',
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 22),
=======
            hintText: tr('search_equipment_placeholder'),
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: _sub),
            prefixIcon: const Icon(Icons.search_rounded, color: _sub, size: 22),
>>>>>>> 30bced0 (Update project files)
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: EquipmentModel.categories.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? _accent : _card,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Text(
                  EquipmentModel.categories[index],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : _sub,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EquipmentDetailsScreen(equipment: equipment),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    color: const Color(0xFFF5F5F5),
                    child: EquipmentImage(
                      imageUrls: equipment.imageUrls,
                      fallbackAsset: equipment.imageAsset,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 110,
                    ),
                  ),
                ),
                // Rating
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          equipment.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _dark,
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
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    equipment.model,
                    style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Price
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '₹${equipment.pricePerHour.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _accent,
                          ),
                        ),
                        TextSpan(
                          text: '/hr',
                          style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Provider mini info
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accentLight,
                        ),
                        child: Center(
                          child: Text(
                            equipment.provider.name[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          equipment.provider.name,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: _sub,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: _sub.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            tr('no_equipment_found'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr('try_different_search'),
            style: GoogleFonts.poppins(fontSize: 13, color: _sub),
          ),
        ],
      ),
    );
  }
}
