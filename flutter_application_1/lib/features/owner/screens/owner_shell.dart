import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/stats_service.dart';
import '../../../core/services/notifications_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/notifications_screen.dart';
import '../../booking/screens/provider_bookings_screen.dart';
import '../../booking/services/booking_service.dart';
import '../../../models/booking_model.dart';
import '../../equipment/screens/add_equipment_screen.dart';

import '../../equipment/screens/owner_equipment_detail_screen.dart';
import '../../equipment/services/equipment_service.dart' as equip_svc;
import '../../home/models/equipment_model.dart';
import '../../home/widgets/equipment_image.dart'
    show EquipmentImage;
// ─────────────────────────────────────────────────────────────
// Owner Shell — 4-tab bottom nav
//  Dashboard · Equipment · Bookings · Profile
// ─────────────────────────────────────────────────────────────

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});
  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _idx = 0;

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _sub = Color(0xFFBBBBCC);

<<<<<<< HEAD
  final List<Widget> _pages = const [
    _OwnerDashboard(),
    _OwnerEquipment(),
    _OwnerBookings(),
    _OwnerProfile(),
  ];
=======
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _OwnerDashboard(onSwitchTab: (i) => setState(() => _idx = i)),
      const _OwnerEquipment(),
      const _OwnerBookings(),
      const _OwnerNotifications(),
      _OwnerProfile(onSwitchTab: (i) => setState(() => _idx = i)),
    ];
  }
