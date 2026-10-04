import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/professional_model.dart';
import '../../models/user_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_network_image.dart';
import 'booking_summary_screen.dart';

class BookingCalendarScreen extends StatefulWidget {
  final Professional professional;

  const BookingCalendarScreen({super.key, required this.professional});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  Patient? _selectedPatient;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _morningSlots = [
    '08:00 AM - 09:00 AM',
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
  ];

  final List<String> _afternoonSlots = [
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
  ];

  final List<String> _eveningSlots = [
    '06:00 PM - 07:00 PM',
    '07:00 PM - 08:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final user = authProv.currentUser;
    if (user != null && user.patients.isNotEmpty) {
      _selectedPatient = user.patients.first;
      _addressController.text = _selectedPatient!.address.isNotEmpty
          ? _selectedPatient!.address
          : user.defaultAddress;
    } else {
      _addressController.text = user?.defaultAddress ?? '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddPatientDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final relationCtrl = TextEditingController(text: 'Family Member');
    final notesCtrl = TextEditingController();
    String gender = 'Male';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Patient Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Patient Full Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => gender = val ?? 'Male'),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: relationCtrl,
                  decoration: const InputDecoration(labelText: 'Relationship (Father/Mother/Self)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Medical Notes (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final newPat = Patient(
                  id: 'pat_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  age: int.tryParse(ageCtrl.text) ?? 50,
                  gender: gender,
                  relationship: relationCtrl.text.trim(),
                  healthNotes: notesCtrl.text.trim(),
                  address: _addressController.text,
                );
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.addPatient(newPat);
                setState(() {
                  _selectedPatient = newPat;
                });
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Save Patient'),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToSummary() {
    if (_selectedSlot == null) {
      AppUtils.showToast(context, 'Please select a time slot', isError: true);
      return;
    }
    if (_selectedPatient == null) {
      AppUtils.showToast(context, 'Please select or add a patient', isError: true);
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      AppUtils.showToast(context, 'Please enter home visit address', isError: true);
      return;
    }

    final booking = Booking(
      id: 'PRT-BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      serviceTitle: widget.professional.role == 'Nurse'
          ? 'Home Nurse Visit & Clinical Care'
          : (widget.professional.role == 'Physiotherapist'
              ? 'Home Physiotherapy & Mobility Session'
              : 'Elderly Caregiver Attendant Visit'),
      professionalId: widget.professional.id,
      professionalName: widget.professional.name,
      professionalRole: widget.professional.role,
      professionalPhoto: widget.professional.photoUrl,
      patientName: _selectedPatient!.name,
      patientAge: _selectedPatient!.age,
      address: _addressController.text.trim(),
      date: _selectedDay,
      timeSlot: _selectedSlot!,
      price: widget.professional.pricePerVisit,
      notes: _notesController.text.trim(),
      status: 'Booked',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingSummaryScreen(
          booking: booking,
          professional: widget.professional,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingProv = Provider.of<BookingProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final patients = authProv.currentUser?.patients ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Select Date & Time Slot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Professional Mini Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CustomNetworkImage(
                    imageUrl: widget.professional.photoUrl,
                    fallbackText: widget.professional.name,
                    width: 52,
                    height: 52,
                    isCircle: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.professional.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          widget.professional.title,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.professional.pricePerVisit.toInt()} Rs',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Table Calendar Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 60)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.twoWeeks,
                  availableCalendarFormats: const {
                    CalendarFormat.twoWeeks: '2 Weeks',
                    CalendarFormat.month: 'Month',
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: AppTheme.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    disabledTextStyle: const TextStyle(color: Colors.grey),
                  ),
                  enabledDayPredicate: (day) {
                    // Disable past dates
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final target = DateTime(day.year, day.month, day.day);
                    return !target.isBefore(today);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedSlot = null; // reset slot when day changes
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Slots Legend
            Row(
              children: [
                _buildLegendItem(AppTheme.primaryTeal, 'Available'),
                const SizedBox(width: 14),
                _buildLegendItem(Colors.grey.shade400, 'Booked (Disabled)'),
                const SizedBox(width: 14),
                _buildLegendItem(AppTheme.primaryTealDark, 'Selected'),
              ],
            ),
            const SizedBox(height: 16),

            // Time Slots Section
            Text(
              'Available Slots for ${AppUtils.formatDate(_selectedDay)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Morning Slots
            _buildSlotCategory('Morning', _morningSlots, bookingProv),
            const SizedBox(height: 12),

            // Afternoon Slots
            _buildSlotCategory('Afternoon', _afternoonSlots, bookingProv),
            const SizedBox(height: 12),

            // Evening Slots
            _buildSlotCategory('Evening', _eveningSlots, bookingProv),
            const SizedBox(height: 24),

            // Patient Selection Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Patient',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddPatientDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New Patient'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (patients.isEmpty)
              OutlinedButton(
                onPressed: () => _showAddPatientDialog(context),
                child: const Text('Add Patient Details'),
              )
            else
              Column(
                children: patients.map((patient) {
                  final isSelected = _selectedPatient?.id == patient.id;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    color: isSelected ? AppTheme.primaryTealLight.withOpacity(0.4) : Colors.white,
                    child: RadioListTile<String>(
                      value: patient.id,
                      groupValue: _selectedPatient?.id,
                      activeColor: AppTheme.primaryTeal,
                      title: Text(
                        '${patient.name} (${patient.relationship}, ${patient.age} yrs)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: patient.healthNotes.isNotEmpty
                          ? Text(
                              patient.healthNotes,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            )
                          : null,
                      onChanged: (val) {
                        setState(() {
                          _selectedPatient = patient;
                          if (patient.address.isNotEmpty) {
                            _addressController.text = patient.address;
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Visit Address Field
            const Text(
              'Home Visit Address',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Enter complete house number, building, landmark, pincode',
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Clinical Notes Field
            const Text(
              'Clinical Notes for Professional (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. Please bring extra catheter kit / IV cannula 22G',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            const SizedBox(height: 32),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _proceedToSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Review Booking Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSlotCategory(String category, List<String> slots, BookingProvider bookingProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isBooked = bookingProv.isSlotAlreadyBooked(
              professionalId: widget.professional.id,
              date: _selectedDay,
              timeSlot: slot,
            );
            final isSelected = _selectedSlot == slot;

            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: isBooked
                  ? null
                  : (selected) {
                      setState(() {
                        _selectedSlot = selected ? slot : null;
                      });
                    },
              disabledColor: const Color(0xFFF1F5F9),
              selectedColor: AppTheme.primaryTeal,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isBooked
                    ? Colors.grey.shade400
                    : (isSelected ? Colors.white : AppTheme.primaryTealDark),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isBooked
                    ? Colors.grey.shade300
                    : (isSelected ? AppTheme.primaryTeal : AppTheme.primaryTeal.withOpacity(0.4)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
