import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../models/booking_model.dart';
import '../../models/professional_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_network_image.dart';
import 'booking_success_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Booking booking;
  final Professional professional;

  const BookingSummaryScreen({
    super.key,
    required this.booking,
    required this.professional,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  String _paymentMode = 'Pay After Visit (Cash / UPI)';
  bool _isProcessing = false;

  Future<void> _confirmBooking() async {
    setState(() => _isProcessing = true);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);

    final result = await bookingProv.createBooking(widget.booking);
    setState(() => _isProcessing = false);

    if (result['success'] == true && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(
            booking: widget.booking,
            professional: widget.professional,
          ),
        ),
      );
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.emergencyRed),
                SizedBox(width: 8),
                Text('Booking Conflict'),
              ],
            ),
            content: Text(
              result['message'] ?? 'This slot was just booked by another user. Please choose another slot.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // close dialog
                  Navigator.of(context).pop(); // back to calendar
                },
                child: const Text('Select Another Slot'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = widget.booking;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Booking Review & Confirmation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional & Service Card
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
                    Row(
                      children: [
                        CustomNetworkImage(
                          imageUrl: widget.professional.photoUrl,
                          fallbackText: widget.professional.name,
                          width: 56,
                          height: 56,
                          isCircle: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.serviceTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.professional.name} • ${widget.professional.role}',
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
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      AppUtils.formatDate(b.date),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.access_time,
                      'Time Slot',
                      b.timeSlot,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Patient & Address Card
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
                      'Patient & Visit Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      Icons.person_outline,
                      'Patient',
                      '${b.patientName} (${b.patientAge} Years)',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Address',
                      b.address,
                    ),
                    if (b.notes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        Icons.notes,
                        'Notes',
                        b.notes,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Mode
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
                      'Payment Method',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RadioListTile<String>(
                      value: 'Pay After Visit (Cash / UPI)',
                      groupValue: _paymentMode,
                      activeColor: AppTheme.primaryTeal,
                      title: const Text('Pay After Service Completion (Cash / UPI)'),
                      subtitle: const Text('Verified receipt generated on visit completion'),
                      onChanged: (val) => setState(() => _paymentMode = val!),
                    ),
                    RadioListTile<String>(
                      value: 'Prepay Online (UPI / Card)',
                      groupValue: _paymentMode,
                      activeColor: AppTheme.primaryTeal,
                      title: const Text('Online Payment (Instant Confirmation)'),
                      subtitle: const Text('Portea Secure Gateway (Demo simulated)'),
                      onChanged: (val) => setState(() => _paymentMode = val!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Price Breakdown Card
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
                      'Price Breakdown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const Divider(height: 16),
                    _buildPriceRow(
                      'Professional Visit Fee',
                      PricingCalculator.formatCurrency(b.price),
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Sterile PPE & Consumables Kit',
                      'Free (Portea Certified)',
                      isGreen: true,
                    ),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'GST & Taxes (18%)',
                      'Included in visit rate',
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          PricingCalculator.formatCurrency(b.price),
                          style: const TextStyle(
                            fontSize: 18,
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
            const SizedBox(height: 32),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryTeal),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isGreen ? AppTheme.successGreen : null,
          ),
        ),
      ],
    );
  }
}
