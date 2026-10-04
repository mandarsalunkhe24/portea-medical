import 'package:flutter/material.dart';
import '../core/theme.dart';

class VerifiedBadge extends StatelessWidget {
  final bool showLabel;
  final double size;

  const VerifiedBadge({
    super.key,
    this.showLabel = true,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: AppTheme.successGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, size: size, color: Colors.white),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.successGreenLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: size, color: AppTheme.successGreen),
          const SizedBox(width: 4),
          const Text(
            'Verified Professional',
            style: TextStyle(
              color: AppTheme.successGreen,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
