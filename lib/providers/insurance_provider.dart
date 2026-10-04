import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/insurance_claim_model.dart';
import '../data/mock_data.dart';

class InsuranceProvider extends ChangeNotifier {
  List<InsuranceClaim> _claims = [];
  Map<String, bool> _checklistStatus = {};
  bool _isLoading = true;

  List<InsuranceClaim> get claims => _claims;
  Map<String, bool> get checklistStatus => _checklistStatus;
  bool get isLoading => _isLoading;

  InsuranceProvider() {
    _initInsurance();
  }

  Future<void> _initInsurance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Claims
      final claimsJson = prefs.getString(AppConstants.prefClaimsKey);
      if (claimsJson != null && claimsJson.isNotEmpty) {
        final decoded = json.decode(claimsJson) as List<dynamic>;
        _claims = decoded
            .map((c) => InsuranceClaim.fromMap(Map<String, dynamic>.from(c)))
            .toList();
      } else {
        _claims = MockData.getInitialSampleClaims();
        await _saveClaimsToPrefs();
      }

      // Initialize Checklist
      for (final doc in MockData.requiredClaimDocuments) {
        final isChecked = prefs.getBool('claim_doc_$doc') ?? false;
        _checklistStatus[doc] = isChecked;
      }
    } catch (e) {
      debugPrint('Error init insurance: $e');
      _claims = MockData.getInitialSampleClaims();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleChecklistDoc(String doc, bool value) async {
    _checklistStatus[doc] = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('claim_doc_$doc', value);
  }

  Future<InsuranceClaim> submitClaim({
    required String policyNumber,
    required String insurerName,
    required String patientName,
    required String serviceBooked,
    required String phone,
    required List<String> documentFileNames,
    required double estimatedAmount,
  }) async {
    final newClaim = InsuranceClaim(
      id: 'CLM-IN-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      policyNumber: policyNumber,
      insurerName: insurerName,
      patientName: patientName,
      serviceBooked: serviceBooked,
      phone: phone,
      documentFileNames: documentFileNames,
      status: 'Submitted',
      submissionDate: DateTime.now(),
      estimatedClaimAmount: estimatedAmount,
      trackingRemarks:
          'Application received. Assigned to Portea Medical TPA Desk for policy verification.',
    );

    _claims.insert(0, newClaim);
    notifyListeners();
    await _saveClaimsToPrefs();
    return newClaim;
  }

  Future<void> advanceClaimStatus(String claimId) async {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) return;

    final claim = _claims[index];
    String nextStatus = claim.status;
    String remarks = claim.trackingRemarks;

    if (claim.status == 'Submitted') {
      nextStatus = 'In Review';
      remarks = 'TPA query resolved. Claim dossier sent to insurance surveyor.';
    } else if (claim.status == 'In Review') {
      nextStatus = 'Approved';
      remarks = 'Pre-approval granted. Reimbursement will be credited in 3 business days.';
    }

    _claims[index] = claim.copyWith(
      status: nextStatus,
      trackingRemarks: remarks,
    );
    notifyListeners();
    await _saveClaimsToPrefs();
  }

  Future<void> _saveClaimsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_claims.map((c) => c.toMap()).toList());
    await prefs.setString(AppConstants.prefClaimsKey, jsonString);
  }
}
