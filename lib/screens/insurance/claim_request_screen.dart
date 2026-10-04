import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/insurance_provider.dart';

class ClaimRequestScreen extends StatefulWidget {
  const ClaimRequestScreen({super.key});

  @override
  State<ClaimRequestScreen> createState() => _ClaimRequestScreenState();
}

class _ClaimRequestScreenState extends State<ClaimRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _policyNumberCtrl = TextEditingController(text: 'STAR-HEALTH-99410382');
  final _patientNameCtrl = TextEditingController(text: 'Ramesh Salunkhe');
  final _serviceCtrl = TextEditingController(text: 'Post-Op Physiotherapy & Nursing');
  final _amountCtrl = TextEditingController(text: '6791.50');
  final _phoneCtrl = TextEditingController(text: '+919876543210');
  String _selectedInsurer = MockData.insurancePartners.first;

  final List<String> _uploadedFiles = [
    'Doctor_Prescription_Referral.pdf',
    'Portea_Official_Tax_Invoice.pdf',
  ];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser != null) {
      _phoneCtrl.text = auth.currentUser!.phone;
      if (auth.currentUser!.patients.isNotEmpty) {
        _patientNameCtrl.text = auth.currentUser!.patients.first.name;
      }
    }
  }

  @override
  void dispose() {
    _policyNumberCtrl.dispose();
    _patientNameCtrl.dispose();
    _serviceCtrl.dispose();
    _amountCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadDoc() async {
    final image = await AppUtils.pickImageSafely(context, source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _uploadedFiles.add(image.name.isNotEmpty ? image.name : 'Document_${_uploadedFiles.length + 1}.jpg');
      });
    } else {
      setState(() {
        _uploadedFiles.add('Medical_Treatment_Record_${_uploadedFiles.length + 1}.pdf');
      });
      if (mounted) {
        AppUtils.showToast(context, 'Document added to claim dossier');
      }
    }
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final insProv = Provider.of<InsuranceProvider>(context, listen: false);

    await insProv.submitClaim(
      policyNumber: _policyNumberCtrl.text.trim(),
      insurerName: _selectedInsurer,
      patientName: _patientNameCtrl.text.trim(),
      serviceBooked: _serviceCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      documentFileNames: _uploadedFiles,
      estimatedAmount: double.tryParse(_amountCtrl.text.trim()) ?? 5000.0,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      AppUtils.showToast(
        context,
        'Claim assistance dossier submitted to Portea TPA Desk!',
        isSuccess: true,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Request Claim Assistance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit Insurance Dossier',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Our in-house TPA claims team will verify your bills and submit pre-authorization.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Insurer Dropdown
              const Text('Insurance Provider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedInsurer,
                isExpanded: true,
                items: MockData.insurancePartners
                    .map((ins) => DropdownMenuItem(value: ins, child: Text(ins, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) => setState(() => _selectedInsurer = val!),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.shield_outlined)),
              ),
              const SizedBox(height: 14),

              // Policy Number
              const Text('Policy / TPA Card Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _policyNumberCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. STAR-HEALTH-009124',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter policy number' : null,
              ),
              const SizedBox(height: 14),

              // Patient Name
              const Text('Patient Name (Insured)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _patientNameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Ramesh Salunkhe',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter patient name' : null,
              ),
              const SizedBox(height: 14),

              // Service Rendered
              const Text('Healthcare Service Rendered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _serviceCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Home Physiotherapy Post-TKR',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Estimated Amount & Phone
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Claim Amount (Rs.)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '6791.50',
                            prefixIcon: Icon(Icons.currency_rupee),
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
                        const Text('Contact Mobile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '9876543210',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Attached Documents
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dossier Attachments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  TextButton.icon(
                    onPressed: _uploadDoc,
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text('Add File / Photo'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ..._uploadedFiles.map((f) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: AppTheme.secondaryBlue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                          onPressed: () => setState(() => _uploadedFiles.remove(f)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Claim to Portea TPA Desk',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
