import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../models/equipment_model.dart';
import '../../providers/equipment_provider.dart';
import '../../widgets/custom_network_image.dart';
import 'equipment_detail_screen.dart';
import 'my_rentals_screen.dart';
import 'delivery_tracking_screen.dart';

class EquipmentCatalogScreen extends StatefulWidget {
  const EquipmentCatalogScreen({super.key});

  @override
  State<EquipmentCatalogScreen> createState() => _EquipmentCatalogScreenState();
}

class _EquipmentCatalogScreenState extends State<EquipmentCatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _categories = [
    'All',
    'Mobility',
    'Respiratory',
    'Patient Care',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eqProv = Provider.of<EquipmentProvider>(context);
    final equipment = eqProv.filteredEquipment;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Medical Equipment Rental'),
        actions: [
          IconButton(
            tooltip: 'Track Active Delivery',
            icon: const Icon(Icons.local_shipping_outlined, color: AppTheme.primaryTeal),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeliveryTrackingScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'My Rental Orders',
            icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.secondaryBlue),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyRentalsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Category Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search oxygen, hospital bed, wheelchair...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              eqProv.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) => eqProv.setSearchQuery(val),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = eqProv.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => eqProv.setCategory(cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Catalog Grid
          Expanded(
            child: equipment.isEmpty
                ? const Center(child: Text('No equipment items match your search.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: equipment.length,
                    itemBuilder: (context, index) {
                      final item = equipment[index];
                      return _buildEquipmentCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, Equipment item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EquipmentDetailScreen(equipment: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomNetworkImage(
                      imageUrl: item.imageUrl,
                      fallbackIcon: equipmentCategoryIcon(item.category),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Category Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Title
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),

              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Rental',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        '${PricingCalculator.formatCurrency(item.monthlyRate)}/mo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.primaryTeal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
