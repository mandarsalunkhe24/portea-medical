import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/emergency_provider.dart';
import '../screens/sos/sos_screen.dart';

class SosFloatingButton extends StatelessWidget {
  const SosFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppTheme.emergencyShadow,
      ),
      child: FloatingActionButton.extended(
        heroTag: 'sos_fab_btn',
        onPressed: () => _showSosConfirmDialog(context),
        backgroundColor: AppTheme.emergencyRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.emergency_rounded, size: 28),
        label: const Text(
          'SOS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  static void _showSosConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => const _SosCountdownDialog(),
    );
  }
}

class _SosCountdownDialog extends StatefulWidget {
  const _SosCountdownDialog();

  @override
  State<_SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends State<_SosCountdownDialog> {
  int _secondsLeft = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _dispatchSos();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _dispatchSos() async {
    _timer?.cancel();
    if (!mounted) return;
    final nav = Navigator.of(context);
    final provider = Provider.of<EmergencyProvider>(context, listen: false);
    nav.pop(); // close dialog
    await provider.triggerSos(context);

    if (mounted) {
      nav.push(
        MaterialPageRoute(builder: (_) => const SosScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emergencyProv = Provider.of<EmergencyProvider>(context, listen: false);
    final primary = emergencyProv.primaryContact;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.emergencyRedLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.emergencyRed, width: 3),
              ),
              child: Center(
                child: Text(
                  '$_secondsLeft',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.emergencyRed,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'EMERGENCY SOS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.emergencyRed,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alerting Portea Medical 24x7 Emergency Grid and calling:\n${primary?.name ?? "Ambulance 108"} (${primary?.phone ?? "108"})',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 16, color: AppTheme.emergencyRed),
                  SizedBox(width: 6),
                  Text(
                    'GPS: 19.0438° N, 73.0674° E (Kharghar)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel Alert'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _dispatchSos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emergencyRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Call Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
