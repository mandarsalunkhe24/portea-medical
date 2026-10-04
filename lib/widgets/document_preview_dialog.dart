import 'package:flutter/material.dart';
import '../core/theme.dart';

class DocumentPreviewDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String identifier;
  final String verifiedDate;
  final String verificationBody;
  final IconData icon;

  const DocumentPreviewDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.identifier,
    this.verifiedDate = 'Verified for 2026',
    this.verificationBody = 'Portea Clinical Quality & Credentialing Board',
    this.icon = Icons.verified_user_rounded,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String identifier,
    String verifiedDate = 'Verified for 2026',
    String verificationBody = 'Portea Clinical Quality & Credentialing Board',
    IconData icon = Icons.verified_user_rounded,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => DocumentPreviewDialog(
        title: title,
        subtitle: subtitle,
        identifier: identifier,
        verifiedDate: verifiedDate,
        verificationBody: verificationBody,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Badge Icon
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppTheme.successGreenLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.successGreen.withOpacity(0.3), width: 2),
              ),
              child: Icon(icon, color: AppTheme.successGreen, size: 38),
            ),
            const SizedBox(height: 16),
            Text(
              'Digital Credential Record',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryTeal,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Certificate Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildRow('Credential / ID Number', identifier, isMono: true),
                  const Divider(height: 20),
                  _buildRow('Verification Status', 'ACTIVE & VERIFIED', isGreen: true),
                  const Divider(height: 20),
                  _buildRow('Audited By', verificationBody),
                  const Divider(height: 20),
                  _buildRow('Validity', verifiedDate),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Seal Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield, color: AppTheme.primaryTeal, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tamper-proof verified by Portea Home Healthcare Clinical Registry.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close Preview'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isMono = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: isMono ? 'Courier' : null,
            color: isGreen ? AppTheme.successGreen : null,
          ),
        ),
      ],
    );
  }
}
