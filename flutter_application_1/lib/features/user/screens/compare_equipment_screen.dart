import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../equipment/services/equipment_service.dart' as equip_svc;
import '../../home/models/equipment_model.dart';

// ─────────────────────────────────────────────────────────────
// Compare Equipment Screen
// ─────────────────────────────────────────────────────────────

enum SortBy { price, rating, none }

class CompareEquipmentScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const CompareEquipmentScreen({super.key, this.onBackPressed});

  @override
  State<CompareEquipmentScreen> createState() => _CompareEquipmentScreenState();
}

class _CompareEquipmentScreenState extends State<CompareEquipmentScreen>
    with SingleTickerProviderStateMixin {
  final List<EquipmentModel> _selectedItems = [];
  SortBy _sortBy = SortBy.none;
  late AnimationController _animCtrl;

  // Brand palette
  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;
  static const Color _red = Color(0xFFEF4444);

  List<EquipmentModel> get _allEquipment {
    final provider = context.read<equip_svc.EquipmentProvider>();
    return provider.allEquipment
        .where((fs) => fs.availabilityStatus)
        .map((fs) => EquipmentModel.fromFirestoreModel(fs))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<equip_svc.EquipmentProvider>().loadAllEquipment();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    final provider = context.read<equip_svc.EquipmentProvider>();
    if (provider.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading equipment, please wait...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _SelectEquipmentSheet(_allEquipment, _selectedItems, (item) {
            setState(() {
              if (!_selectedItems.contains(item)) {
                _selectedItems.add(item);
                _animCtrl.forward().then((_) => _animCtrl.reset());
              }
            });
            Navigator.pop(context);
          }),
    );
  }

  void _removeItem(EquipmentModel item) {
    setState(() => _selectedItems.remove(item));
  }

  void _clearAll() {
    setState(() => _selectedItems.clear());
  }

  void _sortItems() {
    setState(() {
      if (_sortBy == SortBy.price) {
        _selectedItems.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
      } else if (_sortBy == SortBy.rating) {
        _selectedItems.sort((a, b) => b.rating.compareTo(a.rating));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (_selectedItems.isNotEmpty)
              SliverToBoxAdapter(child: _buildSortAndClear()),
            if (_selectedItems.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverToBoxAdapter(child: _buildComparisonTable()),
            if (_selectedItems.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: _accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBackPressed ?? () => Navigator.pop(context),
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
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Compare Equipment',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select up to 5 items to compare side by side',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _sub,
            ),
          ),
          if (_selectedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${_selectedItems.length} item${_selectedItems.length > 1 ? 's' : ''} selected',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _accent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.compare_arrows_rounded,
                size: 50,
                color: _accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Items Selected',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to select equipment for comparison',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _sub,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortAndClear() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: PopupMenuButton<SortBy>(
                onSelected: (value) => setState(() {
                  _sortBy = value;
                  _sortItems();
                }),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: SortBy.price,
                    child: Text('Sort by Price'),
                  ),
                  const PopupMenuItem(
                    value: SortBy.rating,
                    child: Text('Sort by Rating'),
                  ),
                  const PopupMenuItem(
                    value: SortBy.none,
                    child: Text('No Sort'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _sortBy == SortBy.price
                            ? 'Price'
                            : _sortBy == SortBy.rating
                            ? 'Rating'
                            : 'Sort',
                        style: GoogleFonts.poppins(fontSize: 13, color: _dark),
                      ),
                      const Icon(Icons.unfold_more, size: 18, color: _sub),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _clearAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _red, width: 1.5),
              ),
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Comparison Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _dark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Table + Insights',
                    style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                child: Row(
                  children: List.generate(
                    _selectedItems.length,
                    (i) => _ComparisonCard(
                      item: _selectedItems[i],
                      onRemove: () => _removeItem(_selectedItems[i]),
                      isBestPrice:
                          i ==
                          _selectedItems.indexWhere(
                            (e) =>
                                e.pricePerHour ==
                                _selectedItems
                                    .map((x) => x.pricePerHour)
                                    .reduce((a, b) => a < b ? a : b),
                          ),
                      isBestRating:
                          i ==
                          _selectedItems.indexWhere(
                            (e) =>
                                e.rating ==
                                _selectedItems
                                    .map((x) => x.rating)
                                    .reduce((a, b) => a > b ? a : b),
                          ),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            _ComparisonMetricsTable(items: _selectedItems),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFEDEDED)),
            _ComparisonChart(items: _selectedItems),
          ],
        ),
      ),
    );
  }
}

