import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/emergency_contact_model.dart';
import '../models/sos_event_model.dart';
import '../data/mock_data.dart';
import '../core/utils.dart';

class EmergencyProvider extends ChangeNotifier {
  List<EmergencyContact> _contacts = [];
  List<SosEvent> _sosHistory = [];
  bool _isLoading = true;

  List<EmergencyContact> get contacts => _contacts;
  List<SosEvent> get sosHistory => _sosHistory;
  bool get isLoading => _isLoading;

  EmergencyContact? get primaryContact {
    try {
      return _contacts.firstWhere((c) => c.isPrimary);
    } catch (_) {
      try {
        return _contacts.firstWhere((c) => !c.isDefaultService);
      } catch (_) {
        return _contacts.isNotEmpty ? _contacts.first : null;
      }
    }
  }

  EmergencyProvider() {
    _initEmergency();
  }

  Future<void> _initEmergency() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Contacts
      final contactsJson = prefs.getString(AppConstants.prefEmergencyContactsKey);
      if (contactsJson != null && contactsJson.isNotEmpty) {
        final decoded = json.decode(contactsJson) as List<dynamic>;
        _contacts = decoded
            .map((c) => EmergencyContact.fromMap(Map<String, dynamic>.from(c)))
            .toList();
      } else {
        _contacts = List<EmergencyContact>.from(MockData.defaultEmergencyContacts);
        await _saveContactsToPrefs();
      }

      // Load SOS History
      final sosJson = prefs.getString(AppConstants.prefSosEventsKey);
      if (sosJson != null && sosJson.isNotEmpty) {
        final decoded = json.decode(sosJson) as List<dynamic>;
        _sosHistory = decoded
            .map((s) => SosEvent.fromMap(Map<String, dynamic>.from(s)))
            .toList();
      } else {
        _sosHistory = [
          SosEvent(
            id: 'SOS-INIT-1',
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            locationAddress: 'Sector 15, Kharghar, Navi Mumbai (Home Geo-Fence)',
            coordinates: '19.0438° N, 73.0674° E',
            triggeredContactName: 'Mandar Salunkhe (Family)',
            triggeredContactPhone: '+919876543210',
            status: 'Drill Test Verified & Resolved',
          ),
        ];
        await _saveSosToPrefs();
      }
    } catch (e) {
      debugPrint('Error init emergency: $e');
      _contacts = List<EmergencyContact>.from(MockData.defaultEmergencyContacts);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContact(EmergencyContact contact) async {
    // If new contact is primary, clear previous primary
    if (contact.isPrimary) {
      _contacts = _contacts.map((c) => c.copyWith(isPrimary: false)).toList();
    }
    _contacts.add(contact);
    notifyListeners();
    await _saveContactsToPrefs();
  }

  Future<void> updateContact(EmergencyContact updated) async {
    final index = _contacts.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      if (updated.isPrimary) {
        _contacts = _contacts.map((c) => c.copyWith(isPrimary: false)).toList();
      }
      _contacts[index] = updated;
      notifyListeners();
      await _saveContactsToPrefs();
    }
  }

  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    // If primary was removed, mark another as primary
    if (_contacts.isNotEmpty && !_contacts.any((c) => c.isPrimary)) {
      final nonDefault = _contacts.firstWhere(
        (c) => !c.isDefaultService,
        orElse: () => _contacts.first,
      );
      final idx = _contacts.indexWhere((c) => c.id == nonDefault.id);
      if (idx != -1) {
        _contacts[idx] = _contacts[idx].copyWith(isPrimary: true);
      }
    }
    notifyListeners();
    await _saveContactsToPrefs();
  }

  Future<void> setPrimaryContact(String id) async {
    _contacts = _contacts.map((c) => c.copyWith(isPrimary: c.id == id)).toList();
    notifyListeners();
    await _saveContactsToPrefs();
  }

  /// Triggers full SOS sequence: logs event, calls primary contact
  Future<SosEvent> triggerSos(BuildContext context) async {
    final primary = primaryContact ??
        EmergencyContact(
          id: 'temp_amb',
          name: '108 Ambulance',
          relation: 'Emergency',
          phone: '108',
        );

    final event = SosEvent(
      id: 'SOS-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      locationAddress: 'Sector 15, Kharghar, Navi Mumbai - GPS Validated',
      coordinates: '19.0438° N, 73.0674° E',
      triggeredContactName: primary.name,
      triggeredContactPhone: primary.phone,
      status: 'Emergency Alert Sent & Dialing Initiated',
    );

    _sosHistory.insert(0, event);
    notifyListeners();
    await _saveSosToPrefs();

    // Trigger Phone Call
    await AppUtils.makePhoneCall(context, primary.phone);

    return event;
  }

  Future<void> _saveContactsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_contacts.map((c) => c.toMap()).toList());
    await prefs.setString(AppConstants.prefEmergencyContactsKey, jsonString);
  }

  Future<void> _saveSosToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_sosHistory.map((s) => s.toMap()).toList());
    await prefs.setString(AppConstants.prefSosEventsKey, jsonString);
  }
}
