import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({super.key});

  void _showAddEditPatientDialog(BuildContext context, [Patient? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final ageCtrl = TextEditingController(text: existing?.age.toString() ?? '');
    final relationCtrl = TextEditingController(text: existing?.relationship ?? 'Self');
    final notesCtrl = TextEditingController(text: existing?.healthNotes ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    String gender = existing?.gender ?? 'Male';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existing == null ? 'Add Patient Profile' : 'Edit Patient Profile'),
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
                  decoration: const InputDecoration(labelText: 'Age (Years)'),
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
                  decoration: const InputDecoration(labelText: 'Relationship (Self, Father, etc.)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Medical History / Chronic Conditions'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Visit Address'),
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
                final auth = Provider.of<AuthProvider>(context, listen: false);

                if (existing == null) {
                  final newP = Patient(
                    id: 'pat_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    age: int.tryParse(ageCtrl.text) ?? 50,
                    gender: gender,
                    relationship: relationCtrl.text.trim(),
                    healthNotes: notesCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                  );
                  await auth.addPatient(newP);
                } else {
                  final updatedP = Patient(
                    id: existing.id,
                    name: nameCtrl.text.trim(),
                    age: int.tryParse(ageCtrl.text) ?? existing.age,
                    gender: gender,
                    relationship: relationCtrl.text.trim(),
                    healthNotes: notesCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                  );
                  await auth.updatePatient(updatedP);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  AppUtils.showToast(context, 'Patient profile saved successfully');
                }
              },
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final patients = auth.currentUser?.patients ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Managed Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            onPressed: () => _showAddEditPatientDialog(context),
          ),
        ],
      ),
      body: patients.isEmpty
          ? const Center(child: Text('No patient profiles added.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final p = patients[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryTealLight,
                      child: Text(
                        p.name.isNotEmpty ? p.name[0] : 'P',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTealDark),
                      ),
                    ),
                    title: Text(
                      '${p.name} (${p.relationship})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${p.gender}, ${p.age} Years Old', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        if (p.healthNotes.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('Notes: ${p.healthNotes}', style: const TextStyle(fontSize: 12)),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primaryTeal),
                      onPressed: () => _showAddEditPatientDialog(context, p),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_patient_fab',
        onPressed: () => _showAddEditPatientDialog(context),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Patient'),
      ),
    );
  }
}
