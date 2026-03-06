import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/account_type.dart';
import '../providers/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _ob1 = true, _ob2 = true, _agreed = false;
  AccountType? _type;

  late final AnimationController _entryCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  // ── Palette ──
  static const _bg = Colors.white;
  static const _surface = Color(0xFFF7F7F7);
  static const _card = Color(0xFFFFFFFF);
  static const _accent = Color(0xFFFF6B00);
  static const _accent2 = Color(0xFFFFA040);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSub = Color(0xFF888888);
  static const _fieldBg = Color(0xFFF3F3F3);
  static const _border = Color(0xFFE0E0E0);

  // ── Role definitions ──
  static List<_Role> get _roles => <_Role>[
    _Role(
      type: AccountType.owner,
      icon: Icons.construction_rounded,
      label: tr('owner_role'),
      sub: tr('owner_role_desc'),
      color: const Color(0xFFFF6B00),
      bg: const Color(0xFF2A1E10),
      badge: tr('earn'),
      features: [
        tr('add_manage_equipment'),
        tr('accept_reject_bookings'),
        tr('earnings_dashboard'),
        tr('post_services'),
      ],
    ),
    _Role(
      type: AccountType.user,
      icon: Icons.engineering_rounded,
      label: tr('user_role'),
      sub: tr('user_role_desc'),
      color: const Color(0xFF3B82F6),
      bg: const Color(0xFF1E2A40),
      badge: tr('hire'),
      features: [
        tr('search_browse_equipment'),
        tr('book_equipment_instantly'),
        tr('track_booking_status'),
        tr('manage_your_bookings'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
          ),
        );
    _bodyFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _bodySlide = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _phoneCtrl.dispose();

    super.dispose();
  }

  // ── Actions ──
  Future<void> _signUp() async {
    if (_type == null) {
      _toast(tr('choose_account_type'));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      _toast(tr('agree_terms'));
      return;
    }
    // Phone verification is optional for now; proceed without OTP.
    final ok = await context.read<AuthProvider>().signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      accountType: _type!,
    );
    if (!mounted) return;
    if (!ok) {
      final msg = context.read<AuthProvider>().errorMessage ?? 'Sign up failed';
      if (msg.contains('already exists') || msg.contains('already in use')) {
        _showDupDialog();
      } else {
        _toast(msg);
      }
      return;
    }

    // Previously we linked phone credentials here; skipping for now.
  }

  Future<void> _google() async {
    final ok = await context.read<AuthProvider>().signUpWithGoogle();
    if (!mounted) return;
    if (!ok) _toast(context.read<AuthProvider>().errorMessage);
  }

  void _phone() => context.read<AuthProvider>().goToLogin(preferOtpMode: true);

  void _toast(String? m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          m ?? tr('something_went_wrong'),
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDupDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent.withOpacity(0.1),
                  border: Border.all(color: _accent.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: _accent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                tr('already_registered'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                tr('already_registered_msg'),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _textSub,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _emailCtrl.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    tr('try_another_email'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AuthProvider>().goToLogin();
                },
                child: Text(
                  tr('go_to_sign_in'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: AnimatedBuilder(
          animation: _entryCtrl,
          builder: (context, _) => Column(
            children: [
              SlideTransition(
                position: _headerSlide,
                child: FadeTransition(opacity: _headerFade, child: _header()),
              ),
              Expanded(
                child: SlideTransition(
                  position: _bodySlide,
                  child: FadeTransition(
                    opacity: _bodyFade,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Step 1: Role ──
                              _stepHeader('1', tr('i_am_a')),
                              const SizedBox(height: 14),
                              ..._roles.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _roleCard(r),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Step 2: Details ──
                              _stepHeader('2', tr('your_details')),
                              const SizedBox(height: 14),
                              _detailsCard(),
                              const SizedBox(height: 22),

                              // ── Terms ──
                              _termsRow(),
                              const SizedBox(height: 28),

                              // ── Create account ──
                              Consumer<AuthProvider>(
                                builder: (_, auth, __) => _primaryBtn(
                                  label: tr('create_account'),
                                  icon: Icons.person_add_rounded,
                                  loading: auth.isLoading,
                                  onTap: _signUp,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _orDivider(),
                              const SizedBox(height: 20),

                              // ── Social ──
                              Consumer<AuthProvider>(
                                builder: (_, auth, __) => Column(
                                  children: [
                                    _socialBtn(
                                      onTap: auth.isLoading ? null : _google,
                                      isGoogle: true,
                                      label: tr('sign_up_with_google'),
                                    ),
                                    const SizedBox(height: 10),
                                    _socialBtn(
                                      onTap: auth.isLoading ? null : _phone,
                                      icon: Icons.phone_iphone_rounded,
                                      label: tr('sign_up_with_phone'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _signInLink(),
                            ],
                          ),
                        ),
                      ),
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

  // ── Header ──
  Widget _header() => Container(
    color: _bg,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _backBtn(() => context.read<AuthProvider>().goToOnboarding()),
                const Spacer(),
                _logoChip(),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withOpacity(0.15)),
              ),
              child: Text(
                tr('get_started'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              tr('create_your_account'),
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('join_professionals'),
              style: GoogleFonts.poppins(fontSize: 14, color: _textSub),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _backBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: _accent),
    ),
  );

  Widget _logoChip() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Image.asset(
            'assets/images/app_logo.jpeg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          tr('equippro'),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ],
    ),
  );

  // ── Role card ──
  Widget _roleCard(_Role r) {
    final sel = _type == r.type;
    return GestureDetector(
      onTap: () => setState(() => _type = r.type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? r.color.withOpacity(0.08) : _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: sel ? r.color : _border,
            width: sel ? 2 : 1,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: r.color.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: sel ? r.color.withOpacity(0.15) : _fieldBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    r.icon,
                    color: sel ? r.color : _textSub,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            r.label,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: r.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              r.badge,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: r.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        r.sub,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? r.color : Colors.transparent,
                    border: Border.all(
                      color: sel ? r.color : _border,
                      width: 2,
                    ),
                  ),
                  child: sel
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            if (r.features.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...r.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: sel ? r.color : _textSub.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: sel ? _textPrimary : _textSub,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Details card ──
  Widget _detailsCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(tr('full_name')),
        const SizedBox(height: 10),
        _field(
          ctrl: _nameCtrl,
          hint: 'Rajesh Kumar',
          icon: Icons.person_outline_rounded,
          validator: (v) {
            if (v == null || v.isEmpty) return tr('name_required');
            if (v.length < 2) return tr('minimum_2_characters');
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label(tr('email_address')),
        const SizedBox(height: 10),
        _field(
          ctrl: _emailCtrl,
          hint: 'you@company.com',
          icon: Icons.alternate_email_rounded,
          kb: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return tr('email_required');
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
              return tr('enter_valid_email');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label(tr('password')),
        const SizedBox(height: 10),
        _field(
          ctrl: _passCtrl,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscure: _ob1,
          suffix: IconButton(
            icon: Icon(
              _ob1 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: _textSub,
            ),
            onPressed: () => setState(() => _ob1 = !_ob1),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return tr('password_required');
            if (v.length < 6) return tr('minimum_6_characters');
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label(tr('confirm_password')),
        const SizedBox(height: 10),
        _field(
          ctrl: _confirmCtrl,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscure: _ob2,
          suffix: IconButton(
            icon: Icon(
              _ob2 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
              color: _textSub,
            ),
            onPressed: () => setState(() => _ob2 = !_ob2),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return tr('please_confirm_password');
            if (v != _passCtrl.text) return tr('passwords_not_match');
            return null;
          },
        ),
      ],
    ),
  );

  // ── Terms ──
  Widget _termsRow() => GestureDetector(
    onTap: () => setState(() => _agreed = !_agreed),
    child: Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _agreed ? _accent : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: _agreed ? _accent : _border, width: 2),
          ),
          child: _agreed
              ? const Icon(Icons.check, size: 15, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: tr('agree_to'),
              style: GoogleFonts.poppins(fontSize: 13, color: _textSub),
              children: [
                TextSpan(
                  text: tr('terms_conditions'),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // ── Shared widgets ──
  Widget _stepHeader(String num, String title) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_accent, _accent2]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            num,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
    ],
  );

  Widget _label(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _textPrimary,
    ),
  );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType? kb,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: kb,
    obscureText: obscure,
    validator: validator,
    style: GoogleFonts.poppins(fontSize: 15, color: _textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: _textSub.withValues(alpha: 0.5),
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, color: _accent, size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    ),
  );

  Widget _primaryBtn({
    required String label,
    required IconData icon,
    required bool loading,
    required VoidCallback onTap,
  }) => SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        disabledBackgroundColor: _accent.withOpacity(0.4),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: loading
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
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    ),
  );

  Widget _orDivider() => Row(
    children: [
      Expanded(child: Container(height: 1, color: _border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tr('or_divider'),
            style: GoogleFonts.poppins(fontSize: 12, color: _textSub),
          ),
        ),
      ),
      Expanded(child: Container(height: 1, color: _border)),
    ],
  );

  Widget _socialBtn({
    required String label,
    bool isGoogle = false,
    IconData? icon,
    VoidCallback? onTap,
  }) => SizedBox(
    width: double.infinity,
    height: 54,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: _surface,
        side: const BorderSide(color: _border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGoogle)
            Image.network(
              'https://developers.google.com/identity/images/g-logo.png',
              width: 22,
              height: 22,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.login, size: 22, color: _accent),
            )
          else
            Icon(icon, color: _accent, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _signInLink() => Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          tr('already_have_account'),
          style: GoogleFonts.poppins(fontSize: 14, color: _textSub),
        ),
        GestureDetector(
          onTap: () => context.read<AuthProvider>().goToLogin(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tr('sign_in'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Role data class ──
class _Role {
  final AccountType type;
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final Color bg;
  final String badge;
  final List<String> features;
  const _Role({
    required this.type,
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.bg,
    required this.badge,
    this.features = const [],
  });
}