// ────── Select Equipment Modal ──────
class _SelectEquipmentSheet extends StatefulWidget {
  final List<EquipmentModel> allEquipment;
  final List<EquipmentModel> selectedItems;
  final Function(EquipmentModel) onSelect;

  const _SelectEquipmentSheet(
    this.allEquipment,
    this.selectedItems,
    this.onSelect,
  );

  @override
  State<_SelectEquipmentSheet> createState() => _SelectEquipmentSheetState();
}

class _SelectEquipmentSheetState extends State<_SelectEquipmentSheet> {
  late TextEditingController _searchCtrl;
  String _filter = '';

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EquipmentModel> get _filtered {
    List<EquipmentModel> items = widget.allEquipment;
    if (_filter.isNotEmpty) {
      items = items
          .where((e) => e.name.toLowerCase().contains(_filter.toLowerCase()))
          .toList();
    }
    // Exclude already selected items
    items = items.where((e) => !widget.selectedItems.contains(e)).toList();
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Equipment',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8E8E8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _filter = v),
                    decoration: InputDecoration(
                      hintText: 'Search equipment...',
                      hintStyle: GoogleFonts.poppins(color: _sub),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: _sub,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: _filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          widget.allEquipment.isEmpty
                              ? 'No available equipment found.\nPlease check back later.'
                              : 'No equipment matches your search.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: _sub),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _buildEquipmentItem(_filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentItem(EquipmentModel item) {
    return GestureDetector(
      onTap: () => widget.onSelect(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.construction, color: _accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _dark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${item.pricePerHour.toStringAsFixed(0)}/hr',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle, color: _accent, size: 28),
          ],
        ),
      ),
    );
  }
}

// ────── Comparison Card ──────
class _ComparisonCard extends StatelessWidget {
  final EquipmentModel item;
  final VoidCallback onRemove;
  final bool isBestPrice;
  final bool isBestRating;

  const _ComparisonCard({
    required this.item,
    required this.onRemove,
    required this.isBestPrice,
    required this.isBestRating,
  });

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFFFF6B00);
    const Color dark = Color(0xFF1A1A2E);
    const Color sub = Color(0xFF8F90A6);
    const Color card = Colors.white;
    const Color green = Color(0xFF00C853);
    const Color yellow = Color(0xFFFFB800);

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Icon(
                        Icons.construction,
                        size: 60,
                        color: accent.withValues(alpha: 0.5),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 28,
                          height: 28,
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
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0x000ff666),
                          ),
                        ),
                      ),
                    ),
                    if (isBestPrice)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Best Price',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (isBestRating)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: yellow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Top Rated',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: dark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: yellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.rating.toStringAsFixed(1)} (${item.reviewCount})',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: sub,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${item.pricePerHour.toStringAsFixed(0)}/hr',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.isAvailable
                              ? green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.isAvailable ? 'Available' : 'Unavailable',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: item.isAvailable ? green : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Provider',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: sub,
                        ),
                      ),
                      Text(
                        item.provider.name,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: dark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: sub,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: sub,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.provider.location,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: dark,
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
        ],
      ),
    );
  }
}

// ────── Comparison Metrics Table ──────
class _ComparisonMetricsTable extends StatelessWidget {
  final List<EquipmentModel> items;

