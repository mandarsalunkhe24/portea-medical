import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../models/care_plan_model.dart';
import '../../models/professional_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/care_plan_provider.dart';
import '../../providers/professionals_provider.dart';
import '../../widgets/custom_network_image.dart';

class CarePlanCreatorScreen extends StatefulWidget {
  final Professional? preselectedProfessional;

  const CarePlanCreatorScreen({super.key, this.preselectedProfessional});

  @override
  State<CarePlanCreatorScreen> createState() => _CarePlanCreatorScreenState();
}

class _CarePlanCreatorScreenState extends State<CarePlanCreatorScreen> {
  late String _serviceType;
  Professional? _selectedProfessional;
  Patient? _selectedPatient;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  String _frequency = 'Alternate days'; // Daily, Alternate days, Weekly, Custom weekdays
  int _numberOfVisits = 10;
  String _timeSlot = '10:00 AM - 11:00 AM';
  final TextEditingController _titleController = TextEditingController(
    text: 'Rehabilitation & Nursing Care Plan',
  );
  bool _isCreating = false;

  final List<String> _frequencies = [
    'Daily',
    'Alternate days',
    'Weekly',
    'Custom weekdays',
  ];

  final List<String> _slots = [
    '08:00 AM - 09:00 AM',
    '10:00 AM - 11:00 AM',
    '02:00 PM - 03:00 PM',
    '04:00 PM - 05:00 PM',
    '06:00 PM - 07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProfessional = widget.preselectedProfessional;
    _serviceType = _selectedProfessional?.role ?? 'Physiotherapy';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser?.patients.isNotEmpty == true) {
        setState(() {
          _selectedPatient = auth.currentUser!.patients.first;
        });
      }
      final profs = Provider.of<ProfessionalsProvider>(context, listen: false).allProfessionals;
      if (_selectedProfessional == null && profs.isNotEmpty) {
        setState(() {
          _selectedProfessional = profs.first;
          _serviceType = _selectedProfessional!.role;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  CarePlanPricing get _pricing {
    return PricingCalculator.calculateCarePlanPricing(
      serviceType: _serviceType,
      numberOfVisits: _numberOfVisits,
    );
  }

  List<CarePlanVisit> get _previewSchedule {
    return CarePlanProvider.generateSchedule(
      startDate: _startDate,
      frequency: _frequency,
      numberOfVisits: _numberOfVisits,
      timeSlot: _timeSlot,
    );
  }

  Future<void> _saveCarePlan() async {
    if (_selectedProfessional == null || _selectedPatient == null) {
      AppUtils.showToast(context, 'Please select both professional and patient', isError: true);
      return;
    }

    setState(() => _isCreating = true);
    final carePlanProv = Provider.of<CarePlanProvider>(context, listen: false);

    await carePlanProv.createCarePlan(
      title: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : '$_serviceType Care Plan - ${_selectedPatient!.name}',
      serviceType: _serviceType,
      professionalId: _selectedProfessional!.id,
      professionalName: _selectedProfessional!.name,
      professionalRole: _selectedProfessional!.role,
      patientName: _selectedPatient!.name,
      startDate: _startDate,
      frequency: _frequency,
      numberOfVisits: _numberOfVisits,
      preferredTimeSlot: _timeSlot,
    );

    setState(() => _isCreating = false);

    if (mounted) {
      AppUtils.showToast(
        context,
        'Care plan created with 15% discount applied!',
        isSuccess: true,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProv = Provider.of<AuthProvider>(context);
    final profProv = Provider.of<ProfessionalsProvider>(context);

    final matchingProfs = profProv.allProfessionals
        .where((p) => p.role.toLowerCase().contains(_serviceType.toLowerCase()) || _serviceType == 'All')
        .toList();

    final pricing = _pricing;
    final schedule = _previewSchedule;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Recurring Care Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discount Notification Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryTeal, Color(0xFF004D40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '15% CARE PACKAGE DISCOUNT',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select 10 or more visits to automatically apply a 15% discount on the entire care package.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Care Plan Name
            const Text(
              'Care Plan Title',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g. Post-Knee Replacement Rehab Package',
                prefixIcon: Icon(Icons.bookmark_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Service Type Selector
            const Text(
              'Select Healthcare Service',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildServiceChip('Physiotherapy'),
                const SizedBox(width: 8),
                _buildServiceChip('Nurse'),
                const SizedBox(width: 8),
                _buildServiceChip('Elderly Caregiver'),
              ],
            ),
            const SizedBox(height: 16),

            // Select Professional
            const Text(
              'Assigned Verified Professional',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (matchingProfs.isEmpty)
              const Text('No professionals available for this role')
            else
              DropdownButtonFormField<String>(
                value: _selectedProfessional?.id,
                items: matchingProfs
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (${p.qualifications})', style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (id) {
                  setState(() {
                    _selectedProfessional = profProv.getProfessionalById(id!);
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_pin),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            const SizedBox(height: 16),

            // Patient Selection
            const Text(
              'Patient',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPatient?.id,
              items: (authProv.currentUser?.patients ?? [])
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.name} (${p.relationship}, ${p.age}y)', style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: (id) {
                setState(() {
                  _selectedPatient = authProv.currentUser?.patients.firstWhere((p) => p.id == id);
                });
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.people_outline),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Number of Visits Slider & Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Number of Visits',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _numberOfVisits >= 10 ? AppTheme.successGreenLight : AppTheme.primaryTealLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_numberOfVisits Visits ${_numberOfVisits >= 10 ? "(15% OFF)" : ""}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _numberOfVisits >= 10 ? AppTheme.successGreen : AppTheme.primaryTealDark,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _numberOfVisits.toDouble(),
              min: 3,
              max: 30,
              divisions: 27,
              activeColor: AppTheme.primaryTeal,
              label: '$_numberOfVisits visits',
              onChanged: (val) {
                setState(() {
                  _numberOfVisits = val.toInt();
                });
              },
            ),
            const SizedBox(height: 8),

            // Frequency Selection
            const Text(
              'Visit Frequency',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _frequencies
                  .map((f) => ChoiceChip(
                        label: Text(f),
                        selected: _frequency == f,
                        onSelected: (_) => setState(() => _frequency = f),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Start Date & Time Slot
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 60)),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          AppUtils.formatDate(_startDate),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferred Slot',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _timeSlot,
                        items: _slots
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, style: const TextStyle(fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _timeSlot = val!),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pricing Summary Card (Highlight 15% discount struck-through)
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
                    'Care Package Pricing Breakdown',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 20),
                  _buildPriceRow(
                    'Standard Price (${_numberOfVisits} x ${PricingCalculator.formatCurrency(pricing.basePerVisitPrice)})',
                    pricing.originalFormatted,
                  ),
                  if (pricing.isDiscountApplied) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Bulk Discount (15% Package Saving)',
                      '- ${pricing.discountFormatted}',
                      isGreen: true,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildPriceRow(
                    'Effective Price Per Visit',
                    pricing.effectivePerVisitFormatted,
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Final Total',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Row(
                        children: [
                          if (pricing.isDiscountApplied) ...[
                            Text(
                              pricing.originalFormatted,
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            pricing.finalFormatted,
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
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Auto-Generated Schedule Preview (List of Visits)
            Text(
              'Generated Recurring Schedule (${schedule.length} visits)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListView.separated(
                itemCount: schedule.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final v = schedule[index];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.primaryTealLight,
                      child: Text(
                        '${v.visitNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTealDark,
                        ),
                      ),
                    ),
                    title: Text(
                      'Visit #${v.visitNumber}: ${AppUtils.formatDate(v.date)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    trailing: Text(
                      v.timeSlot,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  );
                },
              ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _saveCarePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Confirm & Activate Care Plan (${pricing.finalFormatted})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceChip(String type) {
    final isSelected = _serviceType == type;
    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _serviceType = type;
        });
      },
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isGreen = false}) {
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
