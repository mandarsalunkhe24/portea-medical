import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/emergency_contact_model.dart';
import '../../providers/emergency_provider.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  void _showAddEditContactDialog(BuildContext context, [EmergencyContact? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final relationCtrl = TextEditingController(text: existing?.relation ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    bool isPrimary = existing?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existing == null ? 'Add Emergency Contact' : 'Edit Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: relationCtrl,
                  decoration: const InputDecoration(labelText: 'Relationship (e.g. Son, Doctor)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number (10 digits)'),
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text('Set as Primary SOS Call Target'),
                  value: isPrimary,
                  activeColor: AppTheme.emergencyRed,
                  onChanged: (val) => setDialogState(() => isPrimary = val ?? false),
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
                if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
                final prov = Provider.of<EmergencyProvider>(context, listen: false);

                if (existing == null) {
                  final newC = EmergencyContact(
                    id: 'ec_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    relation: relationCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    isPrimary: isPrimary,
                  );
                  await prov.addContact(newC);
                } else {
                  final updated = existing.copyWith(
                    name: nameCtrl.text.trim(),
                    relation: relationCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    isPrimary: isPrimary,
                  );
                  await prov.updateContact(updated);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emergencyProv = Provider.of<EmergencyProvider>(context);
    final primary = emergencyProv.primaryContact;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Emergency Assistance & SOS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Elderly-Friendly SOS Trigger Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.emergencyShadow,
              ),
              child: Column(
                children: [
                  const Text(
                    'PORT-EA EMERGENCY DISPATCH',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Giant Pushable SOS Button
                  GestureDetector(
                    onTap: () async {
                      await emergencyProv.triggerSos(context);
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emergency_rounded,
                              size: 48,
                              color: AppTheme.emergencyRed,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'PRESS SOS',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.emergencyRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'One-Touch Emergency Dispatch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Triggers GPS coordinates to Portea 24x7 control room & dials:\n${primary?.name ?? "Ambulance"} (${primary?.phone ?? "108"})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Contacts Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddEditContactDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Contact'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Contacts List
            Column(
              children: emergencyProv.contacts.map((contact) {
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: contact.isPrimary
                          ? AppTheme.emergencyRed
                          : const Color(0xFFE2E8F0),
                      width: contact.isPrimary ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: contact.isDefaultService
                          ? AppTheme.secondaryBlueLight
                          : (contact.isPrimary ? AppTheme.emergencyRedLight : const Color(0xFFF1F5F9)),
                      child: Icon(
                        contact.isDefaultService
                            ? Icons.local_hospital
                            : (contact.isPrimary ? Icons.star : Icons.person),
                        color: contact.isDefaultService
                            ? AppTheme.secondaryBlue
                            : (contact.isPrimary ? AppTheme.emergencyRed : Colors.grey.shade700),
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (contact.isPrimary) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.emergencyRedLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRIMARY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.emergencyRed,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text('${contact.relation} • ${contact.phone}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call, color: AppTheme.successGreen),
                          tooltip: 'Call Now',
                          onPressed: () => AppUtils.makePhoneCall(context, contact.phone),
                        ),
                        if (!contact.isDefaultService)
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'edit') {
                                _showAddEditContactDialog(context, contact);
                              } else if (val == 'primary') {
                                emergencyProv.setPrimaryContact(contact.id);
                              } else if (val == 'delete') {
                                emergencyProv.deleteContact(contact.id);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'primary', child: Text('Set as Primary')),
                              const PopupMenuItem(value: 'edit', child: Text('Edit Contact')),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // SOS History Log
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SOS Incident Log & History',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${emergencyProv.sosHistory.length} events logged',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (emergencyProv.sosHistory.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No emergency SOS triggered yet.'),
                ),
              )
            else
              Column(
                children: emergencyProv.sosHistory.map((event) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              event.id,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.emergencyRed,
                              ),
                            ),
                            Text(
                              AppUtils.formatDateTime(event.timestamp),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Dialed: ${event.triggeredContactName} (${event.triggeredContactPhone})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppTheme.emergencyRed),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${event.locationAddress} • GPS: ${event.coordinates}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${event.status}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
