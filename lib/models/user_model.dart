import 'dart:convert';

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String relationship; // e.g. "Self", "Mother", "Father", "Spouse"
  final String healthNotes;
  final String address;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.relationship,
    this.healthNotes = '',
    this.address = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'relationship': relationship,
      'healthNotes': healthNotes,
      'address': address,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Male',
      relationship: map['relationship'] ?? 'Self',
      healthNotes: map['healthNotes'] ?? '',
      address: map['address'] ?? '',
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String defaultAddress;
  final List<Patient> patients;
  final List<String> savedAddresses;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.defaultAddress,
    this.patients = const [],
    this.savedAddresses = const [],
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? defaultAddress,
    List<Patient>? patients,
    List<String>? savedAddresses,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      patients: patients ?? this.patients,
      savedAddresses: savedAddresses ?? this.savedAddresses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'defaultAddress': defaultAddress,
      'patients': patients.map((p) => p.toMap()).toList(),
      'savedAddresses': savedAddresses,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      defaultAddress: map['defaultAddress'] ?? '',
      patients: (map['patients'] as List<dynamic>?)
              ?.map((p) => Patient.fromMap(Map<String, dynamic>.from(p)))
              .toList() ??
          [],
      savedAddresses: (map['savedAddresses'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
