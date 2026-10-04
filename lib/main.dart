import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/professionals_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/care_plan_provider.dart';
import 'providers/equipment_provider.dart';
import 'providers/emergency_provider.dart';
import 'providers/insurance_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (optional): if it is not configured yet the app falls back to the
  // built-in demo login, so this never blocks the app from starting.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase not initialised, using demo auth: $e');
  }

  // Set preferred portrait orientation & modern system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PorteaAppRoot());
}

class PorteaAppRoot extends StatelessWidget {
  const PorteaAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfessionalsProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => CarePlanProvider()),
        ChangeNotifierProvider(create: (_) => EquipmentProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => InsuranceProvider()),
      ],
      child: const PorteaMedicalApp(),
    );
  }
}

class PorteaMedicalApp extends StatelessWidget {
  const PorteaMedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProv.themeMode,
      home: const SplashScreen(),
    );
  }
}
