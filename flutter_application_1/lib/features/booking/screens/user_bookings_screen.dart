import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/booking_model.dart';
import '../services/booking_service.dart';

/// User's booking screen — shows bookings where current user is the CUSTOMER
class UserBookingsScreen extends StatefulWidget {
  /// If true, renders as an embedded tab (no AppBar back button)
  final bool embedded;
  const UserBookingsScreen({super.key, this.embedded = false});

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _accent = Color(0xFF3B82F6);
  static const _dark = Color(0xFF1A1A2E);
  static const _sub = Color(0xFF8F90A6);
  static const _bg = Color(0xFFFAFAFC);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadUserBookings();
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
          'My Bookings',
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

          final bookings = bp.userBookings;
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _bookingList(
                bookings
                    .where((b) => b.status == BookingStatus.pending)
                    .toList(),
              ),
              _bookingList(
                bookings
                    .where(
                      (b) =>
                          b.status == BookingStatus.approved ||
                          b.status == BookingStatus.inProgress,
                    )
                    .toList(),
              ),
              _bookingList(
                bookings
                    .where(
                      (b) =>
                          b.status == BookingStatus.completed ||
                          b.status == BookingStatus.cancelled ||
                          b.status == BookingStatus.rejected,
                    )
                    .toList(),
              ),
              _bookingList(bookings),
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
      onRefresh: () => context.read<BookingProvider>().loadUserBookings(),
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
          // Equipment name + status badge
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
          if (booking.machineType.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              booking.machineType,
              style: GoogleFonts.poppins(fontSize: 12, color: _sub),
            ),
          ],
          const SizedBox(height: 8),
          _infoRow(Icons.business_rounded, 'Provider: ${booking.providerName}'),
          _infoRow(
            Icons.calendar_today_rounded,
            '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
          ),
          _infoRow(Icons.timer_outlined, '${booking.durationHours} hours'),
          _infoRow(Icons.location_on_outlined, booking.locationAddress),
          const SizedBox(height: 10),
          // Total amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _dark,
                  ),
                ),
                Text(
                  '₹${booking.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _accent,
                  ),
                ),
              ],
            ),
          ),
          // Cancel button for pending bookings
          if (booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _cancelBooking(booking.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel Booking',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          // Status message for non-pending bookings
          if (booking.status == BookingStatus.approved) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Approved by owner — equipment is ready',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ],
          if (booking.status == BookingStatus.rejected) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.cancel_rounded, size: 18, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Rejected by owner',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (booking.status == BookingStatus.completed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  'Completed',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
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

  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel this booking?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final ok = await context.read<BookingProvider>().updateStatus(
      bookingId,
      BookingStatus.cancelled,
      reason: 'Cancelled by user',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Booking cancelled' : 'Failed to cancel'),
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
