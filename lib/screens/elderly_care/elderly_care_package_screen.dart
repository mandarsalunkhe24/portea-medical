import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../models/professional_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/care_plan_provider.dart';
import '../../providers/professionals_provider.dart';
import '../../widgets/custom_network_image.dart';

class ElderlyCarePackageScreen extends StatefulWidget {
  const ElderlyCarePackageScreen({super.key});

  @override
  State<ElderlyCarePackageScreen> createState() =>
      _ElderlyCarePackageScreenState();
}

class _ElderlyCarePackageScreenState extends State<ElderlyCarePackageScreen> {
  Professional? _selectedCaregiver;
  String _preferredSlot = '09:00 AM - 10:00 AM';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  bool _isSubscribing = false;
  bool _isSubscribed = false;

  final List<String> _slots = [
    '08:00 AM - 09:00 AM',
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '05:00 PM - 06:00 PM',
  ];

  final List<Map<String, dynamic>> _inclusions = [
    {
      'title': 'Twice-Daily Vitals & Sugar Charting',
      'desc': 'Blood pressure, pulse, SpO2, and random blood glucose tracking with cloud log.',
      'icon': Icons.monitor_heart_outlined,
    },
    {
      'title': 'Strict Medication Compliance',
      'desc': 'Timely reminders and pill-box organization according to doctor prescription.',
      'icon': Icons.medication_outlined,
    },
    {
      'title': 'Gentle Assisted Mobility & Walks',
      'desc': 'Bed-to-chair transfers, walking support, and daily range-of-motion limb exercises.',
      'icon': Icons.accessibility_new_outlined,
    },
    {
      'title': 'Warm Companionship & Cognitive Stim',
      'desc': 'Reading, memory games, emotional support, and active listening for mental wellbeing.',
      'icon': Icons.favorite_outline,
    },
    {
      'title': 'Daily Digital Family Report',
      'desc': 'Detailed summary with vitals, food intake, and attendant notes pushed to family phone.',
      'icon': Icons.summarize_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profs = Provider.of<ProfessionalsProvider>(context, listen: false).allProfessionals;
      final caregivers = profs.where((p) => p.role.contains('Elderly')).toList();
      if (caregivers.isNotEmpty) {
        setState(() {
          _selectedCaregiver = caregivers.first;
        });
      }
    });
  }

  Future<void> _subscribePackage() async {
    setState(() => _isSubscribing = true);
    final carePlanProv = Provider.of<CarePlanProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final caregiver = _selectedCaregiver ??
        Provider.of<ProfessionalsProvider>(context, listen: false).allProfessionals.last;

    await carePlanProv.createCarePlan(
      title: 'Portea Silver Care - 30 Days Senior Care',
      serviceType: 'Elderly Care',
      professionalId: caregiver.id,
      professionalName: caregiver.name,
      professionalRole: caregiver.role,
      patientName: auth.currentUser?.patients.first.name ?? 'Ramesh Salunkhe',
      startDate: _startDate,
      frequency: 'Daily',
      numberOfVisits: 30,
      preferredTimeSlot: _preferredSlot,
    );

    setState(() {
      _isSubscribing = false;
      _isSubscribed = true;
    });

    if (mounted) {
      AppUtils.showToast(
        context,
        'Subscription activated! 30 daily visits scheduled.',
        isSuccess: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profProv = Provider.of<ProfessionalsProvider>(context);
    final caregivers = profProv.allProfessionals.where((p) => p.role.contains('Elderly')).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Elderly Home Care Package'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PORTEA GOLDEN YEARS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Daily Senior Care & Attendant Package',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A trained, verified attendant visits your home every single day (30 visits a month) for medical assistance and heartfelt companionship.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        PricingCalculator.formatCurrency(PricingCalculator.elderlyCareMonthlyPrice),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        ' / month (Daily Visits)',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Subscription Dashboard (If subscribed)
                  if (_isSubscribed) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreenLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.successGreen),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified, color: AppTheme.successGreen),
                              SizedBox(width: 8),
                              Text(
                                'Active Monthly Subscription',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          const Text(
                            'Today\'s Attendant Check-in Status: Completed',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sunita Gaikwad checked in at 09:05 AM. Vitals recorded: BP 122/80, Pulse 74 bpm. Breakfast & morning medications taken.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.notifications_active, size: 16, color: AppTheme.primaryTeal),
                              const SizedBox(width: 6),
                              Text(
                                'SMS & WhatsApp push delivered to family',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Inclusions List
                  const Text(
                    'What is Included Every Single Day',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ..._inclusions.map((item) => Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreenLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(item['icon'], color: AppTheme.successGreen, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['desc'],
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
                        ),
                      )),
                  const SizedBox(height: 20),

                  // Select Dedicated Caregiver
                  const Text(
                    'Select Dedicated Senior Caregiver',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (caregivers.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedCaregiver?.id ?? caregivers.first.id,
                      items: caregivers
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.name} (${c.experienceYears}y exp - ★${c.rating})', style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (id) {
                        setState(() {
                          _selectedCaregiver = caregivers.firstWhere((c) => c.id == id);
                        });
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Preferred Time Slot
                  const Text(
                    'Preferred Daily Visit Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _slots
                        .map((slot) => ChoiceChip(
                              label: Text(slot),
                              selected: _preferredSlot == slot,
                              onSelected: (_) => setState(() => _preferredSlot = slot),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // 30-Day Schedule Preview
                  const Text(
                    '30-Day Schedule Preview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Daily continuous visits scheduled starting ${AppUtils.formatDate(_startDate)}.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 30,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final d = _startDate.add(Duration(days: i));
                        return Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Day ${i + 1}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${d.day}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                AppUtils.formatDate(d).split(' ')[1], // Month
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Icon(Icons.check_circle, size: 14, color: AppTheme.successGreen),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Subscribe Button
                  if (!_isSubscribed)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubscribing ? null : _subscribePackage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSubscribing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Subscribe for Rs. 8,999 / Month',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AppUtils.showToast(context, 'Family daily report downloaded as PDF');
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download Latest Attendant Report'),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
