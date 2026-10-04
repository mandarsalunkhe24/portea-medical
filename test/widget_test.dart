import 'package:flutter_test/flutter_test.dart';
import 'package:portea_healthcare/core/pricing.dart';
import 'package:portea_healthcare/models/booking_model.dart';
import 'package:portea_healthcare/providers/booking_provider.dart';
import 'package:portea_healthcare/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Pricing and Bulk Discount Logic Tests', () {
    test('Nurse base price is Rs. 599 and Physio is Rs. 799', () {
      expect(PricingCalculator.getBasePricePerVisit('Nurse'), 599.0);
      expect(PricingCalculator.getBasePricePerVisit('Physiotherapy'), 799.0);
    });

    test('10-visit care plan automatically applies 15% bulk discount', () {
      // 10 visits for Nurse: 599 * 10 = 5990, 15% discount = 898.50, final = 5091.50
      final nursePlan = PricingCalculator.calculateCarePlanPricing(
        serviceType: 'Nurse',
        numberOfVisits: 10,
      );
      expect(nursePlan.isDiscountApplied, true);
      expect(nursePlan.discountPercentage, 15);
      expect(nursePlan.originalTotal, 5990.0);
      expect(nursePlan.discountAmount, 898.50);
      expect(nursePlan.finalTotal, 5091.50);

      // 10 visits for Physio: 799 * 10 = 7990, 15% discount = 1198.50, final = 6791.50
      final physioPlan = PricingCalculator.calculateCarePlanPricing(
        serviceType: 'Physiotherapy',
        numberOfVisits: 10,
      );
      expect(physioPlan.isDiscountApplied, true);
      expect(physioPlan.discountPercentage, 15);
      expect(physioPlan.originalTotal, 7990.0);
      expect(physioPlan.discountAmount, 1198.50);
      expect(physioPlan.finalTotal, 6791.50);
    });

    test('Care plan with fewer than 10 visits receives 0% discount', () {
      final plan5 = PricingCalculator.calculateCarePlanPricing(
        serviceType: 'Physiotherapy',
        numberOfVisits: 5,
      );
      expect(plan5.isDiscountApplied, false);
      expect(plan5.discountPercentage, 0);
      expect(plan5.discountAmount, 0.0);
      expect(plan5.finalTotal, 799.0 * 5);
    });

    test('Equipment rental pricing includes duration discounts and refundable deposit', () {
      // 1 Month: 3499 rate + 5000 deposit = 8499
      final rent1 = PricingCalculator.calculateEquipmentRentalPricing(
        monthlyRate: 3499.0,
        durationMonths: 1,
        refundableDeposit: 5000.0,
      );
      expect(rent1.grandTotal, 8499.0);
      expect(rent1.discountAmount, 0.0);

      // 3 Months: 3499 * 3 = 10497, 5% off = 524.85, deposit 5000
      final rent3 = PricingCalculator.calculateEquipmentRentalPricing(
        monthlyRate: 3499.0,
        durationMonths: 3,
        refundableDeposit: 5000.0,
      );
      expect(rent3.discountPercentage, 5);
      expect(rent3.discountAmount, 10497 * 0.05);
    });
  });

  group('Double-Booking Prevention Tests', () {
    test('Prevents booking duplicate slot for the same professional on the same day', () async {
      final bookingProv = BookingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final testDate = DateTime(2026, 10, 15);
      const testSlot = '10:00 AM - 11:00 AM';
      const profId = 'prof_nurse_1';

      final booking1 = Booking(
        id: 'TEST-BK-1',
        serviceTitle: 'Nurse Home Visit',
        professionalId: profId,
        professionalName: 'Sister Ananya Sharma',
        professionalRole: 'Nurse',
        professionalPhoto: '',
        patientName: 'Test Patient A',
        patientAge: 60,
        address: 'Kharghar, Navi Mumbai',
        date: testDate,
        timeSlot: testSlot,
        price: 599.0,
      );

      final result1 = await bookingProv.createBooking(booking1);
      expect(result1['success'], true);

      // Attempt to book the EXACT SAME professional on the same day and slot
      final booking2 = Booking(
        id: 'TEST-BK-2',
        serviceTitle: 'Wound Dressing',
        professionalId: profId,
        professionalName: 'Sister Ananya Sharma',
        professionalRole: 'Nurse',
        professionalPhoto: '',
        patientName: 'Test Patient B',
        patientAge: 45,
        address: 'Vashi, Navi Mumbai',
        date: testDate,
        timeSlot: testSlot,
        price: 599.0,
      );

      final result2 = await bookingProv.createBooking(booking2);
      expect(result2['success'], false);
      expect(result2['message'].toString().contains('already booked'), true);
    });
  });

  group('Widget App Smoke Test', () {
    testWidgets('Renders PorteaAppRoot correctly without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const PorteaAppRoot());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(PorteaAppRoot), findsOneWidget);
    });
  });
}
