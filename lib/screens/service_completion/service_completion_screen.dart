import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../reviews/write_review_screen.dart';

class ServiceCompletionScreen extends StatefulWidget {
  final Booking booking;

  const ServiceCompletionScreen({super.key, required this.booking});

  @override
  State<ServiceCompletionScreen> createState() =>
      _ServiceCompletionScreenState();
}

class _ServiceCompletionScreenState extends State<ServiceCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController(
    text: 'Clinical procedure completed under strict aseptic conditions. Patient responded comfortably.',
  );
  final _bpController = TextEditingController(text: '120/80');
  final _pulseController = TextEditingController(text: '72');
  final _tempController = TextEditingController(text: '98.4');

  bool _professionalConfirmed = true;
  bool _patientConfirmed = true;
  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await AppUtils.pickImageSafely(context, source: source);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _submitCompletion() async {
    if (!_professionalConfirmed || !_patientConfirmed) {
      AppUtils.showToast(
        context,
        'Both professional and patient confirmations are required',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);

    // Default medical photo fallback if image_picker returns null or on web demo
    final photoPath = _pickedImage?.path ??
        'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&q=80&w=400';

    final evidence = ServiceCompletionEvidence(
      photoPath: photoPath,
      notes: _notesController.text.trim(),
      bloodPressure: _bpController.text.trim(),
      pulseRate: '${_pulseController.text.trim()} bpm',
      temperature: '${_tempController.text.trim()} °F',
      professionalConfirmed: _professionalConfirmed,
      patientConfirmed: _patientConfirmed,
      completedAt: DateTime.now(),
    );

    final success = await bookingProv.completeBookingWithEvidence(
      bookingId: widget.booking.id,
      evidence: evidence,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      AppUtils.showToast(
        context,
        'Service completion logged and verified with evidence!',
        isSuccess: true,
      );

      // Prompt for review
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WriteReviewScreen(
            professionalId: widget.booking.professionalId,
            professionalName: widget.booking.professionalName,
            bookingId: widget.booking.id,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Complete Service & Evidence'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppTheme.primaryTeal, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.booking.serviceTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.primaryTealDark,
                            ),
                          ),
                          Text(
                            'Patient: ${widget.booking.patientName} • ${widget.booking.professionalName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Photo Evidence Section
              const Text(
                'Photo Evidence (Clinical / Dressing / Consumables)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (_pickedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: kIsWeb
                          ? Image.network(
                              _pickedImage!.path,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_pickedImage!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          onPressed: () => setState(() => _pickedImage = null),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.add_a_photo_outlined, size: 40, color: AppTheme.primaryTeal),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload procedure completion or vital monitor photo',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Camera'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('Gallery'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Patient Vitals Section
              const Text(
                'Recorded Patient Vitals (Optional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bpController,
                      decoration: const InputDecoration(
                        labelText: 'Blood Pressure',
                        hintText: '120/80',
                        prefixIcon: Icon(Icons.favorite, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _pulseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Pulse (bpm)',
                        hintText: '72',
                        prefixIcon: Icon(Icons.monitor_heart, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _tempController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Temp (°F)',
                        hintText: '98.4',
                        prefixIcon: Icon(Icons.thermostat, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Clinical Notes
              const Text(
                'Procedure & Observations Notes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter clinical observations, wound state, dosage administered...',
                ),
              ),
              const SizedBox(height: 20),

              // Confirmation Checkboxes
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _professionalConfirmed,
                      activeColor: AppTheme.primaryTeal,
                      title: const Text(
                        'Healthcare Professional Signature Confirmation',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'I verify that the prescribed procedure was carried out following Portea hygiene standards.',
                        style: TextStyle(fontSize: 11),
                      ),
                      onChanged: (val) =>
                          setState(() => _professionalConfirmed = val ?? false),
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      value: _patientConfirmed,
                      activeColor: AppTheme.primaryTeal,
                      title: const Text(
                        'Patient / Attendant Verbal Verification',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Patient or family member confirmed satisfactory completion of service.',
                        style: TextStyle(fontSize: 11),
                      ),
                      onChanged: (val) =>
                          setState(() => _patientConfirmed = val ?? false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Evidence & Complete Service',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
