import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/booking_model.dart';
import '../../models/professional_model.dart';
import '../../widgets/app_scaffold.dart';
import '../bookings/booking_detail_screen.dart';

class BookingSuccessScreen extends StatefulWidget {
  final Booking booking;
  final Professional professional;

  const BookingSuccessScreen({
    super.key,
    required this.booking,
    required this.professional,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppScaffold()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Check Circle
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppTheme.successGreenLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.successGreen,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppTheme.successGreen,
                          size: 56,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your home visit has been scheduled and confirmed with ${widget.professional.name}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Booking ID Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'BOOKING REFERENCE ID',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            b.id,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryTeal,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Summary Details Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Service', b.serviceTitle),
                          const Divider(height: 16),
                          _buildDetailRow('Professional', widget.professional.name),
                          const Divider(height: 16),
                          _buildDetailRow('Patient', '${b.patientName} (${b.patientAge}y)'),
                          const Divider(height: 16),
                          _buildDetailRow('Appointment', '${AppUtils.formatDate(b.date)}, ${b.timeSlot}'),
                          const Divider(height: 16),
                          _buildDetailRow('Total Paid / Due', 'Rs. ${b.price.toInt()} (Free Kit Inc.)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => BookingDetailScreen(bookingId: b.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('View Booking Timeline'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const AppScaffold()),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Return to Home Dashboard'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
