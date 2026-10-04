import 'dart:convert';

class SosEvent {
  final String id;
  final DateTime timestamp;
  final String locationAddress;
  final String coordinates;
  final String triggeredContactName;
  final String triggeredContactPhone;
  final String status;

  SosEvent({
    required this.id,
    required this.timestamp,
    required this.locationAddress,
    required this.coordinates,
    required this.triggeredContactName,
    required this.triggeredContactPhone,
    this.status = 'Dispatched Alert & Call Initiated',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'locationAddress': locationAddress,
      'coordinates': coordinates,
      'triggeredContactName': triggeredContactName,
      'triggeredContactPhone': triggeredContactPhone,
      'status': status,
    };
  }

  factory SosEvent.fromMap(Map<String, dynamic> map) {
    return SosEvent(
      id: map['id'] ?? '',
      timestamp: DateTime.parse(
          map['timestamp'] ?? DateTime.now().toIso8601String()),
      locationAddress: map['locationAddress'] ?? '',
      coordinates: map['coordinates'] ?? '',
      triggeredContactName: map['triggeredContactName'] ?? '',
      triggeredContactPhone: map['triggeredContactPhone'] ?? '',
      status: map['status'] ?? 'Dispatched Alert & Call Initiated',
    );
  }

  String toJson() => json.encode(toMap());
  factory SosEvent.fromJson(String source) =>
      SosEvent.fromMap(json.decode(source));
}
