import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/country_model.dart';
import '../providers/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _obscure = true;
  late Country _country;

  late final AnimationController _entryCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  // ── Palette ──
  static const _bg = Colors.white;
  static const _surface = Color(0xFFF7F7F7);
  static const _accent = Color(0xFFFF6B00);
  static const _accent2 = Color(0xFFFFA040);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSub = Color(0xFF888888);
  static const _fieldBg = Color(0xFFF3F3F3);
  static const _border = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _country = CountryList.countries[0];

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
    _bodySlide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _entryCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().consumePreferOtpLoginMode();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _tabCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ── Auth actions (unchanged logic) ──
  Future<void> _sendOTP() async {
    if (_phoneCtrl.text.isEmpty) {
      _toast(tr('enter_phone_number'));
      return;
    }
    final full = _country.dialCode + _phoneCtrl.text.trim();
    final ok = await context.read<AuthProvider>().signInWithPhone(
      phoneNumber: full,
    );
    if (!mounted) return;
    if (!ok) _toast(context.read<AuthProvider>().errorMessage);
  }

  Future<void> _verifyOTP() async {
    if (_otpCtrl.text.isEmpty) {
      _toast(tr('enter_otp'));
      return;
    }
    final ok = await context.read<AuthProvider>().verifyOTP(
      otp: _otpCtrl.text.trim(),
    );
    if (!mounted) return;
    if (!ok) _toast(context.read<AuthProvider>().errorMessage);
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (!ok) _toast(context.read<AuthProvider>().errorMessage);
  }

  Future<void> _forgot() async {
    final em = _emailCtrl.text.trim();
    if (em.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(em)) {
      _toast(tr('enter_valid_email_first'));
      return;
    }
    final ok = await context.read<AuthProvider>().resetPassword(email: em);
    if (!mounted) return;
    if (ok) {
      _snack(
        tr('reset_link_sent').replaceFirst('{}', em),
        const Color(0xFF10B981),
      );
    } else {
      _toast(context.read<AuthProvider>().errorMessage);
    }
  }

  Future<void> _google() async {
    final ok = await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted) return;
    if (!ok) _toast(context.read<AuthProvider>().errorMessage);
  }

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

  void _snack(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              // ── Header ──
              SlideTransition(
                position: _headerSlide,
                child: FadeTransition(opacity: _headerFade, child: _header()),
              ),
              // ── Body ──
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
                              _tabBar(),
                              const SizedBox(height: 28),
                              Consumer<AuthProvider>(
                                builder: (_, auth, __) {
                                  return ListenableBuilder(
                                    listenable: _tabCtrl,
                                    builder: (_, __) => AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      switchInCurve: Curves.easeOut,
                                      switchOutCurve: Curves.easeIn,
                                      transitionBuilder: (child, anim) =>
                                          FadeTransition(
                                            opacity: anim,
                                            child: child,
                                          ),
                                      child: KeyedSubtree(
                                        key: ValueKey(_tabCtrl.index),
                                        child: _tabCtrl.index == 0
                                            ? _otpTab(auth)
                                            : _emailTab(auth),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 28),
                              _orDivider(),
                              const SizedBox(height: 24),
                              Consumer<AuthProvider>(
                                builder: (_, auth, __) =>
                                    _googleBtn(auth.isLoading),
                              ),
                              const SizedBox(height: 32),
                              _signupLink(),
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

  Widget _header() {
    return Container(
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
              // Greeting
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accent.withOpacity(0.15)),
                ),
                child: Text(
                  tr('welcome_back_emoji'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                tr('sign_in_to_account'),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr('continue_managing'),
                style: GoogleFonts.poppins(fontSize: 14, color: _textSub),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(colors: [_accent, _accent2]),
          ),
          child: const Icon(
            Icons.precision_manufacturing_rounded,
            size: 13,
            color: Colors.white,
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

  Widget _tabBar() => Container(
    height: 52,
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: TabBar(
      controller: _tabCtrl,
      indicator: BoxDecoration(
        gradient: const LinearGradient(colors: [_accent, _accent2]),
        borderRadius: BorderRadius.circular(13),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: _accent,
      unselectedLabelColor: _textSub,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(text: tr('phone_otp')),
        Tab(text: tr('email_tab')),
      ],
    ),
  );

  // ── OTP Tab ──
  Widget _otpTab(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!auth.isOtpSent) ...[
          _label(tr('mobile_number')),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: _pickCountry,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _fieldBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_country.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        _country.dialCode,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more, color: _textSub, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  ctrl: _phoneCtrl,
                  hint: '9876543210',
                  icon: Icons.phone_rounded,
                  kb: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tr('send_verification_code'),
            style: GoogleFonts.poppins(fontSize: 12, color: _textSub),
          ),
          const SizedBox(height: 20),
          _primaryBtn(
            label: tr('send_otp'),
            icon: Icons.send_rounded,
            loading: auth.isLoading,
            onTap: _sendOTP,
          ),
        ] else ...[
          // OTP sent state
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('otp_sent'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        tr('code_sent_to').replaceFirst(
                          '{}',
                          '${_country.dialCode} ${_phoneCtrl.text}',
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => auth.resetPhoneAuth(),
                  child: Text(
                    tr('change'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _label(tr('enter_6_digit_otp')),
          const SizedBox(height: 10),
          _field(
            ctrl: _otpCtrl,
            hint: '• • • • • •',
            icon: Icons.lock_clock_rounded,
            kb: TextInputType.number,
            maxLen: 6,
          ),
          const SizedBox(height: 20),
          _primaryBtn(
            label: tr('verify_sign_in'),
            icon: Icons.verified_rounded,
            loading: auth.isLoading,
            onTap: _verifyOTP,
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: auth.isLoading
                  ? null
                  : () => auth.resendOTP(
                      phoneNumber: _country.dialCode + _phoneCtrl.text.trim(),
                    ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 15,
                    color: _accent.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tr('resend_otp'),
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
      ],
    );
  }

  // ── Email Tab ──
  Widget _emailTab(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 18),
        _label(tr('password')),
        const SizedBox(height: 10),
        _field(
          ctrl: _passCtrl,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscure: _obscure,
          suffix: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: _textSub,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return tr('password_required');
            if (v.length < 6) return tr('minimum_6_characters');
            return null;
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: auth.isLoading ? null : _forgot,
            child: Text(
              tr('forgot_password'),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _accent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _primaryBtn(
          label: tr('sign_in'),
          icon: Icons.login_rounded,
          loading: auth.isLoading,
          onTap: _signIn,
        ),
      ],
    );
  }

  // ── Shared widgets ──
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
    int? maxLen,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: kb,
    obscureText: obscure,
    validator: validator,
    maxLength: maxLen,
    style: GoogleFonts.poppins(fontSize: 15, color: _textPrimary),
    decoration: InputDecoration(
      counterText: '',
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

  Widget _googleBtn(bool loading) => SizedBox(
    width: double.infinity,
    height: 56,
    child: OutlinedButton(
      onPressed: loading ? null : _google,
      style: OutlinedButton.styleFrom(
        backgroundColor: _surface,
        side: const BorderSide(color: _border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://developers.google.com/identity/images/g-logo.png',
            width: 22,
            height: 22,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.login, size: 22, color: _accent),
          ),
          const SizedBox(width: 12),
          Text(
            tr('continue_with_google'),
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

  Widget _signupLink() => Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          tr('dont_have_account'),
          style: GoogleFonts.poppins(fontSize: 14, color: _textSub),
        ),
        GestureDetector(
          onTap: () => context.read<AuthProvider>().goToSignUp(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tr('sign_up'),
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

  void _pickCountry() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      barrierColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final countries = CountryList.countries;
        return Column(
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.all(20),
              child: Text(
                tr('select_country'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ),
            SizedBox(
              height: 340,
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (_, i) {
                  final c = countries[i];
                  final sel = c.code == _country.code;
                  return ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      c.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _textPrimary,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    trailing: Text(
                      c.dialCode,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: sel ? _accent : _textSub,
                      ),
                    ),
                    selected: sel,
                    selectedTileColor: _accent.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      setState(() => _country = c);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
