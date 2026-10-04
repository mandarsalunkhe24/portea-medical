import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../data/mock_data.dart';
import '../../providers/insurance_provider.dart';
import '../../widgets/status_chip.dart';
import 'claim_request_screen.dart';

class InsuranceAssistanceScreen extends StatelessWidget {
  const InsuranceAssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insProv = Provider.of<InsuranceProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Insurance Claim Assistance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Claim Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.secondaryBlueDark, AppTheme.secondaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'PORTEA TPA CLAIM SUPPORT',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Reimburse Home Healthcare from Your Health Insurance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Most comprehensive health policies cover doctor-advised domiciliary nursing and physiotherapy under OPD / Daycare benefits.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ClaimRequestScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.secondaryBlueDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Request Claim Assistance Dossier'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // How Home Healthcare Claims Work (Step-by-Step)
            const Text(
              'How Domiciliary Claims Work (Step-by-Step)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildStepRow(
                    '1',
                    'Doctor\'s Prescription',
                    'Obtain a referral advising home nursing, physiotherapy, or oxygen therapy.',
                  ),
                  const Divider(height: 20),
                  _buildStepRow(
                    '2',
                    'Book & Complete Service on Portea',
                    'Our verified clinician performs visits and records daily vitals / evidence.',
                  ),
                  const Divider(height: 20),
                  _buildStepRow(
                    '3',
                    'Download Official GST Tax Invoice',
                    'Portea provides itemized GST invoice and clinical treatment summary.',
                  ),
                  const Divider(height: 20),
                  _buildStepRow(
                    '4',
                    'TPA Assessment & Reimbursement',
                    'Submit your dossier online or have Portea TPA desk coordinate with your insurer.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Required Document Checklist (Saved locally in SharedPreferences)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Claim Readiness Checklist',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Auto-Saved',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: MockData.requiredClaimDocuments.map((doc) {
                  final isChecked = insProv.checklistStatus[doc] ?? false;
                  return CheckboxListTile(
                    value: isChecked,
                    activeColor: AppTheme.secondaryBlue,
                    title: Text(
                      doc,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        color: isChecked ? Colors.grey : const Color(0xFF1E293B),
                      ),
                    ),
                    onChanged: (val) {
                      insProv.toggleChecklistDoc(doc, val ?? false);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Active Submitted Claim Requests
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Claim Assistance Requests',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ClaimRequestScreen()),
                    );
                  },
                  child: const Text('+ New Request'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (insProv.claims.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No claims submitted yet.'),
                ),
              )
            else
              Column(
                children: insProv.claims.map((claim) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
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
                                claim.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              StatusChip(status: claim.status, isSmall: true),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            claim.insurerName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Policy: ${claim.policyNumber} • Patient: ${claim.patientName}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estimated Claim: ${PricingCalculator.formatCurrency(claim.estimatedClaimAmount)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 15, color: AppTheme.secondaryBlue),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  claim.trackingRemarks,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                          if (claim.status != 'Approved') ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  insProv.advanceClaimStatus(claim.id);
                                  AppUtils.showToast(context, 'Claim status advanced for demo!');
                                },
                                icon: const Icon(Icons.fast_forward, size: 14),
                                label: const Text('Advance Claim Status', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Supported Health Insurance Partners
            const Text(
              'Supported Insurance & TPA Partners',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MockData.insurancePartners
                  .map((p) => Chip(
                        avatar: const Icon(Icons.health_and_safety, size: 16, color: AppTheme.secondaryBlue),
                        label: Text(p),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String stepNum, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppTheme.secondaryBlueLight,
          child: Text(
            stepNum,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryBlueDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
