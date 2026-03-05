import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
                tr('provider_will_respond'),
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
