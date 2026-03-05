import 'package:flutter/material.dart';
import '../../../core/utils/safe_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/booking_model.dart';
import '../services/booking_service.dart';

/// Provider's booking management screen - view & manage incoming bookings
class ProviderBookingsScreen extends StatefulWidget {
  final String providerId;

  /// If true, renders as an embedded tab (no AppBar back button)
  final bool embedded;

  const ProviderBookingsScreen({
    super.key,
    required this.providerId,
    this.embedded = false,
  });

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends SafeState<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _accent = Color(0xFFFF6B00);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _bg = Color(0xFFFAFAFC);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadProviderBookings(widget.providerId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: _dark,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'Booking Requests',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _accent,
          unselectedLabelColor: _sub,
          indicatorColor: _accent,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Done'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (_, bp, __) {
          if (bp.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _bookingList(
                bp.providerBookings
                    .where((b) => b.status == BookingStatus.pending)
                    .toList(),
              ),
              _bookingList(
                bp.providerBookings
                    .where(
                      (b) =>
                          b.status == BookingStatus.approved ||
                          b.status == BookingStatus.inProgress,
                    )
                    .toList(),
              ),
              _bookingList(
                bp.providerBookings
                    .where(
                      (b) =>
                          b.status == BookingStatus.completed ||
                          b.status == BookingStatus.cancelled ||
                          b.status == BookingStatus.rejected,
                    )
                    .toList(),
              ),
              _bookingList(bp.providerBookings),
            ],
          );
        },
      ),
    );
  }

  Widget _bookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 64,
              color: _sub.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No bookings yet',
              style: GoogleFonts.poppins(fontSize: 16, color: _sub),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => context.read<BookingProvider>().loadProviderBookings(
        widget.providerId,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _bookingCard(bookings[i]),
      ),
    );
  }

  Widget _bookingCard(BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.equipmentName.isEmpty
                      ? 'Equipment Booking'
                      : booking.equipmentName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status.value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.person_outline, booking.userName),
          _infoRow(Icons.phone_outlined, booking.userPhone),
          _infoRow(
            Icons.calendar_today_rounded,
            '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
          ),
          _infoRow(Icons.timer_outlined, '${booking.durationHours} hours'),
          _infoRow(Icons.location_on_outlined, booking.locationAddress),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${booking.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _accent,
                ),
              ),
              Text(
                'You earn: ₹${booking.providerAmount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(
                      booking.id,
                      BookingStatus.rejected,
                      'Rejected by provider',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateStatus(booking.id, BookingStatus.approved),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (booking.status == BookingStatus.approved) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _updateStatus(booking.id, BookingStatus.completed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Mark Completed',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _sub),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: _sub),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    String bookingId,
    BookingStatus status, [
    String? reason,
  ]) async {
    final bp = context.read<BookingProvider>();
    final ok = await bp.updateStatus(bookingId, status, reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (status == BookingStatus.completed
                    ? 'Booking marked as completed!'
                    : status == BookingStatus.approved
                    ? 'Booking accepted!'
                    : status == BookingStatus.rejected
                    ? 'Booking rejected'
                    : 'Status updated!')
              : bp.errorMessage ?? 'Update failed',
        ),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.approved:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.indigo;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.grey;
      case BookingStatus.rejected:
        return Colors.red;
    }
  }
}
