import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import 'patients_list_screen.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTealLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: AppTheme.primaryTeal),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Academic Project',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppConstants.projectTitle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              '${AppConstants.department}\n${AppConstants.university}',
              style: TextStyle(fontSize: 13, color: AppTheme.primaryTealDark, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24),
            Text(
              'A complete, production-grade cross-platform Flutter application for booking home healthcare services with verified clinical professionals, dynamic care plan recurrence, 15% bulk discounts, elderly care, equipment rentals, live delivery tracking, and 24x7 emergency SOS.',
              style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Developed by: Mandar Salunkhe\nBatch: B.Tech CSE & AI (2023-2027)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPaymentHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Payment & Invoice History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildPaymentTile('PRT-TXN-9021', 'Knee Physiotherapy Visit', 'Rs. 799', 'UPI Paid', '28 Sep 2026'),
              _buildPaymentTile('PRT-TXN-8842', 'Oxygen Concentrator Rental', 'Rs. 8,499', 'NetBanking', '25 Sep 2026'),
              _buildPaymentTile('PRT-TXN-7719', '10-Visit Nursing Care Plan', 'Rs. 5,091.50', 'Card', '18 Sep 2026'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(String id, String item, String amount, String mode, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('$id • $mode • $date', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryTeal),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProv = Provider.of<AuthProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final user = authProv.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.primaryTeal,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Mandar Salunkhe',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.phone ?? '+91 98765 43210',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        Text(
                          user?.email ?? 'mandar.salunkhe@itm.edu',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Manage Profiles Section
            _buildSectionCard(
              title: 'Family & Delivery Profiles',
              children: [
                _buildListTile(
                  icon: Icons.people_outline,
                  title: 'Manage Patients',
                  subtitle: '${user?.patients.length ?? 0} Saved patient profiles',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientsListScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  subtitle: '${user?.savedAddresses.length ?? 0} Saved home visit locations',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AddressesScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.payment_outlined,
                  title: 'Payment & Receipts',
                  subtitle: 'Invoices, GST receipts, and transaction history',
                  onTap: () => _showPaymentHistory(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preferences
            _buildSectionCard(
              title: 'App Preferences',
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Toggle between light & dark healthcare theme', style: TextStyle(fontSize: 12)),
                  value: themeProv.isDarkMode,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => themeProv.toggleTheme(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Care & Vitals Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receive arrival alerts and daily elder health reports', style: TextStyle(fontSize: 12)),
                  value: _notificationsEnabled,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('App Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(_selectedLanguage, style: const TextStyle(fontSize: 12)),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    items: ['English', 'Hindi (हिंदी)', 'Marathi (मराठी)']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedLanguage = val!);
                      AppUtils.showToast(context, 'Language set to $_selectedLanguage');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // About & Help
            _buildSectionCard(
              title: 'Support & Academic Accreditation',
              children: [
                _buildListTile(
                  icon: Icons.school_outlined,
                  title: 'About Project 123 & ITM University',
                  subtitle: 'B.Tech CSE & AI final project specification',
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Portea Clinical Helpline',
                  subtitle: 'Call toll-free 1800-121-2323',
                  onTap: () => AppUtils.makePhoneCall(context, AppConstants.porteaHelplineNumber),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProv.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: AppTheme.emergencyRed),
                label: const Text('Sign Out of Portea', style: TextStyle(color: AppTheme.emergencyRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.emergencyRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryTeal, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
