import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/care_plan_provider.dart';
import '../../providers/professionals_provider.dart';
import '../../widgets/custom_network_image.dart';
import '../professionals/professional_list_screen.dart';
import '../professionals/professional_profile_screen.dart';
import '../bookings/booking_detail_screen.dart';
import '../care_plan/care_plan_creator_screen.dart';
import '../elderly_care/elderly_care_package_screen.dart';
import '../insurance/insurance_assistance_screen.dart';
import '../equipment/delivery_tracking_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeDashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProv = Provider.of<AuthProvider>(context);
    final bookingProv = Provider.of<BookingProvider>(context);
    final carePlanProv = Provider.of<CarePlanProvider>(context);
    final profProv = Provider.of<ProfessionalsProvider>(context);

    final user = authProv.currentUser;
    final nextAppointment = bookingProv.nextUpcomingAppointment;
    final topProfessionals = profProv.allProfessionals.take(4).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 16,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryTealLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppTheme.primaryTeal,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CURRENT LOCATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Kharghar, Navi Mumbai',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Track Medical Delivery',
            icon: const Icon(Icons.local_shipping_outlined, color: AppTheme.primaryTeal),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DeliveryTrackingScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Insurance Assistance',
            icon: const Icon(Icons.shield_outlined, color: AppTheme.secondaryBlue),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InsuranceAssistanceScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // In-memory refresh simulation
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting & Project Subtitle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.name.split(' ').first ?? 'User'} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'How can Portea Medical help your family today?',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTealLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ITM Skills Univ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTealDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfessionalListScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF64748B), size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Search nurse, physio, elderly care, equipment...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Offers Banner (15% Off Care Package)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CarePlanCreatorScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00695C), Color(0xFF00897B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.discount_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARE PACKAGE OFFER',
                              style: TextStyle(
                                color: Color(0xFF80CBC4),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Save 15% on 10+ Visits',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Automatic discount on recurring nurse & physio care plans.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Service Categories Grid
              const Text(
                'Healthcare Services at Home',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 124,
                ),
                children: [
                  _buildServiceCard(
                    context,
                    title: 'Nurse Visit',
                    subtitle: 'From ${PricingCalculator.formatCurrency(PricingCalculator.nurseVisitBasePrice)}',
                    icon: Icons.health_and_safety,
                    iconColor: AppTheme.primaryTeal,
                    bgColor: AppTheme.primaryTealLight,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfessionalListScreen(
                            initialRole: 'Nurse',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    context,
                    title: 'Physiotherapy',
                    subtitle: 'From ${PricingCalculator.formatCurrency(PricingCalculator.physioVisitBasePrice)}',
                    icon: Icons.accessibility_new,
                    iconColor: AppTheme.secondaryBlue,
                    bgColor: AppTheme.secondaryBlueLight,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfessionalListScreen(
                            initialRole: 'Physiotherapist',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    context,
                    title: 'Equipment Rental',
                    subtitle: 'From ${PricingCalculator.formatCurrency(PricingCalculator.minimumEquipmentMonthlyPrice)}/mo',
                    icon: Icons.wheelchair_pickup,
                    iconColor: const Color(0xFFE65100),
                    bgColor: const Color(0xFFFFF3E0),
                    onTap: () {
                      onNavigateTab(3); // Equipment tab
                    },
                  ),
                  _buildServiceCard(
                    context,
                    title: 'Elderly Care',
                    subtitle: 'Daily visits ${PricingCalculator.formatCurrency(PricingCalculator.elderlyCareMonthlyPrice)}/mo',
                    icon: Icons.volunteer_activism,
                    iconColor: AppTheme.successGreen,
                    bgColor: AppTheme.successGreenLight,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ElderlyCarePackageScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Upcoming Appointment Card
              if (nextAppointment != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Appointment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomNetworkImage(
                              imageUrl: nextAppointment.professionalPhoto,
                              fallbackText: nextAppointment.professionalName,
                              width: 50,
                              height: 50,
                              isCircle: true,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextAppointment.serviceTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${nextAppointment.professionalName} • ${nextAppointment.professionalRole}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryBlueLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                nextAppointment.status,
                                style: const TextStyle(
                                  color: AppTheme.secondaryBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryTeal),
                            const SizedBox(width: 6),
                            Text(
                              AppUtils.formatDate(nextAppointment.date),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 16, color: AppTheme.primaryTeal),
                            const SizedBox(width: 6),
                            Text(
                              nextAppointment.timeSlot,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Patient: ${nextAppointment.patientName}',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BookingDetailScreen(
                                      bookingId: nextAppointment.id,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('View Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],

              // Quick Stats Section
              const Text(
                'Healthcare Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Bookings',
                      value: '${bookingProv.totalBookingsCount}',
                      icon: Icons.bookmark_added_outlined,
                      color: AppTheme.primaryTeal,
                      bg: AppTheme.primaryTealLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Active Plans',
                      value: '${carePlanProv.activeCarePlansCount}',
                      icon: Icons.calendar_month_outlined,
                      color: AppTheme.secondaryBlue,
                      bg: AppTheme.secondaryBlueLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Completed',
                      value: '${bookingProv.completedVisitsCount}',
                      icon: Icons.check_circle_outline,
                      color: AppTheme.successGreen,
                      bg: AppTheme.successGreenLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Top Rated Professionals (Horizontal Scroll)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Rated Professionals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfessionalListScreen(),
                        ),
                      );
                    },
                    child: const Text('View All (8)'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: topProfessionals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final prof = topProfessionals[index];
                    return _buildProfessionalHorizontalCard(context, prof);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Quick Utility Links (Insurance Help & Delivery Tracking)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const InsuranceAssistanceScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shield_outlined, size: 18),
                      label: const Text('Insurance Help'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DeliveryTrackingScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_shipping_outlined, size: 18),
                      label: const Text('Track Delivery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalHorizontalCard(BuildContext context, dynamic prof) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'prof_photo_${prof.id}',
                child: CustomNetworkImage(
                  imageUrl: prof.photoUrl,
                  fallbackText: prof.name,
                  width: 70,
                  height: 70,
                  isCircle: true,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                prof.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                prof.role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${prof.rating} (${prof.reviewCount})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${PricingCalculator.formatCurrency(prof.pricePerVisit)}/visit',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
