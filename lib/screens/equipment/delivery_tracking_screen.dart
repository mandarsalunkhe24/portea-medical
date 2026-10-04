import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/rental_order_model.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/status_chip.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String? orderId;

  const DeliveryTrackingScreen({super.key, this.orderId});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  String? _activeOrderId;

  @override
  void initState() {
    super.initState();
    _activeOrderId = widget.orderId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eqProv = Provider.of<EquipmentProvider>(context);
    final orders = eqProv.rentalOrders;

    if (orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Equipment Delivery')),
        body: const Center(
          child: Text('No active equipment orders found to track.'),
        ),
      );
    }

    final activeOrder = _activeOrderId != null
        ? eqProv.getRentalOrderById(_activeOrderId!) ?? orders.first
        : orders.first;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Live Delivery Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Switcher if multiple orders exist
            if (orders.length > 1) ...[
              const Text(
                'Select Order to Track:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: activeOrder.id,
                items: orders
                    .map((o) => DropdownMenuItem(
                          value: o.id,
                          child: Text('${o.equipmentName} (${o.id})', style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (id) => setState(() => _activeOrderId = id),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Active Order Summary Card
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
                      Text(
                        activeOrder.id,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      StatusChip(status: activeOrder.currentStatus, isSmall: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CustomNetworkImage(
                        imageUrl: activeOrder.equipmentImage,
                        width: 56,
                        height: 56,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeOrder.equipmentName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tenure: ${activeOrder.durationMonths} Month(s) • Total Paid: Rs. ${activeOrder.totalCost.toInt()}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppTheme.primaryTeal),
                      const SizedBox(width: 6),
                      Text(
                        'Estimated Delivery: ${activeOrder.etaString}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Agent Contact Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryTealLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.primaryTeal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeOrder.deliveryAgentName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Text(
                          'Portea Medical Logistics Technician',
                          style: TextStyle(fontSize: 11, color: AppTheme.primaryTealDark),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => AppUtils.makePhoneCall(
                      context,
                      activeOrder.deliveryAgentPhone,
                    ),
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stepper / Timeline Card
            Container(
              padding: const EdgeInsets.all(18),
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
                        'Delivery Timeline & Inspection',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      // Debug simulator button
                      if (activeOrder.currentStatus != 'Delivered')
                        ElevatedButton.icon(
                          onPressed: () {
                            eqProv.simulateNextDeliveryStage(activeOrder.id);
                            AppUtils.showToast(
                              context,
                              'Simulated next delivery stage for offline demo!',
                              isSuccess: true,
                            );
                          },
                          icon: const Icon(Icons.fast_forward, size: 14),
                          label: const Text('Simulate Next Stage', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Stepper Events
                  ...List.generate(activeOrder.trackingHistory.length, (i) {
                    final event = activeOrder.trackingHistory[i];
                    final isLast = i == activeOrder.trackingHistory.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: event.isCompleted
                                    ? AppTheme.successGreen
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: event.isCompleted
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : Text(
                                        '${i + 1}',
                                        style: const TextStyle(fontSize: 10, color: Colors.white),
                                      ),
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 44,
                                color: event.isCompleted
                                    ? AppTheme.successGreen
                                    : Colors.grey.shade300,
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: event.isCompleted ? FontWeight.bold : FontWeight.w500,
                                  color: event.isCompleted ? const Color(0xFF1E293B) : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                event.description,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppUtils.formatTime(event.timestamp),
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Delivery Address Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryTeal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Destination',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text(
                          activeOrder.deliveryAddress,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
