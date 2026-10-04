import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import 'sos_floating_button.dart';
import '../screens/home/home_dashboard_screen.dart';
import '../screens/bookings/my_bookings_screen.dart';
import '../screens/care_plan/care_plans_screen.dart';
import '../screens/equipment/equipment_catalog_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppScaffold extends StatefulWidget {
  final int initialIndex;
  const AppScaffold({super.key, this.initialIndex = 0});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppUtils.isLargeScreen(context);

    final List<Widget> screens = [
      HomeDashboardScreen(onNavigateTab: _onTabSelected),
      const MyBookingsScreen(),
      const CarePlansScreen(),
      const EquipmentCatalogScreen(),
      const ProfileScreen(),
    ];

    if (isDesktop) {
      return Scaffold(
        floatingActionButton: const SosFloatingButton(),
        body: Row(
          children: [
            // Responsive Navigation Rail for Web & Desktop
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Portea',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: Text('Bookings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Care Plans'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.wheelchair_pickup_outlined),
                  selectedIcon: Icon(Icons.wheelchair_pickup),
                  label: Text('Equipment'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Centered max-width content area
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppUtils.contentMaxWidth(context),
                  ),
                  child: screens[_currentIndex],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout with BottomNavigationBar
    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: const SosFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryTeal,
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Care Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wheelchair_pickup_outlined),
            activeIcon: Icon(Icons.wheelchair_pickup),
            label: 'Equipment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
