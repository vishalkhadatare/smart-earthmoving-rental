import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/provider_service.dart';

/// Indian districts list for dropdown
class IndianDistricts {
  static const List<String> districts = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Ahmedabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Jaipur',
    'Lucknow',
    'Kanpur',
    'Nagpur',
    'Indore',
    'Thane',
    'Bhopal',
    'Visakhapatnam',
    'Patna',
    'Vadodara',
    'Ghaziabad',
    'Ludhiana',
    'Agra',
    'Nashik',
    'Faridabad',
    'Meerut',
    'Rajkot',
    'Varanasi',
    'Srinagar',
    'Aurangabad',
    'Dhanbad',
    'Amritsar',
    'Allahabad',
    'Ranchi',
    'Howrah',
    'Coimbatore',
    'Jabalpur',
    'Gwalior',
    'Vijayawada',
    'Jodhpur',
    'Madurai',
    'Raipur',
    'Kota',
    'Chandigarh',
    'Guwahati',
    'Solapur',
    'Hubli-Dharwad',
    'Tiruchirappalli',
    'Bareilly',
    'Mysore',
    'Tiruppur',
    'Gurgaon',
  ];
}

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});
  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _selectedDistrict;
  final String _selectedState = 'Maharashtra';

  // Track which section is expanded
  int _currentStep = 0;

  // ── Theme ──
  static const _bg = Color(0xFF0D0F1A);
  static const _surface = Color(0xFF14162A);
  static const _card = Color(0xFF1A1D30);
  static const _accent = Color(0xFFFF6B00);
  static const _accent2 = Color(0xFFFF9A3E);
  static const _green = Color(0xFF22C55E);
  static const _blue = Color(0xFF3B82F6);
  static const _textPrimary = Color(0xFFEEEFF5);
  static const _textSub = Color(0xFF9CA3AF);
  static const _fieldBg = Color(0xFF1E2035);
  static const _border = Color(0xFF2A2D45);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: _bg,
      ),
    );
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _gstinCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDistrict == null) {
      _toast('Please select a district');
      return;
    }

    final provider = context.read<ProviderRegistrationProvider>();
    final ok = await provider.register(
      companyName: _companyNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim(),
      gstin: _gstinCtrl.text.trim(),
      district: _selectedDistrict!,
      state: _selectedState,
      address: _addressCtrl.text.trim(),
      latitude: 19.0760,
      longitude: 72.8777,
    );

    if (!mounted) return;
    if (ok) {
      _showSuccessDialog();
    } else {
      _toast(provider.errorMessage);
    }
  }

  void _toast(String? m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          m ?? 'Something went wrong',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated check
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _green.withValues(alpha: 0.2),
                      _green.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: _green.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.check_rounded, color: _green, size: 44),
              ),
              const SizedBox(height: 24),
              Text(
                'You\'re In! 🎉',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Registration successful!\nYour profile is under verification.\nYou\'ll be notified within 24 hours.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _textSub,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Timeline
              _timelineItem(
                Icons.check_circle_rounded,
                _green,
                'Registration Submitted',
                true,
              ),
              _timelineItem(
                Icons.hourglass_top_rounded,
                _accent,
                'Verification In Progress',
                false,
              ),
              _timelineItem(
                Icons.verified_rounded,
                _blue,
                'Profile Verified',
                false,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // dialog
                    Navigator.pop(context, true); // screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
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
    );
  }

  Widget _timelineItem(IconData icon, Color color, String label, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? color.withValues(alpha: 0.15) : _fieldBg,
            ),
            child: Icon(
              icon,
              size: 16,
              color: done ? color : _textSub.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: done ? _textPrimary : _textSub,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _goStep(int step) => setState(() => _currentStep = step);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Header ──
          _header(),

          // ── Body ──
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Progress Stepper ──
                      _stepper(),
                      const SizedBox(height: 24),

                      // ── Step Content ──
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOut,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_currentStep),
                          child: _currentStep == 0
                              ? _step1Business()
                              : _currentStep == 1
                              ? _step2Contact()
                              : _step3Location(),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Navigation buttons ──
                      _navButtons(),
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

  // ── Header ──
  Widget _header() {
    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'New Registration',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Hero banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accent, _accent2],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.add_business_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Become a Provider',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'List equipment • Earn daily • Grow your fleet',
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
            ],
          ),
        ),
      ),
    );
  }

  // ── Progress Stepper ──
  Widget _stepper() {
    const labels = ['Business', 'Contact', 'Location'];
    const icons = [
      Icons.business_rounded,
      Icons.phone_rounded,
      Icons.pin_drop_rounded,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = i == _currentStep;
          final done = i < _currentStep;
          final color = done ? _green : (active ? _accent : _textSub);

          return Expanded(
            child: GestureDetector(
              onTap: () => _goStep(i),
              child: Column(
                children: [
                  // Dot / check
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (i > 0)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: done
                                ? _green.withValues(alpha: 0.5)
                                : _border,
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        width: active ? 38 : 32,
                        height: active ? 38 : 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? _green.withValues(alpha: 0.15)
                              : active
                              ? _accent.withValues(alpha: 0.15)
                              : _fieldBg,
                          border: Border.all(
                            color: done ? _green : (active ? _accent : _border),
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          done ? Icons.check_rounded : icons[i],
                          size: active ? 18 : 15,
                          color: color,
                        ),
                      ),
                      if (i < 2)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i < _currentStep
                                ? _green.withValues(alpha: 0.5)
                                : _border,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? _textPrimary : _textSub,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════
  // STEP 1: Business Info
  // ═══════════════════════════════════════
  Widget _step1Business() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          Icons.business_rounded,
          'Business Info',
          'Tell us about your company',
        ),
        const SizedBox(height: 18),

        _fieldCard(
          children: [
            _label('Company / Business Name'),
            const SizedBox(height: 10),
            _textField(
              ctrl: _companyNameCtrl,
              hint: 'e.g. Kumar Earthmovers Pvt Ltd',
              icon: Icons.domain_rounded,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 18),
            _label('Owner / Proprietor Name'),
            const SizedBox(height: 10),
            _textField(
              ctrl: _ownerNameCtrl,
              hint: 'e.g. Rajesh Kumar',
              icon: Icons.badge_rounded,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 18),
            _label('GSTIN (Optional)'),
            const SizedBox(height: 10),
            _textField(
              ctrl: _gstinCtrl,
              hint: '22AAAAA0000A1Z5',
              icon: Icons.receipt_long_rounded,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Benefits card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: _green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Provider Benefits',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _benefitRow('📍', 'Get discovered by hirers in your area'),
              _benefitRow('📊', 'Real-time booking & earnings dashboard'),
              _benefitRow('💰', 'Receive payments directly — no middlemen'),
              _benefitRow('⭐', 'Build ratings & grow your business'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _benefitRow(String emoji, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: _textSub,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════
  // STEP 2: Contact Details
  // ═══════════════════════════════════════
  Widget _step2Contact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          Icons.phone_rounded,
          'Contact Details',
          'How hirers will reach you',
        ),
        const SizedBox(height: 18),

        _fieldCard(
          children: [
            _label('Phone Number'),
            const SizedBox(height: 10),
            _textField(
              ctrl: _phoneCtrl,
              hint: '+91 98765 43210',
              icon: Icons.call_rounded,
              kb: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 18),
            _label('WhatsApp Number'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    ctrl: _whatsappCtrl,
                    hint: '+91 98765 43210',
                    icon: Icons.chat_rounded,
                    kb: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _whatsappCtrl.text = _phoneCtrl.text;
                    setState(() {});
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _accent.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.content_copy_rounded,
                      size: 18,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Info chip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: _blue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your WhatsApp number will be shown to hirers for quick contact. Tap the copy icon to use the same phone number.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textSub,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // STEP 3: Location
  // ═══════════════════════════════════════
  Widget _step3Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          Icons.pin_drop_rounded,
          'Service Area',
          'Where your equipment operates',
        ),
        const SizedBox(height: 18),

        _fieldCard(
          children: [
            _label('District / City'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDistrict,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedDistrict != null ? _accent : _border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city_rounded,
                      size: 20,
                      color: _selectedDistrict != null ? _accent : _textSub,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDistrict ?? 'Select your primary district',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _selectedDistrict != null
                              ? _textPrimary
                              : _textSub.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _textSub,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _label('Full Address'),
            const SizedBox(height: 10),
            _textField(
              ctrl: _addressCtrl,
              hint: 'Street, area, city, pincode',
              icon: Icons.home_work_rounded,
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // GPS card
        GestureDetector(
          onTap: () => _toast('GPS picker coming soon'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border, style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: _accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use Current Location',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        'Tap to auto-fill from GPS',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Soon',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Verification notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.security_rounded, color: _accent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Process',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'After registration, our team will verify your business details. You\'ll receive a confirmation within 24 hours.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _textSub,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── District picker ──
  void _pickDistrict() {
    final searchCtrl = TextEditingController();
    List<String> filtered = List.from(IndianDistricts.districts);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setBS) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.85,
          builder: (_, scrollCtrl) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  children: [
                    Text(
                      'Select District',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Search bar
                    TextField(
                      controller: searchCtrl,
                      onChanged: (q) {
                        setBS(() {
                          filtered = IndianDistricts.districts
                              .where(
                                (d) =>
                                    d.toLowerCase().contains(q.toLowerCase()),
                              )
                              .toList();
                        });
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search city or district...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: _textSub,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: _textSub,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: _fieldBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _accent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final d = filtered[i];
                    final sel = d == _selectedDistrict;
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: sel
                              ? _accent.withValues(alpha: 0.12)
                              : _fieldBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: sel ? _accent : _textSub,
                        ),
                      ),
                      title: Text(
                        d,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _textPrimary,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      trailing: sel
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: _accent,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedDistrict = d);
                        Navigator.pop(context);
                      },
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

  // ── Nav buttons ──
  Widget _navButtons() {
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => _goStep(_currentStep - 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textPrimary,
                  side: const BorderSide(color: _border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          flex: 2,
          child: _currentStep < 2
              ? SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _goStep(_currentStep + 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )
              : Consumer<ProviderRegistrationProvider>(
                  builder: (_, prov, __) => SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: prov.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        elevation: 0,
                        disabledBackgroundColor: _green.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: prov.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Submit Registration',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // SHARED COMPONENTS
  // ═══════════════════════════════════════

  Widget _sectionHeader(IconData icon, String title, String sub) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_accent, _accent2]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          Text(sub, style: GoogleFonts.poppins(fontSize: 12, color: _textSub)),
        ],
      ),
    ],
  );

  Widget _fieldCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Widget _label(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _textPrimary,
    ),
  );

  Widget _textField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType? kb,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: kb,
    validator: validator,
    maxLines: maxLines,
    style: GoogleFonts.poppins(fontSize: 14, color: _textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: _textSub.withValues(alpha: 0.5),
      ),
      prefixIcon: maxLines == 1 ? Icon(icon, color: _accent, size: 20) : null,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: maxLines > 1 ? 14 : 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    ),
  );
}