  const _ComparisonMetricsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    const Color headerBg = Color(0xFFF5F5F7);
    const Color border = Color(0xFFE0E0E0);
    const Color dark = Color(0xFF1A1A2E);
    const Color sub = Color(0xFF8F90A6);
    const Color accent = Color(0xFFFF6B00);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final bestPriceHour = items
        .map((e) => e.pricePerHour)
        .reduce((a, b) => a < b ? a : b);
    final bestRating = items
        .map((e) => e.rating)
        .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric labels column (fixed width)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: headerBg,
                  border: Border(bottom: BorderSide(color: border, width: 1)),
                ),
                child: Text(
                  'Metric',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
              ),
              _metricLabelCell('Digging Depth'),
              _metricLabelCell('Price per Hour'),
              _metricLabelCell('Price per Day'),
              _metricLabelCell('Rating'),
              _metricLabelCell('Availability'),
            ],
          ),
          // One fixed-width column per equipment
          ...items.map((e) {
            final perDay = e.pricePerHour * 8;
            final isBestPrice = e.pricePerHour == bestPriceHour;
            final isBestRating = e.rating == bestRating;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: headerBg,
                    border: Border(
                      bottom: BorderSide(color: border, width: 1),
                      left: BorderSide(color: border, width: 1),
                    ),
                  ),
                  child: Text(
                    e.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: dark,
                    ),
                  ),
                ),
                _metricValueCell(text: e.depth.isEmpty ? 'N/A' : e.depth),
                _metricValueCell(
                  text: '₹${e.pricePerHour.toStringAsFixed(0)}/hr',
                  highlight: isBestPrice,
                  highlightColor: accent,
                ),
                _metricValueCell(text: '₹${perDay.toStringAsFixed(0)}/day'),
                _metricValueCell(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        e.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: isBestRating
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isBestRating ? accent : dark,
                        ),
                      ),
                    ],
                  ),
                ),
                _metricValueCell(child: _availabilityChip(e.isAvailable)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _metricLabelCell(String label) {
    const Color border = Color(0xFFE0E0E0);
    const Color sub = Color(0xFF8F90A6);

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 1)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: sub,
        ),
      ),
    );
  }

  Widget _metricValueCell({
    String? text,
    Widget? child,
    bool highlight = false,
    Color? highlightColor,
  }) {
    const Color border = Color(0xFFE0E0E0);
    const Color dark = Color(0xFF1A1A2E);

    final content =
        child ??
        Text(
          text ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            color: highlight ? (highlightColor ?? dark) : dark,
          ),
        );

    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: border, width: 1),
          left: BorderSide(color: border, width: 1),
        ),
      ),
      child: content,
    );
  }

  Widget _availabilityChip(bool available) {
    final Color chipColor = available ? const Color(0xFF00C853) : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        available ? 'Available' : 'Unavailable',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }
}

// ────── Comparison Chart (Bars) ──────
class _ComparisonChart extends StatelessWidget {
  final List<EquipmentModel> items;

  const _ComparisonChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    const Color bg = Color(0xFFF9FAFB);
    const Color border = Color(0xFFE0E0E0);
    const Color dark = Color(0xFF1A1A2E);
    const Color sub = Color(0xFF8F90A6);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visual Comparison',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quickly see depth, price & rating across selected equipment.',
            style: GoogleFonts.poppins(fontSize: 11, color: sub),
          ),
          const SizedBox(height: 10),
          _metricBarRow(
            context,
            title: 'Digging Depth (m)',
            color: const Color(0xFF3B82F6),
            valueOf: (e) =>
                double.tryParse(e.depth.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                0.0,
            formatValue: (v) => v <= 0 ? 'N/A' : '${v.toStringAsFixed(1)}m',
          ),
          const SizedBox(height: 8),
          _metricBarRow(
            context,
            title: 'Price per Hour',
            color: const Color(0xFFFF6B00),
            valueOf: (e) => e.pricePerHour,
            formatValue: (v) => '₹${v.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _metricBarRow(
            context,
            title: 'Rating',
            color: const Color(0xFFFFB800),
            valueOf: (e) => e.rating,
            formatValue: (v) => v.toStringAsFixed(1),
            maxOverride: 5,
          ),
        ],
      ),
    );
  }

  Widget _metricBarRow(
    BuildContext context, {
    required String title,
    required Color color,
    required double Function(EquipmentModel) valueOf,
    required String Function(double) formatValue,
    double? maxOverride,
  }) {
    final values = items.map(valueOf).toList();
    double maxVal =
        maxOverride ??
        (values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0);
    if (maxVal <= 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Not available for selected equipment',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(items.length, (index) {
              final v = values[index];
              final normalized = (v / maxVal).clamp(0.15, 1.0);
              final e = items[index];
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 14,
                          height: 60 * normalized,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatValue(v),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
