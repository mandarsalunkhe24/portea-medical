import 'package:flutter/material.dart';
import '../core/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusChip({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
      case 'approved':
        bg = AppTheme.successGreenLight;
        fg = AppTheme.successGreen;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        bg = AppTheme.emergencyRedLight;
        fg = AppTheme.emergencyRed;
        icon = Icons.cancel;
        break;
      case 'in progress':
      case 'out for delivery':
      case 'on the way':
      case 'in review':
        bg = AppTheme.warningAmberLight;
        fg = AppTheme.warningAmber;
        icon = Icons.timelapse;
        break;
      case 'professional assigned':
      case 'packed':
      case 'active':
        bg = AppTheme.secondaryBlueLight;
        fg = AppTheme.secondaryBlue;
        icon = Icons.person_pin_circle;
        break;
      case 'paused':
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        icon = Icons.pause_circle_outline;
        break;
      case 'booked':
      case 'order placed':
      case 'submitted':
      case 'scheduled':
      default:
        bg = AppTheme.primaryTealLight;
        fg = AppTheme.primaryTeal;
        icon = Icons.event_available;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: fg,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
