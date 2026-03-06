import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../booking/services/booking_service.dart';

/// Booking creation screen
class CreateBookingScreen extends StatefulWidget {
  final String equipmentId;
  final String equipmentName;
  final String machineType;
  final String providerId;
  final String providerName;
  final double hourlyRate;

  const CreateBookingScreen({
    super.key,
    required this.equipmentId,
    required this.equipmentName,
    required this.machineType,
    required this.providerId,
    required this.providerName,
    required this.hourlyRate,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '8');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _bg = Color(0xFFFAFAFC);
  static const _fieldBg = Color(0xFFF5F5F8);
  static const _border = Color(0xFFEEEEF2);

  double get _totalAmount =>
      widget.hourlyRate * (int.tryParse(_hoursCtrl.text) ?? 0);
  double get _commission => _totalAmount * 0.05;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: _accent)),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _book() async {
    if (!_formKey.currentState!.validate()) return;

    final bookingProvider = context.read<BookingProvider>();
    final ok = await bookingProvider.createBooking(
      equipmentId: widget.equipmentId,
      equipmentName: widget.equipmentName,
      machineType: widget.machineType,
      providerId: widget.providerId,
      providerName: widget.providerName,
      userName: _nameCtrl.text.trim(),
      userPhone: _phoneCtrl.text.trim(),
      bookingDate: _selectedDate,
      latitude: 19.0760,
      longitude: 72.8777,
      locationAddress: _addressCtrl.text.trim(),
      durationHours: int.tryParse(_hoursCtrl.text) ?? 8,
      hourlyRate: widget.hourlyRate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      // Show payment gateway sheet
      final paid = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => _BookingPaymentSheet(
          totalAmount: _totalAmount,
          equipmentName: widget.equipmentName,
        ),
      );
      if (!mounted) return;
      if (paid == true) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  tr('booking_confirmed'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment submitted! Provider will respond soon.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: _sub),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context, true); // go back
                },
                child: Text(
                  tr('ok'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? tr('booking_failed')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale; // rebuild on locale change
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
          tr('book_equipment'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Equipment summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        size: 28,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.equipmentName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                            ),
                          ),
                          Text(
                            '${widget.machineType} • ₹${widget.hourlyRate.toStringAsFixed(0)}/hr',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _sub,
                            ),
                          ),
                          Text(
                            'by ${widget.providerName}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Your Name
              _label(tr('your_name_label')),
              const SizedBox(height: 8),
              _field(
                ctrl: _nameCtrl,
                hint: tr('full_name_hint'),
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? tr('name_required') : null,
              ),
              const SizedBox(height: 20),

              // Phone
              _label(tr('phone_label')),
              const SizedBox(height: 8),
              _field(
                ctrl: _phoneCtrl,
                hint: '+91 98765 43210',
                icon: Icons.phone_outlined,
                kb: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? tr('phone_required') : null,
              ),
              const SizedBox(height: 20),

              // Date
              _label(tr('booking_date')),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: _fieldBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: _accent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: GoogleFonts.poppins(fontSize: 15, color: _dark),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.edit_calendar_rounded,
                        color: _sub,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Duration
              _label(tr('duration_hours')),
              const SizedBox(height: 8),
              _field(
                ctrl: _hoursCtrl,
                hint: '8',
                icon: Icons.timer_outlined,
                kb: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return tr('duration_required');
                  if (int.tryParse(v) == null || int.parse(v) < 1) {
                    return tr('enter_valid_hours');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location
              _label(tr('site_address')),
              const SizedBox(height: 8),
              _field(
                ctrl: _addressCtrl,
                hint: tr('site_address_hint'),
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? tr('address_required') : null,
              ),
              const SizedBox(height: 20),

              // Notes
              _label(tr('additional_notes')),
              const SizedBox(height: 8),
              _field(
                ctrl: _notesCtrl,
                hint: tr('special_requirements_hint'),
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Price breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accent.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _priceRow(
                      tr('rate'),
                      '₹${widget.hourlyRate.toStringAsFixed(0)}/hr',
                    ),
                    _priceRow(tr('duration'), '${_hoursCtrl.text} hours'),
                    const Divider(height: 24),
                    _priceRow(
                      tr('total_amount'),
                      '₹${_totalAmount.toStringAsFixed(0)}',
                      bold: true,
                    ),
                    _priceRow(
                      tr('platform_fee'),
                      '₹${_commission.toStringAsFixed(0)}',
                      color: _sub,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Book Button
              Consumer<BookingProvider>(
                builder: (_, bp, __) => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: bp.isLoading ? null : _book,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: bp.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            '${tr('confirm_booking')} • ₹${_totalAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? _dark,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? (bold ? _accent : _dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _dark,
    ),
  );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType? kb,
    String? Function(String?)? validator,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: kb,
    validator: validator,
    maxLines: maxLines,
    onChanged: onChanged,
    style: GoogleFonts.poppins(fontSize: 15, color: _dark),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: _sub.withValues(alpha: 0.5),
      ),
      prefixIcon: Icon(icon, color: _accent, size: 20),
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// BOOKING PAYMENT SHEET — UPI / Bank / Card
// ═══════════════════════════════════════════════════════════════
class _BookingPaymentSheet extends StatefulWidget {
  final double totalAmount;
  final String equipmentName;
  const _BookingPaymentSheet({
    required this.totalAmount,
    required this.equipmentName,
  });

  @override
  State<_BookingPaymentSheet> createState() => _BookingPaymentSheetState();
}

class _BookingPaymentSheetState extends State<_BookingPaymentSheet> {
  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _green = Color(0xFF00C853);

  int _step = 0; // 0 = payment form, 1 = success
  bool _loading = false;
  final _utrCtrl = TextEditingController();
  String? _utrError;
  String _selectedMethod = 'upi';

  final _cardNumCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  @override
  void dispose() {
    _utrCtrl.dispose();
    _cardNumCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  String get _formattedAmount => '₹${widget.totalAmount.toStringAsFixed(0)}';

  Future<void> _confirmPayment() async {
    final utr = _utrCtrl.text.trim();
    if (utr.length < 6) {
      setState(
        () => _utrError =
            'Enter a valid transaction / UTR reference (min 6 chars)',
      );
      return;
    }
    setState(() {
      _loading = true;
      _utrError = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('payments')
            .add({
              'amount': widget.totalAmount,
              'equipmentName': widget.equipmentName,
              'method': _selectedMethod,
              'utr': utr,
              'status': 'pending',
              'type': 'booking',
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _step = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _utrError = 'Could not record payment. Please try again.';
      });
    }
  }

  Future<void> _launchUpiApp(String appUri) async {
    final uri = Uri.parse(appUri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final amt = widget.totalAmount.toStringAsFixed(0);
      final genericUpi =
          'upi://pay?pa=vishalkhadatare1-1@okicici&pn=SEEMP+Platform&am=$amt&cu=INR&tn=BookingPayment';
      final fallback = Uri.parse(genericUpi);
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'App not installed. Please pay via UPI ID: vishalkhadatare1-1@okicici and enter UTR below.',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: _step == 0 ? _buildPaymentStep() : _buildSuccessStep(),
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: _accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Payment',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _dark,
                      ),
                    ),
                    Text(
                      widget.equipmentName,
                      style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formattedAmount,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Method selector tabs
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F8),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _methodChip('upi', Icons.account_balance_wallet_rounded, 'UPI'),
                _methodChip('bank', Icons.account_balance_rounded, 'Bank'),
                _methodChip('card', Icons.credit_card_rounded, 'Card'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedMethod == 'upi') ..._upiContent(),
          if (_selectedMethod == 'bank') ..._bankContent(),
          if (_selectedMethod == 'card') ..._cardContent(),
          const SizedBox(height: 16),
          // UTR / Reference input
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: _accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Enter Transaction / UTR Reference',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _utrCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. 425678901234',
                    hintStyle: GoogleFonts.poppins(color: _sub, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _accent, width: 1.5),
                    ),
                    errorText: _utrError,
                    prefixIcon: const Icon(
                      Icons.tag_rounded,
                      size: 18,
                      color: _accent,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: _loading
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFFF6B00), Color(0xFFFF9A44)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: _loading ? _accent.withValues(alpha: 0.5) : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _loading
                      ? []
                      : [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pay $_formattedAmount & Confirm',
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_rounded, size: 12, color: _sub),
              const SizedBox(width: 4),
              Text(
                '256-bit secured · Verified within 24 hrs',
                style: GoogleFonts.poppins(fontSize: 11, color: _sub),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _methodChip(String method, IconData icon, String label) {
    final selected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? _accent : _sub),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? _accent : _sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── UPI Content ───────────────────────────────────────────────
  List<Widget> _upiContent() {
    const upiId = 'vishalkhadatare1-1@okicici';
    final amt = widget.totalAmount.toStringAsFixed(0);
    final baseParams =
        'pa=$upiId&pn=SEEMP+Platform&am=$amt&cu=INR&tn=BookingPayment';

    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _accent.withValues(alpha: 0.08),
              _accent.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 26,
                color: _accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPI ID',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _sub,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    upiId,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C853),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SEEMP Platform · $_formattedAmount',
                        style: GoogleFonts.poppins(fontSize: 11, color: _sub),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Pay via UPI App',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _upiAppButton(
              label: 'PhonePe',
              imagePath: 'assets/images/phonepe_icon.png',
              bgColor: const Color(0xFF5F259F),
              uri: 'phonepe://pay?$baseParams',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _upiAppButton(
              label: 'GPay',
              imagePath: 'assets/images/gpay_icon.png',
              bgColor: Colors.white,
              uri: 'tez://upi/pay?$baseParams',
              hasBorder: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _upiAppButton(
              label: 'Paytm',
              imagePath: 'assets/images/paytm_icon.png',
              bgColor: const Color(0xFF002970),
              uri: 'paytmmp://pay?$baseParams',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchUpiApp('upi://pay?$baseParams'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accent, _accent.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Any UPI',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 14, color: _sub),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Tap an app to pay $_formattedAmount directly. Enter UTR below after payment.',
                style: GoogleFonts.poppins(fontSize: 11, color: _sub),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _upiAppButton({
    required String label,
    required String imagePath,
    required Color bgColor,
    required String uri,
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: () => _launchUpiApp(uri),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: hasBorder
              ? Border.all(color: const Color(0xFFE0E0E0), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: bgColor == Colors.white
                  ? Colors.black.withValues(alpha: 0.08)
                  : bgColor.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => Icon(
                Icons.payment_rounded,
                size: 28,
                color: hasBorder ? _dark : Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: hasBorder ? _dark : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Bank Transfer Content ─────────────────────────────────────
  List<Widget> _bankContent() {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            _bankRow('Bank Name', 'State Bank of India'),
            const SizedBox(height: 8),
            _bankRow('Account Number', '1234 5678 9012'),
            const SizedBox(height: 8),
            _bankRow('IFSC Code', 'SBIN0001234'),
            const SizedBox(height: 8),
            _bankRow('Account Name', 'SEEMP Technologies Pvt Ltd'),
            const SizedBox(height: 8),
            _bankRow('Amount', _formattedAmount),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Transfer $_formattedAmount and enter UTR/reference number below:',
        style: GoogleFonts.poppins(fontSize: 12, color: _sub),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _bankRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: _sub)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _dark,
          ),
        ),
      ],
    );
  }

  // ── Credit / Debit Card Content ───────────────────────────────
  List<Widget> _cardContent() {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF3A3A5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SEEMP',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _cardNumCtrl.text.isEmpty
                  ? '•••• •••• •••• ••••'
                  : _cardNumCtrl.text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD HOLDER',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: Colors.white54,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      _cardNameCtrl.text.isEmpty
                          ? 'YOUR NAME'
                          : _cardNameCtrl.text.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EXPIRES',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: Colors.white54,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      _cardExpiryCtrl.text.isEmpty
                          ? 'MM/YY'
                          : _cardExpiryCtrl.text,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _cardField(
        _cardNumCtrl,
        'Card Number',
        '1234 5678 9012 3456',
        TextInputType.number,
        maxLen: 19,
      ),
      const SizedBox(height: 10),
      _cardField(
        _cardNameCtrl,
        'Cardholder Name',
        'John Doe',
        TextInputType.name,
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _cardField(
              _cardExpiryCtrl,
              'Expiry (MM/YY)',
              'MM/YY',
              TextInputType.datetime,
              maxLen: 5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _cardField(
              _cardCvvCtrl,
              'CVV',
              '•••',
              TextInputType.number,
              maxLen: 3,
              obscure: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, size: 15, color: _accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Card payments are verified manually. After paying, enter the bank transaction reference number below.',
                style: GoogleFonts.poppins(fontSize: 11, color: _accent),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _cardField(
    TextEditingController ctrl,
    String label,
    String hint,
    TextInputType type, {
    int? maxLen,
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      maxLength: maxLen,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(fontSize: 12, color: _sub),
        hintStyle: GoogleFonts.poppins(color: _sub, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFFF5F5F8),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 13, color: _dark),
    );
  }

  // ── Success Step ──────────────────────────────────────────────
  Widget _buildSuccessStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: _green,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Payment Submitted!',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your $_formattedAmount payment has been recorded.\nIt will be verified within 24 hours.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: _sub, height: 1.5),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Done',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
