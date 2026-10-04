import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/status_chip.dart';
import 'booking_detail_screen.dart';
import '../reviews/write_review_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCancelConfirmation(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Appointment?'),
        content: Text(
          'Are you sure you want to cancel the appointment for ${booking.patientName} with ${booking.professionalName} on ${AppUtils.formatDate(booking.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final prov = Provider.of<BookingProvider>(context, listen: false);
              await prov.cancelBooking(booking.id);
              if (context.mounted) {
                AppUtils.showToast(context, 'Booking cancelled successfully');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emergencyRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, Booking booking) {
    DateTime newDate = booking.date.add(const Duration(days: 1));
    String newSlot = booking.timeSlot;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Reschedule Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current: ${AppUtils.formatDate(booking.date)} (${booking.timeSlot})',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              const Text('Select New Date:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: newDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setDialogState(() => newDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(AppUtils.formatDate(newDate)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Select New Time Slot:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: newSlot,
                items: [
                  '08:00 AM - 09:00 AM',
                  '10:00 AM - 11:00 AM',
                  '02:00 PM - 03:00 PM',
                  '04:00 PM - 05:00 PM',
                  '06:00 PM - 07:00 PM',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) => setDialogState(() => newSlot = val!),
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prov = Provider.of<BookingProvider>(context, listen: false);
                final res = await prov.rescheduleBooking(
                  bookingId: booking.id,
                  newDate: newDate,
                  newTimeSlot: newSlot,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  AppUtils.showToast(
                    context,
                    res['message'],
                    isSuccess: res['success'] == true,
                    isError: res['success'] == false,
                  );
                }
              },
              child: const Text('Confirm Reschedule'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingProv = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Appointments & Bookings'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryTeal,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'Upcoming (${bookingProv.upcomingBookings.length})'),
            Tab(text: 'Completed (${bookingProv.completedBookings.length})'),
            Tab(text: 'Cancelled (${bookingProv.cancelledBookings.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(bookingProv.upcomingBookings, isUpcoming: true),
          _buildBookingsList(bookingProv.completedBookings, isCompleted: true),
          _buildBookingsList(bookingProv.cancelledBookings, isCancelled: true),
        ],
      ),
    );
  }

  Widget _buildBookingsList(
    List<Booking> bookings, {
    bool isUpcoming = false,
    bool isCompleted = false,
    bool isCancelled = false,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'No upcoming appointments'
                  : (isCompleted
                      ? 'No completed appointments yet'
                      : 'No cancelled appointments'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Home healthcare visits will show up here.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Service Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b.id,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    StatusChip(status: b.status, isSmall: true),
                  ],
                ),
                const SizedBox(height: 10),

                // Professional Info
                Row(
                  children: [
                    CustomNetworkImage(
                      imageUrl: b.professionalPhoto,
                      fallbackText: b.professionalName,
                      width: 50,
                      height: 50,
                      isCircle: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.serviceTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${b.professionalName} • ${b.professionalRole}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Date, Time, Patient
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 15, color: AppTheme.primaryTeal),
                    const SizedBox(width: 6),
                    Text(
                      AppUtils.formatDate(b.date),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time, size: 15, color: AppTheme.primaryTeal),
                    const SizedBox(width: 6),
                    Text(
                      b.timeSlot,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 15, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      'Patient: ${b.patientName} (${b.patientAge}y)',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    Text(
                      PricingCalculator.formatCurrency(b.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Card Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingDetailScreen(bookingId: b.id),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('View Timeline & Details'),
                      ),
                    ),
                    if (isUpcoming) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_calendar, size: 20, color: AppTheme.primaryTeal),
                        tooltip: 'Reschedule',
                        onPressed: () => _showRescheduleDialog(context, b),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppTheme.emergencyRed),
                        tooltip: 'Cancel',
                        onPressed: () => _showCancelConfirmation(context, b),
                      ),
                    ],
                    if (isCompleted && !b.hasReview) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WriteReviewScreen(
                                professionalId: b.professionalId,
                                professionalName: b.professionalName,
                                bookingId: b.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text('Review'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
