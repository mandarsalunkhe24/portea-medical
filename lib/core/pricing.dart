import 'package:intl/intl.dart';

class PricingCalculator {
  // Base rates per visit
  static const double nurseVisitBasePrice = 599.0;
  static const double physioVisitBasePrice = 799.0;
  static const double elderlyCareMonthlyPrice = 8999.0;
  static const double minimumEquipmentMonthlyPrice = 499.0;

  // Discount percentage for 10 or more visits
  static const double bulkVisitDiscountPercentage = 0.15; // 15%
  static const int bulkDiscountThreshold = 10;

  // Multi-month equipment rental discounts
  static const double equipment3MonthDiscount = 0.05; // 5%
  static const double equipment6MonthDiscount = 0.10; // 10%

  /// Returns base price per visit for a service type
  static double getBasePricePerVisit(String serviceType) {
    final lower = serviceType.toLowerCase();
    if (lower.contains('physio')) {
      return physioVisitBasePrice;
    } else if (lower.contains('elderly') || lower.contains('geriatric')) {
      return 499.0; // Per visit caregiver rate if part of custom visits
    }
    return nurseVisitBasePrice;
  }

  /// Calculates pricing details for a care plan or multi-visit booking
  static CarePlanPricing calculateCarePlanPricing({
    required String serviceType,
    required int numberOfVisits,
  }) {
    final basePrice = getBasePricePerVisit(serviceType);
    final originalTotal = basePrice * numberOfVisits;
    final isDiscountEligible = numberOfVisits >= bulkDiscountThreshold;
    final discountAmount = isDiscountEligible
        ? (originalTotal * bulkVisitDiscountPercentage)
        : 0.0;
    final finalTotal = originalTotal - discountAmount;
    final effectivePerVisitPrice =
        numberOfVisits > 0 ? (finalTotal / numberOfVisits) : basePrice;

    return CarePlanPricing(
      basePerVisitPrice: basePrice,
      numberOfVisits: numberOfVisits,
      originalTotal: originalTotal,
      discountPercentage: isDiscountEligible ? 15 : 0,
      discountAmount: discountAmount,
      finalTotal: finalTotal,
      effectivePerVisitPrice: effectivePerVisitPrice,
      isDiscountApplied: isDiscountEligible,
    );
  }

  /// Calculates equipment rental pricing
  static EquipmentRentalPricing calculateEquipmentRentalPricing({
    required double monthlyRate,
    required int durationMonths,
    double refundableDeposit = 1000.0,
  }) {
    final baseRentalCost = monthlyRate * durationMonths;
    double discountPercentage = 0.0;
    if (durationMonths >= 6) {
      discountPercentage = equipment6MonthDiscount;
    } else if (durationMonths >= 3) {
      discountPercentage = equipment3MonthDiscount;
    }

    final discountAmount = baseRentalCost * discountPercentage;
    final discountedRentalCost = baseRentalCost - discountAmount;
    final grandTotal = discountedRentalCost + refundableDeposit;

    return EquipmentRentalPricing(
      monthlyRate: monthlyRate,
      durationMonths: durationMonths,
      refundableDeposit: refundableDeposit,
      baseRentalCost: baseRentalCost,
      discountPercentage: (discountPercentage * 100).toInt(),
      discountAmount: discountAmount,
      discountedRentalCost: discountedRentalCost,
      grandTotal: grandTotal,
    );
  }

  /// Formats currency with Indian numbering system and Rs. symbol
  static String formatCurrency(double amount, {bool showDecimals = false}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs. ',
      decimalDigits: showDecimals ? 2 : 0,
    );
    return formatter.format(amount);
  }
}

class CarePlanPricing {
  final double basePerVisitPrice;
  final int numberOfVisits;
  final double originalTotal;
  final int discountPercentage;
  final double discountAmount;
  final double finalTotal;
  final double effectivePerVisitPrice;
  final bool isDiscountApplied;

  CarePlanPricing({
    required this.basePerVisitPrice,
    required this.numberOfVisits,
    required this.originalTotal,
    required this.discountPercentage,
    required this.discountAmount,
    required this.finalTotal,
    required this.effectivePerVisitPrice,
    required this.isDiscountApplied,
  });

  String get originalFormatted =>
      PricingCalculator.formatCurrency(originalTotal);
  String get finalFormatted =>
      PricingCalculator.formatCurrency(finalTotal, showDecimals: (finalTotal % 1 != 0));
  String get discountFormatted =>
      PricingCalculator.formatCurrency(discountAmount, showDecimals: (discountAmount % 1 != 0));
  String get effectivePerVisitFormatted =>
      PricingCalculator.formatCurrency(effectivePerVisitPrice, showDecimals: (effectivePerVisitPrice % 1 != 0));
}

class EquipmentRentalPricing {
  final double monthlyRate;
  final int durationMonths;
  final double refundableDeposit;
  final double baseRentalCost;
  final int discountPercentage;
  final double discountAmount;
  final double discountedRentalCost;
  final double grandTotal;

  EquipmentRentalPricing({
    required this.monthlyRate,
    required this.durationMonths,
    required this.refundableDeposit,
    required this.baseRentalCost,
    required this.discountPercentage,
    required this.discountAmount,
    required this.discountedRentalCost,
    required this.grandTotal,
  });

  String get grandTotalFormatted =>
      PricingCalculator.formatCurrency(grandTotal);
  String get rentalCostFormatted =>
      PricingCalculator.formatCurrency(discountedRentalCost);
  String get depositFormatted =>
      PricingCalculator.formatCurrency(refundableDeposit);
  String get discountFormatted =>
      PricingCalculator.formatCurrency(discountAmount);
}
