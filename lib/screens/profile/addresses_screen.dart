import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  void _showAddAddressDialog(BuildContext context) {
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Service Address'),
        content: TextField(
          controller: addrCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Flat / House No, Building, Landmark, City, Pincode',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (addrCtrl.text.trim().isEmpty) return;
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.addAddress(addrCtrl.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                AppUtils.showToast(context, 'Address added to profile');
              }
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final addresses = auth.currentUser?.savedAddresses ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Saved Service Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () => _showAddAddressDialog(context),
          ),
        ],
      ),
      body: addresses.isEmpty
          ? const Center(child: Text('No addresses saved.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addr = addresses[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.primaryTealLight,
                      child: Icon(Icons.location_on, color: AppTheme.primaryTeal),
                    ),
                    title: Text(
                      'Address #${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(addr, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_address_fab',
        onPressed: () => _showAddAddressDialog(context),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }
}
