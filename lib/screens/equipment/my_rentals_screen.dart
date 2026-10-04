import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/status_chip.dart';
import 'delivery_tracking_screen.dart';

class MyRentalsScreen extends StatelessWidget {
  const MyRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eqProv = Provider.of<EquipmentProvider>(context);
    final orders = eqProv.rentalOrders;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Equipment Rentals'),
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No equipment rental orders placed yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            StatusChip(status: order.currentStatus, isSmall: true),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CustomNetworkImage(
                              imageUrl: order.equipmentImage,
                              width: 54,
                              height: 54,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.equipmentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Duration: ${order.durationMonths} Month(s) • Total: ${PricingCalculator.formatCurrency(order.totalCost)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ordered on ${AppUtils.formatDate(order.orderDate)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DeliveryTrackingScreen(
                                      orderId: order.id,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.navigation_outlined, size: 16),
                              label: const Text('Live Tracking'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
