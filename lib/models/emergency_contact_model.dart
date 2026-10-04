import 'dart:convert';

class EmergencyContact {
  final String id;
  final String name;
  final String relation;
  final String phone;
  final bool isPrimary;
  final bool isDefaultService;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    this.isPrimary = false,
    this.isDefaultService = false,
  });

  EmergencyContact copyWith({
    String? name,
    String? relation,
    String? phone,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
      isDefaultService: isDefaultService,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'phone': phone,
      'isPrimary': isPrimary,
      'isDefaultService': isDefaultService,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      phone: map['phone'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
      isDefaultService: map['isDefaultService'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory EmergencyContact.fromJson(String source) =>
      EmergencyContact.fromMap(json.decode(source));
}