>>>>>>> 30bced0 (Update project files)

  @override
  Widget build(BuildContext context) {
    context
        .locale; // register as EasyLocalization dependent so bottom nav rebuilds on language change
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
<<<<<<< HEAD
                _nav(Icons.dashboard_rounded, 'Dashboard', 0),
                _nav(Icons.construction_rounded, 'Equipment', 1),
                _nav(Icons.event_note_rounded, 'Bookings', 2),
                _nav(Icons.person_outline_rounded, 'Profile', 3),
=======
                _nav(Icons.dashboard_rounded, tr('dashboard'), 0),
                _nav(Icons.construction_rounded, tr('equipment'), 1),
                _nav(Icons.event_note_rounded, tr('bookings'), 2),
                _nav(Icons.notifications_none_rounded, tr('notifications'), 3),
                _nav(Icons.person_outline_rounded, tr('profile'), 4),
>>>>>>> 30bced0 (Update project files)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nav(IconData icon, String label, int i) {
    final on = _idx == i;
    return GestureDetector(
      onTap: () => setState(() => _idx = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: on ? _accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: on ? _accent : _sub),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                color: on ? _accent : _sub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 1. DASHBOARD
// ═══════════════════════════════════════════════════════════════

class _OwnerDashboard extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const _OwnerDashboard({required this.onSwitchTab});
  @override
  State<_OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<_OwnerDashboard> {
  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _card = Colors.white;
  static const _bg = Color(0xFFF7F7F7);
  static const _green = Color(0xFF00C853);
  static const _blue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() {
    if (!mounted) return;
    context.read<StatsProvider>().loadUserStats();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<equip_svc.EquipmentProvider>().loadProviderEquipment(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
    final auth = Provider.of<AuthProvider>(context);
    final stats = context.watch<StatsProvider>().userStats;
    final equipProv = context.watch<equip_svc.EquipmentProvider>();
    final notifProv = context.watch<NotificationsProvider>();
    final myEquip = equipProv.equipment
        .map((f) => EquipmentModel.fromFirestoreModel(f))
        .toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                children: [
<<<<<<< HEAD
=======
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(
                            'hello_greeting',
                          ).replaceFirst('{}', auth.userName.split(' ').first),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr('equipment_owner_dashboard'),
                          style: GoogleFonts.poppins(fontSize: 13, color: _sub),
                        ),
                      ],
                    ),
                  ),
>>>>>>> 30bced0 (Update project files)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _accent,
                    child: Text(
                      auth.userName.isNotEmpty
                          ? auth.userName[0].toUpperCase()
                          : 'O',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
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
                          'Hello, ${auth.userName.split(' ').first}!',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Equipment Owner',
                          style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Likes feature coming soon!',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: _accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.favorite_border_rounded,
                        color: _sub, size: 24),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded,
                            color: _sub, size: 24),
                        if (notifProv.unseenCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B00),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${notifProv.unseenCount}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
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
              const SizedBox(height: 24),

              // Stats cards
              Row(
                children: [
                  _statCard(
                    '${myEquip.length}',
                    tr('equipment'),
                    Icons.construction_rounded,
                    _accent,
                    onTap: () => widget.onSwitchTab(1),
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    '${stats.bookings}',
                    tr('bookings'),
                    Icons.event_note_rounded,
                    _blue,
                    onTap: () => widget.onSwitchTab(2),
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    '${stats.reviews}',
                    tr('reviews'),
                    Icons.star_rounded,
                    _green,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Earnings card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          tr('total_earnings'),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<BookingModel>>(
                      stream: FirebaseAuth.instance.currentUser?.uid != null
                          ? BookingService().streamProviderBookings(
                              FirebaseAuth.instance.currentUser!.uid,
                            )
                          : const Stream.empty(),
                      builder: (context, snap) {
                        double total = 0;
                        int completedCount = 0;
                        if (snap.hasData) {
                          for (final b in snap.data!) {
                            if (b.status == BookingStatus.completed) {
                              total += b.providerAmount;
                              completedCount++;
                            }
                          }
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              completedCount == 0
                                  ? tr('no_completed_bookings_yet')
                                  : '$completedCount ${tr('completed_bookings')}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                tr('quick_actions'),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 51, 51, 201),
                ),
              ),
              const SizedBox(height: 12),
<<<<<<< HEAD
              Center(
                child: Column(
                  children: [
                    _quickAction(
                      Icons.add_circle_rounded,
                      'Add\nEquipment',
                      _accent,
                      () => Navigator.push(
=======
              Row(
                children: [
                  _quickAction(
                    Icons.add_circle_rounded,
                    'Add\nEquipment',
                    _accent,
                    () async {
                      await Navigator.push(
>>>>>>> 30bced0 (Update project files)
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEquipmentScreen(),
                        ),
<<<<<<< HEAD
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Equipment Status Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_rounded, color: _blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Equipment Status: ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _sub,
                            ),
                          ),
                          DropdownButton<String>(
                            value: 'Available',
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(
                                value: 'Available',
                                child: Text('Available'),
                              ),
                              DropdownMenuItem(
                                value: 'Rented',
                                child: Text('Rented'),
                              ),
                              DropdownMenuItem(
                                value: 'Under Maintenance',
                                child: Text('Under Maintenance'),
                              ),
                            ],
                            onChanged: (String? value) {
                              if (value != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Status changed to $value',
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
                          ),
                        ],
=======
                      );
                      _reload();
                    },
                  ),
                  const SizedBox(width: 12),
                  _quickAction(
                    Icons.business_rounded,
                    'Register\nProvider',
                    _blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProviderRegistrationScreen(),
>>>>>>> 30bced0 (Update project files)
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent equipment
              Row(
                children: [
                  Text(
                    tr('recent_equipment'),
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${myEquip.length} total',
                    style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (equipProv.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: _accent),
                  ),
                )
              else if (myEquip.isEmpty)
                _emptyCard(
                  tr('no_equipment_yet'),
                  tr('tap_to_add_equipment'),
                  Icons.construction_outlined,
                )
              else
                ...myEquip.take(3).map((e) => _equipRow(e)),
              const SizedBox(height: 24),

              // ── Recent Reviews ──
              Row(
                children: [
                  Text(
                    'Recent Reviews',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .where(
                      'providerId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: _accent),
                      ),
                    );
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return _emptyCard(
                      'No reviews yet',
                      'Reviews from renters will appear here',
                      Icons.star_outline_rounded,
                    );
                  }
                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data()! as Map<String, dynamic>;
                      final rating = (data['rating'] as num?)?.toInt() ?? 0;
                      final userName = (data['userName'] as String?) ?? 'User';
                      final comment = (data['comment'] as String?) ?? '';
                      final equipName =
                          (data['equipmentName'] as String?) ?? 'Equipment';
                      final ts = data['createdAt'];
                      String dateStr = '';
                      if (ts is Timestamp) {
                        final dt = ts.toDate();
                        dateStr = '${dt.day}/${dt.month}/${dt.year}';
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _accent.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _dark,
                                        ),
                                      ),
                                      Text(
                                        equipName,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < rating
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                    if (dateStr.isNotEmpty)
                                      Text(
                                        dateStr,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: _sub,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            if (comment.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                comment,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _sub,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    String val,
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                val,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: _sub),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(String title, String sub, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: _sub),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.poppins(fontSize: 12, color: _sub),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _equipRow(EquipmentModel e) {
    final equipProv = context.read<equip_svc.EquipmentProvider>();
    final fsModel = equipProv.equipment.firstWhere(
      (f) => f.id == e.id,
      orElse: () => equipProv.equipment.first,
    );

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OwnerEquipmentDetailScreen(equipment: fsModel),
          ),
        );
        // Reload after returning
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null && mounted) {
          context.read<equip_svc.EquipmentProvider>().loadProviderEquipment(
            uid,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 60,
                height: 60,
                child: EquipmentImage(
                  imageUrls: e.imageUrls,
                  fallbackAsset: e.imageAsset,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 2),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: e.isAvailable
                    ? _green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                e.isAvailable ? tr('active') : tr('inactive'),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: e.isAvailable ? _green : Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFBBBBCC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 2. EQUIPMENT (manage listings)
// ═══════════════════════════════════════════════════════════════

class _OwnerEquipment extends StatefulWidget {
  const _OwnerEquipment();
  @override
  State<_OwnerEquipment> createState() => _OwnerEquipmentState();
}

class _OwnerEquipmentState extends State<_OwnerEquipment> {
  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _green = Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<equip_svc.EquipmentProvider>().loadProviderEquipment(uid);
    }
    context.read<StatsProvider>().loadUserStats();
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
    final prov = context.watch<equip_svc.EquipmentProvider>();
    final items = prov.equipment
        .map((f) => EquipmentModel.fromFirestoreModel(f))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Text(
                    tr('my_equipment'),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${items.length} ads',
                    style: GoogleFonts.poppins(fontSize: 13, color: _sub),
                  ),
                ],
              ),
            ),
            Expanded(
              child: prov.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : items.isEmpty
                  ? _empty()
                  : RefreshIndicator(
                      color: _accent,
                      onRefresh: () async => _load(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => _tile(items[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_post_equipment',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEquipmentScreen()),
          );
          _load();
        },
        backgroundColor: _accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          tr('post_equipment'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _empty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: _accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tr('no_listings_yet'),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tr('post_equipment_msg'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: _sub, height: 1.5),
          ),
        ],
      ),
    ),
  );

  Widget _tile(EquipmentModel e) {
    // Find the original Firestore model for navigation
    final prov = context.read<equip_svc.EquipmentProvider>();
    final fsModel = prov.equipment.firstWhere(
      (f) => f.id == e.id,
      orElse: () => prov.equipment.first,
    );

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OwnerEquipmentDetailScreen(equipment: fsModel),
          ),
        );
        _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
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
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${e.pricePerHour.toStringAsFixed(0)}/hr',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: e.isAvailable
                              ? _green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          e.isAvailable ? tr('active') : tr('inactive'),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: e.isAvailable ? _green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFBBBBCC),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 3. BOOKINGS (accept / reject / manage)
// ═══════════════════════════════════════════════════════════════

class _OwnerBookings extends StatelessWidget {
  const _OwnerBookings();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return ProviderBookingsScreen(providerId: uid, embedded: true);
  }
}

// ═══════════════════════════════════════════════════════════════
// 4. NOTIFICATIONS (incoming booking requests)
// ═══════════════════════════════════════════════════════════════

class _OwnerNotifications extends StatelessWidget {
  const _OwnerNotifications();

  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _bg = Color(0xFFF7F7F7);
  static const _card = Colors.white;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    context.locale;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Text(
                    tr('notifications'),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<BookingModel>>(
                stream: BookingService().streamProviderBookings(uid),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }
                  final bookings = snap.data ?? [];
                  if (bookings.isEmpty) return _empty();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: bookings.length,
                    itemBuilder: (ctx, i) => _notifCard(bookings[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: _accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              tr('no_notifications'),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr('notifications_empty_msg'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _sub,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notifCard(BookingModel b) {
    final color = _statusColor(b.status);
    final icon = _statusIcon(b.status);
    final label = _statusLabel(b.status);
    final d = b.bookingDate;
    final dateStr = '${d.day} ${_months[d.month - 1]} ${d.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.equipmentName,
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
                  'From: ${b.userName}',
                  style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                    ),
                    const Spacer(),
                    Text(
                      '₹${b.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return const Color(0xFFFF9800);
      case BookingStatus.approved:
        return const Color(0xFF00C853);
      case BookingStatus.inProgress:
        return const Color(0xFF3B82F6);
      case BookingStatus.completed:
        return const Color(0xFF9C27B0);
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.rejected:
        return Colors.red;
    }
  }

  IconData _statusIcon(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return Icons.hourglass_top_rounded;
      case BookingStatus.approved:
        return Icons.check_circle_rounded;
      case BookingStatus.inProgress:
        return Icons.play_circle_rounded;
      case BookingStatus.completed:
        return Icons.done_all_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
      case BookingStatus.rejected:
        return Icons.block_rounded;
    }
  }

  String _statusLabel(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// 5. PROFILE (owner profile)
// ═══════════════════════════════════════════════════════════════

class _OwnerProfile extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const _OwnerProfile({required this.onSwitchTab});
  @override
  State<_OwnerProfile> createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<_OwnerProfile> {
  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _accentLight = Color(0xFFFFF3E8);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _sub = Color(0xFF8F90A6);
  static const Color _card = Colors.white;

  static const Map<String, String> _langNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'mr': 'मराठी',
  };

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  tr('select_language'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...context.supportedLocales.map((locale) {
                final code = locale.languageCode;
                final isSelected = context.locale == locale;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? _accent : _sub,
                  ),
                  title: Text(
                    _langNames[code] ?? code,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? _accent : Colors.black87,
                    ),
                  ),
                  trailing: Text(
                    code.toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                  ),
                  onTap: () {
                    context.setLocale(locale);
                    Navigator.of(sheetCtx).pop();
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadUserStats();
      context.read<AuthProvider>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
    final auth = Provider.of<AuthProvider>(context);
    final stats = context.watch<StatsProvider>().userStats;
    final name = auth.userName;
    final email = auth.userEmail;
    final photoUrl = auth.userPhotoUrl;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: Container(
                          color: Colors.white,
                          child: photoUrl != null
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                  errorBuilder: (_, __, ___) => _initial(name),
                                )
                              : _initial(name),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tr('owner_badge'),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _stat('${stats.listings}', tr('listings')),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        _stat('${stats.bookings}', tr('bookings')),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        _stat('${stats.reviews}', tr('reviews')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Email verification banner
              if (!auth.isEmailVerified) _emailVerificationBanner(auth),

              _section(tr('account'), [
                _M(
                  Icons.person_outline_rounded,
                  tr('edit_profile'),
                  onTap: () => _showEditProfileSheet(auth),
                ),
<<<<<<< HEAD
=======
                _M(
                  Icons.business_rounded,
                  tr('register_as_provider'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProviderRegistrationScreen(),
                    ),
                  ),
                ),
>>>>>>> 30bced0 (Update project files)
              ]),
              const SizedBox(height: 14),
              _section(tr('general'), [
                _M(
                  Icons.language_rounded,
                  tr('language_label'),
                  onTap: _showLanguagePicker,
                ),
                _M(
                  Icons.notifications_none_rounded,
<<<<<<< HEAD
                  'Notifications',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
=======
                  tr('notifications'),
                  onTap: () => widget.onSwitchTab(3),
>>>>>>> 30bced0 (Update project files)
                ),
                _M(
                  Icons.payment_outlined,
                  tr('payment_methods'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('cash_on_delivery_msg'),
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: _accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                _M(
                  Icons.history_rounded,
                  tr('transaction_history'),
                  onTap: () {
                    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProviderBookingsScreen(providerId: uid),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 14),
              _section(tr('support'), [
                _M(
                  Icons.help_outline_rounded,
                  tr('help_faq'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('support_email_msg'),
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: _accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
                _M(
                  Icons.chat_outlined,
                  tr('contact_us'),
                  onTap: () =>
                      launchUrl(Uri.parse('mailto:support@equippro.in')),
                ),
                _M(
                  Icons.star_outline_rounded,
                  tr('rate_app'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('thank_you_msg'),
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: _accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 20),
              // Sign out
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => auth.signOut(),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  label: Text(
                    tr('sign_out'),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tr('app_version'),
                style: GoogleFonts.poppins(fontSize: 12, color: _sub),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initial(String name) => Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'O',
      style: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: _accent,
      ),
    ),
  );

  void _showEditProfileSheet(AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.userName);
    final phoneCtrl = TextEditingController(text: auth.userPhone ?? '');
    File? pickedFile;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tr('edit_profile'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 24),
                // Avatar picker
                GestureDetector(
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 600,
                      imageQuality: 75,
                    );
                    if (picked != null) {
                      setSheetState(() => pickedFile = File(picked.path));
                    }
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: _accentLight,
                        backgroundImage: pickedFile != null
                            ? FileImage(pickedFile!) as ImageProvider
                            : (auth.userPhotoUrl != null
                                  ? NetworkImage(auth.userPhotoUrl!)
                                  : null),
                        child: pickedFile == null && auth.userPhotoUrl == null
                            ? Text(
                                auth.userName.isNotEmpty
                                    ? auth.userName[0].toUpperCase()
                                    : 'O',
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: _accent,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: tr('name'),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: tr('phone'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            setSheetState(() => isSaving = true);
                            final ok = await auth.updateUserProfile(
                              name: nameCtrl.text.trim().isEmpty
                                  ? null
                                  : nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              photoFile: pickedFile,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? tr('profile_updated')
                                      : (auth.errorMessage ?? 'Update failed'),
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: ok
                                    ? const Color(0xFF00C853)
                                    : Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            tr('save'),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailVerificationBanner(AuthProvider auth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFCC00).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF9800),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('email_not_verified'),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A5C00),
                  ),
                ),
                Text(
                  tr('verify_email_to_continue'),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF7A5C00),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await auth.sendEmailVerification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr('verification_email_sent'),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tr('verify'),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String val, String label) => Expanded(
    child: Column(
      children: [
        Text(
          val,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    ),
  );

  Widget _section(String title, List<_M> items) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(18),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _sub,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map(_menuItem),
      ],
    ),
  );

  Widget _menuItem(_M m) => InkWell(
    onTap: m.onTap ?? () {},
    borderRadius: BorderRadius.circular(18),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(m.icon, color: _accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              m.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _dark,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _sub),
        ],
      ),
    ),
  );
}

class _M {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _M(this.icon, this.title, {this.onTap});
}
