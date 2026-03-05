import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/stats_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../booking/screens/user_bookings_screen.dart';
import '../../booking/services/booking_service.dart';
import '../../../models/booking_model.dart';
import '../../equipment/screens/rc_verification_screen.dart';
import '../../equipment/services/equipment_service.dart' as equip_svc;
import '../../home/models/equipment_model.dart';
import '../../home/screens/equipment_details_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../notifications/notifications_screen.dart';

// ─────────────────────────────────────────────────────────────
// User Shell — 4-tab bottom nav
//  Home · My Bookings · Notifications · Profile
// ─────────────────────────────────────────────────────────────

class UserShell extends StatefulWidget {
  const UserShell({super.key});
  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _idx = 0;

  static const Color _accent = Color(0xFF3B82F6);
  static const Color _sub = Color(0xFFBBBBCC);

  final List<Widget> _pages = const [
    HomeScreen(),
    _UserBookings(),
    // Use the new notifications screen
    NotificationsScreen(),
    _UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    context
        .locale; // register as EasyLocalization dependent so bottom nav rebuilds on language change
    return Scaffold(
      drawer: _buildDrawer(context),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nav(Icons.home_rounded, tr('home'), 0),
                _nav(Icons.event_note_rounded, tr('my_bookings'), 1),
                _nav(Icons.notifications_none_rounded, tr('notifications'), 2),
                _nav(Icons.person_outline_rounded, tr('profile'), 3),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.construction_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'EquipPro',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    tr('explore_more'),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(
              context,
              Icons.recommend_rounded,
              tr('recommendations'),
              const Color(0xFF3B82F6),
              () {
                Navigator.pop(context);
                context.read<equip_svc.EquipmentProvider>().loadAllEquipment();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _RecommendationsScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              context,
              Icons.compare_arrows_rounded,
              tr('compare_equipment'),
              const Color(0xFFFF6B00),
              () {
                Navigator.pop(context);
                context.read<equip_svc.EquipmentProvider>().loadAllEquipment();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _CompareEquipmentScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 24),
            _drawerItem(
              context,
              Icons.home_rounded,
              tr('home'),
              const Color(0xFF3B82F6),
              () {
                Navigator.pop(context);
                setState(() => _idx = 0);
              },
            ),
            _drawerItem(
              context,
              Icons.event_note_rounded,
              tr('my_bookings'),
              const Color(0xFF3B82F6),
              () {
                Navigator.pop(context);
                setState(() => _idx = 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MY BOOKINGS — shows user's booked equipment
// ═══════════════════════════════════════════════════════════════

class _UserBookings extends StatelessWidget {
  const _UserBookings();

  @override
  Widget build(BuildContext context) {
    return const UserBookingsScreen(embedded: true);
  }
}

// ═══════════════════════════════════════════════════════════════
// NOTIFICATIONS
// ═══════════════════════════════════════════════════════════════

class _UserNotifications extends StatelessWidget {
  const _UserNotifications();

  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _blue = Color(0xFF3B82F6);
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
                stream: BookingService().streamUserBookings(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _blue),
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
                color: _blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: _blue,
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
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${b.totalAmount.toStringAsFixed(0)}  ·  ${b.durationHours}h  ·  ${b.providerName}',
                  style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
// USER PROFILE
// ═══════════════════════════════════════════════════════════════

class _UserProfile extends StatefulWidget {
  const _UserProfile();
  @override
  State<_UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<_UserProfile> {
  static const Color _bg = Color(0xFFF7F7F7);
  static const Color _accent = Color(0xFF3B82F6);
  static const Color _accentLight = Color(0xFFEBF2FF);
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
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
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
                    GestureDetector(
                      onTap: () => _showEditProfileSheet(auth),
                      child: Stack(
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
                                        errorBuilder: (_, __, ___) =>
                                            _initial(name),
                                      )
                                    : _initial(name),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF3B82F6),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
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
                        tr('user_badge'),
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
                _M(
                  Icons.calendar_today_rounded,
                  tr('booking_history'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserBookingsScreen(),
                      ),
                    );
                  },
                ),
                _M(
                  Icons.directions_car_rounded,
                  tr('verify_vehicle_rc'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RCVerificationScreen(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              _section(tr('general'), [
                _M(
                  Icons.language_rounded,
                  tr('language_label'),
                  onTap: _showLanguagePicker,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserBookingsScreen(),
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
      name.isNotEmpty ? name[0].toUpperCase() : 'U',
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
                                    : 'U',
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
                // Name field
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.poppins(color: const Color(0xFF1C1C1E)),
                  decoration: InputDecoration(
                    labelText: tr('name'),
                    labelStyle: GoogleFonts.poppins(
                      color: const Color(0xFF5A5A72),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF5A5A72),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                  ),
                ),
                const SizedBox(height: 14),
                // Phone field
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(color: const Color(0xFF1C1C1E)),
                  decoration: InputDecoration(
                    labelText: tr('phone'),
                    labelStyle: GoogleFonts.poppins(
                      color: const Color(0xFF5A5A72),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF5A5A72),
                    ),
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

// ═══════════════════════════════════════════════════════════════
// RECOMMENDATIONS SCREEN
// ═══════════════════════════════════════════════════════════════
class _RecommendationsScreen extends StatelessWidget {
  const _RecommendationsScreen();

  static const _bg = Color(0xFFF7F7F7);
  static const _accent = Color(0xFF3B82F6);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('recommendations'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<equip_svc.EquipmentProvider>(
        builder: (ctx, prov, _) {
          final all = prov.allEquipment;
          if (all.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.recommend_rounded,
                    size: 60,
                    color: _accent.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr('no_equipment_yet'),
                    style: GoogleFonts.poppins(fontSize: 16, color: _sub),
                  ),
                ],
              ),
            );
          }
          // Sort by rating desc for recommendations
          final sorted = [...all]..sort((a, b) => b.rating.compareTo(a.rating));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (ctx, i) {
              final eq = sorted[i];
              return _RecommendCard(eq: eq);
            },
          );
        },
      ),
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final dynamic eq;
  const _RecommendCard({required this.eq});

  static const _accent = Color(0xFF3B82F6);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _card = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EquipmentDetailsScreen(
            equipment: EquipmentModel.fromFirestoreModel(eq),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Rank badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.recommend_rounded,
                color: _accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${eq.brand} ${eq.machineType.value}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${eq.district} · ₹${eq.hourlyRate.toStringAsFixed(0)}/hr',
                    style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: Color(0xFFFFB800),
                ),
                const SizedBox(width: 3),
                Text(
                  eq.rating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// COMPARE EQUIPMENT SCREEN
// ═══════════════════════════════════════════════════════════════
class _CompareEquipmentScreen extends StatefulWidget {
  const _CompareEquipmentScreen();
  @override
  State<_CompareEquipmentScreen> createState() =>
      _CompareEquipmentScreenState();
}

class _CompareEquipmentScreenState extends State<_CompareEquipmentScreen> {
  dynamic _leftEq;
  dynamic _rightEq;

  static const _bg = Color(0xFFF7F7F7);
  static const _accent = Color(0xFF3B82F6);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _card = Colors.white;

  void _pickEquipment(bool isLeft, List<dynamic> all) async {
    final picked = await showModalBottomSheet<dynamic>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Equipment',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: all.length,
              itemBuilder: (ctx, i) {
                final eq = all[i];
                return ListTile(
                  leading: const Icon(Icons.construction_rounded),
                  title: Text(
                    '${eq.brand} ${eq.machineType.value}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '₹${eq.hourlyRate.toStringAsFixed(0)}/hr · ${eq.district}',
                    style: GoogleFonts.poppins(fontSize: 12, color: _sub),
                  ),
                  onTap: () => Navigator.pop(ctx, eq),
                );
              },
            ),
          ),
        ],
      ),
    );
    if (picked != null) {
      setState(() {
        if (isLeft) {
          _leftEq = picked;
        } else {
          _rightEq = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('compare_equipment'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<equip_svc.EquipmentProvider>(
        builder: (ctx, prov, _) {
          final all = prov.allEquipment;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Selector row
                Row(
                  children: [
                    Expanded(
                      child: _picker(
                        'Equipment A',
                        _leftEq,
                        () => _pickEquipment(true, all),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.compare_arrows_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _picker(
                        'Equipment B',
                        _rightEq,
                        () => _pickEquipment(false, all),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_leftEq != null && _rightEq != null) ...[
                  _compareRow(
                    'Type',
                    _leftEq.machineType.value,
                    _rightEq.machineType.value,
                  ),
                  _compareRow('Brand', _leftEq.brand, _rightEq.brand),
                  _compareRow('Model', _leftEq.model, _rightEq.model),
                  _compareRow(
                    'Hourly Rate',
                    '₹${_leftEq.hourlyRate.toStringAsFixed(0)}',
                    '₹${_rightEq.hourlyRate.toStringAsFixed(0)}',
                    betterLeft: _leftEq.hourlyRate <= _rightEq.hourlyRate,
                  ),
                  _compareRow(
                    'Rating',
                    _leftEq.rating.toStringAsFixed(1),
                    _rightEq.rating.toStringAsFixed(1),
                    betterLeft: _leftEq.rating >= _rightEq.rating,
                  ),
                  _compareRow('Location', _leftEq.district, _rightEq.district),
                  if (_leftEq.enginePower.isNotEmpty ||
                      _rightEq.enginePower.isNotEmpty)
                    _compareRow(
                      'Engine Power',
                      _leftEq.enginePower.isEmpty ? '—' : _leftEq.enginePower,
                      _rightEq.enginePower.isEmpty ? '—' : _rightEq.enginePower,
                    ),
                  if (_leftEq.bucketCapacity.isNotEmpty ||
                      _rightEq.bucketCapacity.isNotEmpty)
                    _compareRow(
                      'Bucket Capacity',
                      _leftEq.bucketCapacity.isEmpty
                          ? '—'
                          : _leftEq.bucketCapacity,
                      _rightEq.bucketCapacity.isEmpty
                          ? '—'
                          : _rightEq.bucketCapacity,
                    ),
                  if (_leftEq.operatingWeight.isNotEmpty ||
                      _rightEq.operatingWeight.isNotEmpty)
                    _compareRow(
                      'Op. Weight',
                      _leftEq.operatingWeight.isEmpty
                          ? '—'
                          : _leftEq.operatingWeight,
                      _rightEq.operatingWeight.isEmpty
                          ? '—'
                          : _rightEq.operatingWeight,
                    ),
                  if (_leftEq.depth.isNotEmpty || _rightEq.depth.isNotEmpty)
                    _compareRow(
                      'Depth',
                      _leftEq.depth.isEmpty ? '—' : _leftEq.depth,
                      _rightEq.depth.isEmpty ? '—' : _rightEq.depth,
                    ),
                  if (_leftEq.soilType.isNotEmpty ||
                      _rightEq.soilType.isNotEmpty)
                    _compareRow(
                      'Soil Type',
                      _leftEq.soilType.isEmpty ? '—' : _leftEq.soilType,
                      _rightEq.soilType.isEmpty ? '—' : _rightEq.soilType,
                    ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.compare_rounded,
                          size: 60,
                          color: _accent.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select two equipment to compare',
                          style: GoogleFonts.poppins(fontSize: 14, color: _sub),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _picker(String label, dynamic eq, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          children: [
            Icon(
              eq == null
                  ? Icons.add_circle_outline_rounded
                  : Icons.construction_rounded,
              color: _accent,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              eq == null ? label : '${eq.brand}\n${eq.machineType.value}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _compareRow(
    String label,
    String left,
    String right, {
    bool? betterLeft,
  }) {
    final leftColor = betterLeft == null
        ? _dark
        : (betterLeft ? const Color(0xFF00C853) : _sub);
    final rightColor = betterLeft == null
        ? _dark
        : (!betterLeft ? const Color(0xFF00C853) : _sub);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: leftColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: _sub),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: rightColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
