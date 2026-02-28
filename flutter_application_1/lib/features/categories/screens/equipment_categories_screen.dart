import 'package:flutter/material.dart';

/// Equipment category model
class EquipmentCategory {
  final String name;
  final String emoji;
  final int id;

  const EquipmentCategory({
    required this.name,
    required this.emoji,
    required this.id,
  });
}

/// Main Equipment Categories Screen
class EquipmentCategoriesScreen extends StatelessWidget {
  const EquipmentCategoriesScreen({super.key});

  static const List<EquipmentCategory> categories = [
    EquipmentCategory(name: 'Excavators', emoji: '🏗️', id: 1),
    EquipmentCategory(name: 'Backhoe Loaders', emoji: '⛏️', id: 2),
    EquipmentCategory(name: 'Bulldozers', emoji: '🚜', id: 3),
    EquipmentCategory(name: 'Skid Steers', emoji: '🔧', id: 4),
    EquipmentCategory(name: 'Wheel Loaders', emoji: '🏭', id: 5),
    EquipmentCategory(name: 'Motor Graders', emoji: '🛣️', id: 6),
    EquipmentCategory(name: 'Rollers', emoji: '🛞', id: 7),
    EquipmentCategory(name: 'Dump Trucks', emoji: '🚚', id: 8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [_buildHeaderSection(context), _buildCategoryGrid(context)],
        ),
      ),
    );
  }

  /// Build AppBar with logo, language toggle, and auth buttons
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF59E0B).withOpacity(0.1),
            ),
            child: const Center(
              child: Text('⚙️', style: TextStyle(fontSize: 24)),
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'EquipRent',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          // Language Toggle
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed to $value'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'EN', child: Text('English')),
              const PopupMenuItem(value: 'हि', child: Text('Hindi')),
              const PopupMenuItem(value: 'मर', child: Text('Marathi')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'EN | हि | मर',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),

          // Login Button
          TextButton(
            onPressed: () {
              _showAuthDialog(context, 'Login');
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Register Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _showAuthDialog(context, 'Register');
              },
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build header section with title and subtitle
  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Equipment Categories',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 32,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Browse by type to find exactly what your project needs',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build category grid
  Widget _buildCategoryGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryCard(
            category: categories[index],
            onTap: () => _onCategoryTap(context, categories[index]),
          );
        },
      ),
    );
  }

  /// Handle category tap
  void _onCategoryTap(BuildContext context, EquipmentCategory category) {
    debugPrint('Category tapped: ${category.name} (ID: ${category.id})');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.name} - Browse equipment'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show auth dialog
  void _showAuthDialog(BuildContext context, String authType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$authType to EquipRent'),
        content: Text('$authType feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Reusable Category Card Widget
class CategoryCard extends StatefulWidget {
  final EquipmentCategory category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _animationController.forward();
  }

  void _onTapUp() {
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: Offset(0, _isHovered ? 4 : 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                highlightColor: const Color(0xFFF59E0B).withOpacity(0.1),
                splashColor: const Color(0xFFF59E0B).withOpacity(0.15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji Icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF59E0B).withOpacity(0.08),
                      ),
                      child: Center(
                        child: Text(
                          widget.category.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        widget.category.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Main App Widget (for standalone testing)
void main() {
  runApp(
    MaterialApp(
      title: 'EquipRent',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF59E0B),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const EquipmentCategoriesScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
