import 'dart:convert';

class ServiceCompletionEvidence {
  final String? photoPath;
  final String notes;
  final String bloodPressure;
  final String pulseRate;
  final String temperature;
  final bool professionalConfirmed;
  final bool patientConfirmed;
  final DateTime completedAt;

  ServiceCompletionEvidence({
    this.photoPath,
    required this.notes,
    this.bloodPressure = '',
    this.pulseRate = '',
    this.temperature = '',
    this.professionalConfirmed = true,
    this.patientConfirmed = true,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'photoPath': photoPath,
      'notes': notes,
      'bloodPressure': bloodPressure,
      'pulseRate': pulseRate,
      'temperature': temperature,
      'professionalConfirmed': professionalConfirmed,
      'patientConfirmed': patientConfirmed,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory ServiceCompletionEvidence.fromMap(Map<String, dynamic> map) {
    return ServiceCompletionEvidence(
      photoPath: map['photoPath'],
      notes: map['notes'] ?? '',
      bloodPressure: map['bloodPressure'] ?? '',
      pulseRate: map['pulseRate'] ?? '',
      temperature: map['temperature'] ?? '',
      professionalConfirmed: map['professionalConfirmed'] ?? true,
      patientConfirmed: map['patientConfirmed'] ?? true,
      completedAt: DateTime.parse(
          map['completedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Booking {
  final String id;
  final String serviceTitle;
  final String professionalId;
  final String professionalName;
  final String professionalRole;
  final String professionalPhoto;
  final String patientName;
  final int patientAge;
  final String address;
  final DateTime date;
  final String timeSlot;
  final double price;
  final String status; // 'Booked', 'Professional Assigned', 'On the way', 'In Progress', 'Completed', 'Cancelled'
  final String notes;
  final ServiceCompletionEvidence? evidence;
  final bool hasReview;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.serviceTitle,
    required this.professionalId,
    required this.professionalName,
    required this.professionalRole,
    required this.professionalPhoto,
    required this.patientName,
    required this.patientAge,
    required this.address,
    required this.date,
    required this.timeSlot,
    required this.price,
    this.status = 'Booked',
    this.notes = '',
    this.evidence,
    this.hasReview = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Booking copyWith({
    String? status,
    ServiceCompletionEvidence? evidence,
    bool? hasReview,
    DateTime? date,
    String? timeSlot,
  }) {
    return Booking(
      id: id,
      serviceTitle: serviceTitle,
      professionalId: professionalId,
      professionalName: professionalName,
      professionalRole: professionalRole,
      professionalPhoto: professionalPhoto,
      patientName: patientName,
      patientAge: patientAge,
      address: address,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      price: price,
      status: status ?? this.status,
      notes: notes,
      evidence: evidence ?? this.evidence,
      hasReview: hasReview ?? this.hasReview,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceTitle': serviceTitle,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'professionalRole': professionalRole,
      'professionalPhoto': professionalPhoto,
      'patientName': patientName,
      'patientAge': patientAge,
      'address': address,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'price': price,
      'status': status,
      'notes': notes,
      'evidence': evidence?.toMap(),
      'hasReview': hasReview,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? '',
      serviceTitle: map['serviceTitle'] ?? '',
      professionalId: map['professionalId'] ?? '',
      professionalName: map['professionalName'] ?? '',
      professionalRole: map['professionalRole'] ?? '',
      professionalPhoto: map['professionalPhoto'] ?? '',
      patientName: map['patientName'] ?? '',
      patientAge: map['patientAge'] ?? 0,
      address: map['address'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      timeSlot: map['timeSlot'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Booked',
      notes: map['notes'] ?? '',
      evidence: map['evidence'] != null
          ? ServiceCompletionEvidence.fromMap(
              Map<String, dynamic>.from(map['evidence']))
          : null,
      hasReview: map['hasReview'] ?? false,
      createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());
  factory Booking.fromJson(String source) =>
      Booking.fromMap(json.decode(source));
}
