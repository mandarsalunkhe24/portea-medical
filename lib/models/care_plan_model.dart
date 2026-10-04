import 'dart:convert';

class CarePlanVisit {
  final int visitNumber;
  final DateTime date;
  final String timeSlot;
  final String status; // 'Scheduled', 'Completed', 'Skipped'
  final DateTime? completedAt;

  CarePlanVisit({
    required this.visitNumber,
    required this.date,
    required this.timeSlot,
    this.status = 'Scheduled',
    this.completedAt,
  });

  CarePlanVisit copyWith({
    String? status,
    DateTime? completedAt,
  }) {
    return CarePlanVisit(
      visitNumber: visitNumber,
      date: date,
      timeSlot: timeSlot,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitNumber': visitNumber,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory CarePlanVisit.fromMap(Map<String, dynamic> map) {
    return CarePlanVisit(
      visitNumber: map['visitNumber'] ?? 1,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'Scheduled',
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'])
          : null,
    );
  }
}

class CarePlan {
  final String id;
  final String title;
  final String serviceType;
  final String professionalId;
  final String professionalName;
  final String professionalRole;
  final String patientName;
  final DateTime startDate;
  final String frequency; // 'Daily', 'Alternate days', 'Weekly', 'Custom weekdays'
  final int numberOfVisits;
  final String preferredTimeSlot;
  final double originalPrice;
  final double discountAmount;
  final double finalPrice;
  final String status; // 'Active', 'Paused', 'Completed', 'Cancelled'
  final List<CarePlanVisit> visits;
  final DateTime createdAt;

  CarePlan({
    required this.id,
    required this.title,
    required this.serviceType,
    required this.professionalId,
    required this.professionalName,
    required this.professionalRole,
    required this.patientName,
    required this.startDate,
    required this.frequency,
    required this.numberOfVisits,
    required this.preferredTimeSlot,
    required this.originalPrice,
    required this.discountAmount,
    required this.finalPrice,
    this.status = 'Active',
    required this.visits,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get completedVisitsCount =>
      visits.where((v) => v.status == 'Completed').length;

  double get progressFraction =>
      numberOfVisits > 0 ? (completedVisitsCount / numberOfVisits) : 0.0;

  CarePlan copyWith({
    String? status,
    List<CarePlanVisit>? visits,
  }) {
    return CarePlan(
      id: id,
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
      originalPrice: originalPrice,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
      status: status ?? this.status,
      visits: visits ?? this.visits,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'serviceType': serviceType,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'professionalRole': professionalRole,
      'patientName': patientName,
      'startDate': startDate.toIso8601String(),
      'frequency': frequency,
      'numberOfVisits': numberOfVisits,
      'preferredTimeSlot': preferredTimeSlot,
      'originalPrice': originalPrice,
      'discountAmount': discountAmount,
      'finalPrice': finalPrice,
      'status': status,
      'visits': visits.map((v) => v.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CarePlan.fromMap(Map<String, dynamic> map) {
    return CarePlan(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      serviceType: map['serviceType'] ?? '',
      professionalId: map['professionalId'] ?? '',
      professionalName: map['professionalName'] ?? '',
      professionalRole: map['professionalRole'] ?? '',
      patientName: map['patientName'] ?? '',
      startDate: DateTime.parse(
          map['startDate'] ?? DateTime.now().toIso8601String()),
      frequency: map['frequency'] ?? 'Daily',
      numberOfVisits: map['numberOfVisits'] ?? 10,
      preferredTimeSlot: map['preferredTimeSlot'] ?? '10:00 AM - 11:00 AM',
      originalPrice: (map['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (map['finalPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Active',
      visits: (map['visits'] as List<dynamic>?)
              ?.map((v) => CarePlanVisit.fromMap(Map<String, dynamic>.from(v)))
              .toList() ??
          [],
      createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());
  factory CarePlan.fromJson(String source) =>
      CarePlan.fromMap(json.decode(source));
}
