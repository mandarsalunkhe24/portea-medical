import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/status_chip.dart';
import '../service_completion/service_completion_screen.dart';
import '../reviews/write_review_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  static const List<String> _stages = [
    'Booked',
    'Professional Assigned',
    'On the way',
    'In Progress',
    'Completed',
  ];

  void _showInvoiceDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long, color: AppTheme.primaryTeal),
            SizedBox(width: 8),
            Text('Official Tax Invoice'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PORTEA MEDICAL - HOME HEALTHCARE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              const Text('GSTIN: 27AABCP9042K1Z8 | SAC: 999312'),
              const Divider(height: 16),
              _buildInvoiceLine('Invoice No:', 'INV-${booking.id}'),
              _buildInvoiceLine('Date:', AppUtils.formatDate(booking.date)),
              _buildInvoiceLine('Patient:', '${booking.patientName} (${booking.patientAge}y)'),
              _buildInvoiceLine('Service:', booking.serviceTitle),
              _buildInvoiceLine('Professional:', booking.professionalName),
              const Divider(height: 16),
              _buildInvoiceLine('Visit Fee:', PricingCalculator.formatCurrency(booking.price)),
              _buildInvoiceLine('Consumables Kit:', 'Rs. 0 (Inclusive)'),
              _buildInvoiceLine('CGST (9%) + SGST (9%):', 'Included in visit fee'),
              const Divider(height: 16),
              _buildInvoiceLine('Total Amount Paid:', PricingCalculator.formatCurrency(booking.price), isBold: true),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successGreenLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: AppTheme.successGreen, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Payment Verified & Cleared',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              AppUtils.showToast(
                context,
                'Invoice summary copied & simulated for download/insurance',
                isSuccess: true,
              );
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download / Share'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceLine(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingProv = Provider.of<BookingProvider>(context);
    final booking = bookingProv.getBookingById(bookingId);

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointment Details')),
        body: const Center(child: Text('Appointment record not found.')),
      );
    }

    final currentStageIndex = _stages.indexOf(booking.status);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(booking.id),
        actions: [
          IconButton(
            tooltip: 'Tax Invoice',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => _showInvoiceDialog(context, booking),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Simulation Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Appointment Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      StatusChip(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Interactive Timeline Stepper
                  _buildTimeline(context, currentStageIndex),
                  const SizedBox(height: 14),

                  // Demo simulation trigger
                  if (booking.status != 'Completed' && booking.status != 'Cancelled') ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Demo Workflow Simulator:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (currentStageIndex < _stages.length - 1) {
                              final next = _stages[currentStageIndex + 1];
                              if (next == 'Completed') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ServiceCompletionScreen(
                                      booking: booking,
                                    ),
                                  ),
                                );
                              } else {
                                bookingProv.updateBookingStatus(booking.id, next);
                              }
                            }
                          },
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: Text(
                            currentStageIndex == _stages.length - 2
                                ? 'Complete Service'
                                : 'Next Stage',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Service Completion Evidence Section (if available)
            if (booking.evidence != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.successGreen.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppTheme.successGreen, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Clinical Service Evidence & Vitals',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Photo Evidence
                    if (booking.evidence!.photoPath != null &&
                        booking.evidence!.photoPath!.isNotEmpty) ...[
                      const Text(
                        'Completion Photo / Clinical Consumable Proof:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomNetworkImage(
                          imageUrl: booking.evidence!.photoPath!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Vitals Record
                    const Text(
                      'Recorded Patient Vitals:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildVitalBadge(
                          'Blood Pressure',
                          booking.evidence!.bloodPressure.isNotEmpty
                              ? booking.evidence!.bloodPressure
                              : '120/80 mmHg',
                          Icons.favorite,
                        ),
                        const SizedBox(width: 8),
                        _buildVitalBadge(
                          'Pulse Rate',
                          booking.evidence!.pulseRate.isNotEmpty
                              ? booking.evidence!.pulseRate
                              : '72 bpm',
                          Icons.monitor_heart,
                        ),
                        const SizedBox(width: 8),
                        _buildVitalBadge(
                          'Temp',
                          booking.evidence!.temperature.isNotEmpty
                              ? booking.evidence!.temperature
                              : '98.6 °F',
                          Icons.thermostat,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Clinical Notes
                    if (booking.evidence!.notes.isNotEmpty) ...[
                      Text(
                        'Professional Notes: ${booking.evidence!.notes}',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Dual Signature / Confirmation
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Nurse / Clinician Confirmed',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Patient / Family Signed',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Professional Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Medical Professional',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        CustomNetworkImage(
                          imageUrl: booking.professionalPhoto,
                          fallbackText: booking.professionalName,
                          width: 54,
                          height: 54,
                          isCircle: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.professionalName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                booking.professionalRole,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, color: AppTheme.primaryTeal),
                          tooltip: 'Call Professional',
                          onPressed: () {
                            AppUtils.makePhoneCall(context, '+919876543210');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Patient and Visit Schedule Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Schedule & Patient Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Divider(height: 16),
                    _buildItemRow('Patient Name:', '${booking.patientName} (${booking.patientAge} yrs)'),
                    const SizedBox(height: 8),
                    _buildItemRow('Visit Date:', AppUtils.formatDate(booking.date)),
                    const SizedBox(height: 8),
                    _buildItemRow('Time Slot:', booking.timeSlot),
                    const SizedBox(height: 8),
                    _buildItemRow('Visit Address:', booking.address),
                    if (booking.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildItemRow('Patient Notes:', booking.notes),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Visit Amount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          PricingCalculator.formatCurrency(booking.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (booking.status != 'Completed' && booking.status != 'Cancelled') ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ServiceCompletionScreen(booking: booking),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete Service with Evidence'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (booking.status == 'Completed' && !booking.hasReview) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WriteReviewScreen(
                          professionalId: booking.professionalId,
                          professionalName: booking.professionalName,
                          bookingId: booking.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Leave Rating & Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showInvoiceDialog(context, booking),
                icon: const Icon(Icons.receipt_long),
                label: const Text('View / Share Tax Invoice'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, int activeIndex) {
    return Column(
      children: List.generate(_stages.length, (i) {
        final stage = _stages[i];
        final isDone = activeIndex >= i;
        final isCurrent = activeIndex == i;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isDone ? AppTheme.primaryTeal : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                  ),
                ),
                if (i < _stages.length - 1)
                  Container(
                    width: 2,
                    height: 28,
                    color: isDone ? AppTheme.primaryTeal : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  stage,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isDone ? const Color(0xFF1E293B) : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildVitalBadge(String title, String val, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryTeal),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
