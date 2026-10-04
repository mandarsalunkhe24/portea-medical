import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/pricing.dart';
import '../models/care_plan_model.dart';
import '../data/mock_data.dart';

class CarePlanProvider extends ChangeNotifier {
  List<CarePlan> _carePlans = [];
  bool _isLoading = true;

  List<CarePlan> get allCarePlans => _carePlans;
  bool get isLoading => _isLoading;

  List<CarePlan> get activeCarePlans =>
      _carePlans.where((c) => c.status == 'Active').toList();

  int get activeCarePlansCount => activeCarePlans.length;

  CarePlanProvider() {
    _initCarePlans();
  }

  Future<void> _initCarePlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getString(AppConstants.prefCarePlansKey);

      if (plansJson != null && plansJson.isNotEmpty) {
        final decoded = json.decode(plansJson) as List<dynamic>;
        _carePlans = decoded
            .map((c) => CarePlan.fromMap(Map<String, dynamic>.from(c)))
            .toList();
      } else {
        _carePlans = MockData.getInitialSampleCarePlans();
        await _saveCarePlansToPrefs();
      }
    } catch (e) {
      debugPrint('Error init care plans: $e');
      _carePlans = MockData.getInitialSampleCarePlans();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper to generate recurring visit dates based on frequency
  static List<CarePlanVisit> generateSchedule({
    required DateTime startDate,
    required String frequency,
    required int numberOfVisits,
    required String timeSlot,
    List<int> customWeekdays = const [1, 3, 5], // Mon, Wed, Fri
  }) {
    List<CarePlanVisit> visits = [];
    DateTime currentDate = startDate;
    int visitsCount = 0;

    while (visitsCount < numberOfVisits) {
      bool shouldInclude = true;

      if (frequency == 'Alternate days') {
        // Will step by 2 days
      } else if (frequency == 'Weekly') {
        // Will step by 7 days
      } else if (frequency == 'Custom weekdays') {
        shouldInclude = customWeekdays.contains(currentDate.weekday);
      }

      if (shouldInclude) {
        visits.add(CarePlanVisit(
          visitNumber: visitsCount + 1,
          date: currentDate,
          timeSlot: timeSlot,
          status: 'Scheduled',
        ));
        visitsCount++;
      }

      if (frequency == 'Daily') {
        currentDate = currentDate.add(const Duration(days: 1));
      } else if (frequency == 'Alternate days') {
        currentDate = currentDate.add(const Duration(days: 2));
      } else if (frequency == 'Weekly') {
        currentDate = currentDate.add(const Duration(days: 7));
      } else {
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return visits;
  }

  /// Create and save a new care plan with pricing
  Future<CarePlan> createCarePlan({
    required String title,
    required String serviceType,
    required String professionalId,
    required String professionalName,
    required String professionalRole,
    required String patientName,
    required DateTime startDate,
    required String frequency,
    required int numberOfVisits,
    required String preferredTimeSlot,
    List<int> customWeekdays = const [1, 3, 5],
  }) async {
    final pricing = PricingCalculator.calculateCarePlanPricing(
      serviceType: serviceType,
      numberOfVisits: numberOfVisits,
    );

    final visits = generateSchedule(
      startDate: startDate,
      frequency: frequency,
      numberOfVisits: numberOfVisits,
      timeSlot: preferredTimeSlot,
      customWeekdays: customWeekdays,
    );

    final carePlan = CarePlan(
      id: 'CP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      title: title,
      serviceType: serviceType,
      professionalId: professionalId,
      professionalName: professionalName,
      professionalRole: professionalRole,
      patientName: patientName,
      startDate: startDate,
      frequency: frequency,
      numberOfVisits: numberOfVisits,
      preferredTimeSlot: preferredTimeSlot,
      originalPrice: pricing.originalTotal,
      discountAmount: pricing.discountAmount,
      finalPrice: pricing.finalTotal,
      status: 'Active',
      visits: visits,
    );

    _carePlans.insert(0, carePlan);
    notifyListeners();
    await _saveCarePlansToPrefs();

    return carePlan;
  }

  /// Pause care plan
  Future<void> pauseCarePlan(String id) async {
    final index = _carePlans.indexWhere((c) => c.id == id);
    if (index != -1) {
      _carePlans[index] = _carePlans[index].copyWith(status: 'Paused');
      notifyListeners();
      await _saveCarePlansToPrefs();
    }
  }

  /// Resume care plan
  Future<void> resumeCarePlan(String id) async {
    final index = _carePlans.indexWhere((c) => c.id == id);
    if (index != -1) {
      _carePlans[index] = _carePlans[index].copyWith(status: 'Active');
      notifyListeners();
      await _saveCarePlansToPrefs();
    }
  }

  /// Cancel care plan
  Future<void> cancelCarePlan(String id) async {
    final index = _carePlans.indexWhere((c) => c.id == id);
    if (index != -1) {
      _carePlans[index] = _carePlans[index].copyWith(status: 'Cancelled');
      notifyListeners();
      await _saveCarePlansToPrefs();
    }
  }

  /// Mark visit completed
  Future<void> markVisitCompleted(String planId, int visitNumber) async {
    final planIndex = _carePlans.indexWhere((c) => c.id == planId);
    if (planIndex != -1) {
      final plan = _carePlans[planIndex];
      final updatedVisits = List<CarePlanVisit>.from(plan.visits);
      final vIndex = updatedVisits.indexWhere((v) => v.visitNumber == visitNumber);
      if (vIndex != -1) {
        updatedVisits[vIndex] = updatedVisits[vIndex].copyWith(
          status: 'Completed',
          completedAt: DateTime.now(),
        );

        final allCompleted = updatedVisits.every((v) => v.status == 'Completed');
        _carePlans[planIndex] = plan.copyWith(
          visits: updatedVisits,
          status: allCompleted ? 'Completed' : plan.status,
        );
        notifyListeners();
        await _saveCarePlansToPrefs();
      }
    }
  }

  CarePlan? getCarePlanById(String id) {
    try {
      return _carePlans.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCarePlansToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_carePlans.map((c) => c.toMap()).toList());
    await prefs.setString(AppConstants.prefCarePlansKey, jsonString);
  }
}
