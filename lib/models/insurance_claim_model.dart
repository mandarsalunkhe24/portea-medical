import 'dart:convert';

class InsuranceClaim {
  final String id;
  final String policyNumber;
  final String insurerName;
  final String patientName;
  final String serviceBooked;
  final String phone;
  final List<String> documentFileNames;
  final String status; // 'Submitted', 'In Review', 'Approved', 'Disbursed'
  final DateTime submissionDate;
  final double estimatedClaimAmount;
  final String trackingRemarks;

  InsuranceClaim({
    required this.id,
    required this.policyNumber,
    required this.insurerName,
    required this.patientName,
    required this.serviceBooked,
    required this.phone,
    required this.documentFileNames,
    this.status = 'Submitted',
    required this.submissionDate,
    required this.estimatedClaimAmount,
    this.trackingRemarks = 'Documents received by Portea TPA Desk',
  });

  InsuranceClaim copyWith({
    String? status,
    String? trackingRemarks,
  }) {
    return InsuranceClaim(
      id: id,
      policyNumber: policyNumber,
      insurerName: insurerName,
      patientName: patientName,
      serviceBooked: serviceBooked,
      phone: phone,
      documentFileNames: documentFileNames,
      status: status ?? this.status,
      submissionDate: submissionDate,
      estimatedClaimAmount: estimatedClaimAmount,
      trackingRemarks: trackingRemarks ?? this.trackingRemarks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'policyNumber': policyNumber,
      'insurerName': insurerName,
      'patientName': patientName,
      'serviceBooked': serviceBooked,
      'phone': phone,
      'documentFileNames': documentFileNames,
      'status': status,
      'submissionDate': submissionDate.toIso8601String(),
      'estimatedClaimAmount': estimatedClaimAmount,
      'trackingRemarks': trackingRemarks,
    };
  }

  factory InsuranceClaim.fromMap(Map<String, dynamic> map) {
    return InsuranceClaim(
      id: map['id'] ?? '',
      policyNumber: map['policyNumber'] ?? '',
      insurerName: map['insurerName'] ?? '',
      patientName: map['patientName'] ?? '',
      serviceBooked: map['serviceBooked'] ?? '',
      phone: map['phone'] ?? '',
      documentFileNames: (map['documentFileNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: map['status'] ?? 'Submitted',
      submissionDate: DateTime.parse(
          map['submissionDate'] ?? DateTime.now().toIso8601String()),
      estimatedClaimAmount:
          (map['estimatedClaimAmount'] as num?)?.toDouble() ?? 0.0,
      trackingRemarks:
          map['trackingRemarks'] ?? 'Documents received by Portea TPA Desk',
    );
  }

  String toJson() => json.encode(toMap());
  factory InsuranceClaim.fromJson(String source) =>
      InsuranceClaim.fromMap(json.decode(source));
}
