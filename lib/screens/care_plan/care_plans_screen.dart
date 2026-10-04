import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../models/care_plan_model.dart';
import '../../providers/care_plan_provider.dart';
import '../../widgets/status_chip.dart';
import 'care_plan_creator_screen.dart';

class CarePlansScreen extends StatelessWidget {
  const CarePlansScreen({super.key});

  void _showCarePlanDetails(BuildContext context, CarePlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CarePlanDetailModal(planId: plan.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carePlanProv = Provider.of<CarePlanProvider>(context);
    final plans = carePlanProv.allCarePlans;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Care Plans & Packages'),
        actions: [
          IconButton(
            tooltip: 'Create New Care Plan',
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryTeal),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CarePlanCreatorScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: plans.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No Care Plans Active',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a multi-visit package to enjoy 15% discount.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CarePlanCreatorScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create 10-Visit Plan'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return _buildCarePlanCard(context, plan);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create_plan_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CarePlanCreatorScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Care Plan'),
      ),
    );
  }

  Widget _buildCarePlanCard(BuildContext context, CarePlan plan) {
    final carePlanProv = Provider.of<CarePlanProvider>(context, listen: false);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.id,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                StatusChip(status: plan.status, isSmall: true),
              ],
            ),
            const SizedBox(height: 10),

            // Plan Title
            Text(
              plan.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${plan.serviceType} • Patient: ${plan.patientName}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Assigned: ${plan.professionalName} (${plan.professionalRole})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),

            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress (${plan.completedVisitsCount} / ${plan.numberOfVisits} visits completed)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(plan.progressFraction * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: plan.progressFraction,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
              ),
            ),
            const Divider(height: 24),

            // Details and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.frequency} • ${plan.preferredTimeSlot}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (plan.discountAmount > 0) ...[
                          Text(
                            PricingCalculator.formatCurrency(plan.originalPrice),
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          PricingCalculator.formatCurrency(plan.finalPrice),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (plan.status == 'Active')
                      IconButton(
                        icon: const Icon(Icons.pause_circle_outline, color: Colors.orange),
                        tooltip: 'Pause Plan',
                        onPressed: () => carePlanProv.pauseCarePlan(plan.id),
                      )
                    else if (plan.status == 'Paused')
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline, color: AppTheme.successGreen),
                        tooltip: 'Resume Plan',
                        onPressed: () => carePlanProv.resumeCarePlan(plan.id),
                      ),
                    ElevatedButton(
                      onPressed: () => _showCarePlanDetails(context, plan),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Visits Schedule'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CarePlanDetailModal extends StatelessWidget {
  final String planId;

  const _CarePlanDetailModal({required this.planId});

  @override
  Widget build(BuildContext context) {
    final carePlanProv = Provider.of<CarePlanProvider>(context);
    final plan = carePlanProv.getCarePlanById(planId);

    if (plan == null) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            '${plan.serviceType} • ${plan.completedVisitsCount} of ${plan.numberOfVisits} visits done',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const Divider(height: 20),

          const Text(
            'Visits Schedule & Completion Log:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.separated(
              itemCount: plan.visits.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final v = plan.visits[i];
                final isCompleted = v.status == 'Completed';

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted ? AppTheme.successGreen : Colors.grey,
                  ),
                  title: Text(
                    'Visit #${v.visitNumber}: ${AppUtils.formatDate(v.date)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    isCompleted
                        ? 'Completed on ${AppUtils.formatDateTime(v.completedAt ?? v.date)}'
                        : '${v.timeSlot} • Status: ${v.status}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: isCompleted
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreenLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            carePlanProv.markVisitCompleted(plan.id, v.visitNumber);
                            AppUtils.showToast(
                              context,
                              'Visit #${v.visitNumber} marked completed!',
                              isSuccess: true,
                            );
                          },
                          child: const Text('Mark Done', style: TextStyle(fontSize: 12)),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
