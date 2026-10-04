import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../providers/professionals_provider.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/verified_badge.dart';
import 'professional_profile_screen.dart';

class ProfessionalListScreen extends StatefulWidget {
  final String? initialRole;

  const ProfessionalListScreen({super.key, this.initialRole});

  @override
  State<ProfessionalListScreen> createState() => _ProfessionalListScreenState();
}

class _ProfessionalListScreenState extends State<ProfessionalListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<ProfessionalsProvider>(context, listen: false);
      if (widget.initialRole != null) {
        prov.setRole(widget.initialRole!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _FilterModalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profProv = Provider.of<ProfessionalsProvider>(context);
    final professionals = profProv.filteredProfessionals;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Verified Professionals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter & Sort',
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, skill, or condition...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              profProv.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) {
                    profProv.setSearchQuery(val);
                  },
                ),
                const SizedBox(height: 10),
                // Role filter horizontal chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleFilterChip('All', profProv),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Nurse', profProv),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Physiotherapist', profProv),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip('Elderly Caregiver', profProv),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active filter badges row
          if (profProv.selectedLanguage != 'All' ||
              profProv.minRating > 0 ||
              profProv.minExperience > 0 ||
              profProv.sortBy != 'rating')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.primaryTealLight.withOpacity(0.5),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16, color: AppTheme.primaryTeal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filters active: ${profProv.selectedLanguage != "All" ? "${profProv.selectedLanguage}, " : ""}${profProv.minRating > 0 ? "★${profProv.minRating}+, " : ""}${profProv.minExperience > 0 ? "${profProv.minExperience}+ yrs exp, " : ""}${profProv.sortBy}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryTealDark,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      profProv.resetFilters();
                      _searchController.clear();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Professionals List
          Expanded(
            child: professionals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No professionals match your filter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try clearing filters or search query',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            profProv.resetFilters();
                            _searchController.clear();
                          },
                          child: const Text('Reset All Filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: professionals.length,
                    itemBuilder: (context, index) {
                      final prof = professionals[index];
                      return _buildProfessionalItemCard(context, prof);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(String role, ProfessionalsProvider prov) {
    final isSelected = prov.selectedRole == role;
    return ChoiceChip(
      label: Text(role),
      selected: isSelected,
      onSelected: (_) => prov.setRole(role),
      selectedColor: AppTheme.primaryTealLight,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryTealDark : const Color(0xFF64748B),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildProfessionalItemCard(BuildContext context, dynamic prof) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
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
              builder: (_) => ProfessionalProfileScreen(
                professionalId: prof.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'prof_photo_${prof.id}',
                    child: CustomNetworkImage(
                      imageUrl: prof.photoUrl,
                      fallbackText: prof.name,
                      width: 76,
                      height: 76,
                      isCircle: true,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                prof.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const VerifiedBadge(showLabel: false, size: 14),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prof.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${prof.qualifications} • ${prof.experienceYears} yrs exp',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${prof.rating}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${prof.reviewCount} reviews)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Languages Spoken Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (prof.languages as List<String>)
                    .map<Widget>((lang) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            lang,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),

              // Specialization areas
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (prof.specializations as List<String>)
                    .take(3)
                    .map<Widget>((spec) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTealLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            spec,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryTealDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const Divider(height: 20),

              // Pricing and Book button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Home Visit Fee',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        PricingCalculator.formatCurrency(prof.pricePerVisit),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfessionalProfileScreen(
                            professionalId: prof.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('View Profile & Book'),
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

class _FilterModalSheet extends StatefulWidget {
  const _FilterModalSheet();

  @override
  State<_FilterModalSheet> createState() => _FilterModalSheetState();
}

class _FilterModalSheetState extends State<_FilterModalSheet> {
  late String _language;
  late double _rating;
  late int _experience;
  late String _sort;

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<ProfessionalsProvider>(context, listen: false);
    _language = prov.selectedLanguage;
    _rating = prov.minRating;
    _experience = prov.minExperience;
    _sort = prov.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProfessionalsProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter & Sort Professionals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),

          // Sort by
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _sortChip('Rating (High to Low)', 'rating'),
              _sortChip('Experience (High to Low)', 'experience'),
              _sortChip('Price (Low to High)', 'price_asc'),
              _sortChip('Price (High to Low)', 'price_desc'),
            ],
          ),
          const SizedBox(height: 16),

          // Languages
          const Text('Spoken Language', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['All', 'English', 'Hindi', 'Marathi', 'Gujarati', 'Tamil']
                .map((lang) => ChoiceChip(
                      label: Text(lang),
                      selected: _language == lang,
                      onSelected: (_) => setState(() => _language = lang),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Minimum Rating
          const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [0.0, 4.0, 4.5, 4.8].map((r) {
              final label = r == 0.0 ? 'Any' : '★ $r+';
              return ChoiceChip(
                label: Text(label),
                selected: _rating == r,
                onSelected: (_) => setState(() => _rating = r),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Minimum Experience
          const Text('Minimum Experience', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [0, 5, 8, 10].map((exp) {
              final label = exp == 0 ? 'Any' : '$exp+ Years';
              return ChoiceChip(
                label: Text(label),
                selected: _experience == exp,
                onSelected: (_) => setState(() => _experience = exp),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    prov.resetFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    prov.setLanguage(_language);
                    prov.setMinRating(_rating);
                    prov.setMinExperience(_experience);
                    prov.setSortBy(_sort);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _sort == value,
      onSelected: (_) => setState(() => _sort = value),
    );
  }
}
