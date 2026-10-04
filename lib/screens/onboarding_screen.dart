import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _slides = [
    OnboardingItem(
      title: 'Hospital-Quality Care at Home',
      subtitle:
          'Verified, ICU-trained nurses for IV infusions, sterile wound dressings, injections, and post-surgical recovery at your doorstep.',
      icon: Icons.health_and_safety_rounded,
      color: AppTheme.primaryTeal,
      accentBg: AppTheme.primaryTealLight,
    ),
    OnboardingItem(
      title: 'Expert Home Physiotherapy',
      subtitle:
          'Specialized orthopedic and neurological physiotherapists to accelerate post-knee replacement and stroke rehabilitation in living comfort.',
      icon: Icons.accessibility_new_rounded,
      color: AppTheme.secondaryBlue,
      accentBg: AppTheme.secondaryBlueLight,
    ),
    OnboardingItem(
      title: 'Elderly Care & Medical Rentals',
      subtitle:
          'Compassionate daily senior attendants and instant rental of hospital beds, oxygen concentrators, and wheelchairs with 24x7 SOS backup.',
      icon: Icons.volunteer_activism_rounded,
      color: AppTheme.successGreen,
      accentBg: AppTheme.successGreenLight,
    ),
  ];

  void _finishOnboarding() async {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    await authProv.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Giant Feature Icon Container
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: slide.accentBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: slide.color.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 80,
                            color: slide.color,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppTheme.primaryTeal
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color accentBg;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.accentBg,
  });
}
