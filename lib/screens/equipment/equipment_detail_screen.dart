import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../models/equipment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/custom_network_image.dart';
import 'delivery_tracking_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  int _selectedDurationMonths = 1; // 1, 3, 6
  final TextEditingController _addressController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _addressController.text = auth.currentUser?.defaultAddress ??
        'Flat 402, Green Meadows, Sector 15, Kharghar, Navi Mumbai';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  EquipmentRentalPricing get _pricing {
    return PricingCalculator.calculateEquipmentRentalPricing(
      monthlyRate: widget.equipment.monthlyRate,
      durationMonths: _selectedDurationMonths,
      refundableDeposit: widget.equipment.deposit,
    );
  }

  Future<void> _handleRentNow() async {
    if (_addressController.text.trim().isEmpty) {
      AppUtils.showToast(context, 'Please enter delivery address', isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    final eqProv = Provider.of<EquipmentProvider>(context, listen: false);

    final order = await eqProv.createRentalOrder(
      equipment: widget.equipment,
      durationMonths: _selectedDurationMonths,
      totalCost: _pricing.grandTotal,
      deliveryAddress: _addressController.text.trim(),
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      AppUtils.showToast(
        context,
        'Equipment rental ordered! Dispatched to logistics.',
        isSuccess: true,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DeliveryTrackingScreen(orderId: order.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eq = widget.equipment;
    final pricing = _pricing;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(eq.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Equipment Image
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.white,
              child: Center(
                child: CustomNetworkImage(
                  imageUrl: eq.imageUrl,
                  fallbackIcon: equipmentCategoryIcon(eq.category),
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Sanitized Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTealLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          eq.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTealDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sanitizer, size: 14, color: AppTheme.successGreen),
                            SizedBox(width: 4),
                            Text(
                              'Sterilized & Sanitized',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name & Price
                  Text(
                    eq.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${PricingCalculator.formatCurrency(eq.monthlyRate)} / month (Refundable Deposit: ${PricingCalculator.formatCurrency(eq.deposit)})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  Text(
                    eq.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Features & Specifications
                  const Text(
                    'Medical Specifications & Features',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...eq.features.map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppTheme.primaryTeal,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                f,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Rental Duration Selector (1, 3, 6 Months)
                  const Text(
                    'Select Rental Tenure',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildDurationChip(1, '1 Month', 'Standard Rate'),
                      const SizedBox(width: 8),
                      _buildDurationChip(3, '3 Months', '5% Off Rental'),
                      const SizedBox(width: 8),
                      _buildDurationChip(6, '6 Months', '10% Off Rental'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Delivery Address
                  const Text(
                    'Delivery & Installation Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Enter complete address for technician delivery & demo',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price Summary Breakdown Card
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
                        const Text(
                          'Cost Summary',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        _buildSummaryRow(
                          'Rental Duration (${_selectedDurationMonths} Month${_selectedDurationMonths > 1 ? "s" : ""})',
                          PricingCalculator.formatCurrency(pricing.baseRentalCost),
                        ),
                        if (pricing.discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Duration Discount (${pricing.discountPercentage}%)',
                            '- ${pricing.discountFormatted}',
                            isGreen: true,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Refundable Security Deposit',
                          pricing.depositFormatted,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Doorstep Delivery & Assembly',
                          'Free (Portea Logistics)',
                          isGreen: true,
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount Payable',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              pricing.grandTotalFormatted,
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
                  const SizedBox(height: 32),

                  // Rent Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handleRentNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Rent Now (${pricing.grandTotalFormatted})',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(int months, String label, String subtitle) {
    final isSelected = _selectedDurationMonths == months;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedDurationMonths = months),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryTealLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryTeal : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? AppTheme.primaryTealDark : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
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
