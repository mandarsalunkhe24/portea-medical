import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../data/mock_data.dart';

/// Authentication provider.
///
/// * If Firebase is configured (see FIREBASE_SETUP.md) it uses real Firebase
///   Email/Password authentication.
/// * If Firebase is NOT configured, it automatically falls back to the original
///   demo (mock) login so the app always runs.
///
/// Profile data (patients, addresses) is stored locally, one profile per
/// Firebase user id.
class AuthProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = true;
  bool _isOnboardingCompleted = false;
  String? _lastError;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  /// Human readable message for the last failed login/register/reset.
  String? get lastError => _lastError;

  /// True when Firebase was initialised successfully in main().
  bool get firebaseEnabled {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _fb => FirebaseAuth.instance;

  String get _prefsKey {
    if (firebaseEnabled && _fb.currentUser != null) {
      return '${AppConstants.prefUserKey}_${_fb.currentUser!.uid}';
    }
    return AppConstants.prefUserKey;
  }

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted =
          prefs.getBool(AppConstants.prefOnboardingCompleted) ?? false;

      if (firebaseEnabled) {
        // Firebase restores the previous session asynchronously (especially on web).
        final User? fbUser = await _fb
            .authStateChanges()
            .first
            .timeout(const Duration(seconds: 5), onTimeout: () => _fb.currentUser);
        if (fbUser != null) {
          _currentUser = await _loadFirebaseProfile(fbUser);
        } else {
          _currentUser = null; // show the login screen
        }
      } else {
        // Demo mode (Firebase not configured)
        final userJson = prefs.getString(AppConstants.prefUserKey);
        if (userJson != null && userJson.isNotEmpty) {
          _currentUser = UserProfile.fromJson(userJson);
        } else {
          _currentUser = MockData.defaultUser;
          await _saveUserToPrefs(_currentUser!);
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      _currentUser = firebaseEnabled ? null : MockData.defaultUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingCompleted, true);
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------
  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _lastError = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (firebaseEnabled) {
        final email = emailOrPhone.trim();
        if (!email.contains('@')) {
          _lastError = 'Please sign in with your email address.';
          return false;
        }
        final cred = await _fb.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _currentUser = await _loadFirebaseProfile(cred.user!);
        return true;
      }

      // ---- Demo mode ----
      await Future.delayed(const Duration(milliseconds: 600));
      _currentUser = MockData.defaultUser.copyWith(
        email: emailOrPhone.contains('@')
            ? emailOrPhone
            : MockData.defaultUser.email,
        phone: !emailOrPhone.contains('@')
            ? emailOrPhone
            : MockData.defaultUser.phone,
      );
      await _saveUserToPrefs(_currentUser!);
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = _friendlyError(e.code);
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _lastError = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------
  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    _lastError = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (firebaseEnabled) {
        final cred = await _fb.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = cred.user!;
        await user.updateDisplayName(name);
        _currentUser = _buildProfile(
          id: user.uid,
          name: name,
          email: user.email ?? email.trim(),
          phone: phone,
        );
        await _saveUserToPrefs(_currentUser!);
        return true;
      }

      // ---- Demo mode ----
      await Future.delayed(const Duration(milliseconds: 600));
      _currentUser = _buildProfile(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: phone,
      );
      await _saveUserToPrefs(_currentUser!);
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = _friendlyError(e.code);
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      _lastError = 'Could not create the account. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // PASSWORD RESET (Firebase only)
  // ---------------------------------------------------------------------------
  Future<bool> sendPasswordReset(String email) async {
    _lastError = null;
    if (!firebaseEnabled) {
      _lastError = 'Password reset needs Firebase to be configured.';
      return false;
    }
    try {
      await _fb.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _lastError = _friendlyError(e.code);
      return false;
    } catch (_) {
      _lastError = 'Could not send the reset email. Please try again.';
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE EDITS (unchanged behaviour)
  // ---------------------------------------------------------------------------
  Future<void> addPatient(Patient patient) async {
    if (_currentUser == null) return;
    final updatedList = List<Patient>.from(_currentUser!.patients)..add(patient);
    _currentUser = _currentUser!.copyWith(patients: updatedList);
    notifyListeners();
    await _saveUserToPrefs(_currentUser!);
  }

  Future<void> updatePatient(Patient updatedPatient) async {
    if (_currentUser == null) return;
    final index =
        _currentUser!.patients.indexWhere((p) => p.id == updatedPatient.id);
    if (index != -1) {
      final updatedList = List<Patient>.from(_currentUser!.patients);
      updatedList[index] = updatedPatient;
      _currentUser = _currentUser!.copyWith(patients: updatedList);
      notifyListeners();
      await _saveUserToPrefs(_currentUser!);
    }
  }

  Future<void> addAddress(String address) async {
    if (_currentUser == null) return;
    final updated = List<String>.from(_currentUser!.savedAddresses)
      ..add(address);
    _currentUser = _currentUser!.copyWith(savedAddresses: updated);
    notifyListeners();
    await _saveUserToPrefs(_currentUser!);
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    if (firebaseEnabled) {
      // Keep the saved profile for this user so data is there on next login.
      try {
        await _fb.signOut();
      } catch (e) {
        debugPrint('Sign out error: $e');
      }
      _currentUser = null;
      notifyListeners();
      return;
    }
    _currentUser = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefUserKey);
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  UserProfile _buildProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
  }) {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      defaultAddress: 'Kharghar, Navi Mumbai',
      patients: [
        Patient(
          id: 'pat_self',
          name: name,
          age: 24,
          gender: 'Other',
          relationship: 'Self',
          healthNotes: 'General wellness check',
          address: 'Kharghar, Navi Mumbai',
        ),
      ],
      savedAddresses: ['Kharghar, Navi Mumbai'],
    );
  }

  Future<UserProfile> _loadFirebaseProfile(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${AppConstants.prefUserKey}_${user.uid}';
    final saved = prefs.getString(key);
    if (saved != null && saved.isNotEmpty) {
      try {
        return UserProfile.fromJson(saved);
      } catch (_) {
        // fall through and rebuild
      }
    }
    final email = user.email ?? '';
    final name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (email.contains('@') ? email.split('@').first : 'Portea User');
    final profile = _buildProfile(
      id: user.uid,
      name: name,
      email: email,
      phone: user.phoneNumber ?? '',
    );
    await prefs.setString(key, profile.toJson());
    return profile;
  }

  Future<void> _saveUserToPrefs(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, user.toJson());
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in the Firebase console.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a bit and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Authentication failed ($code).';
    }
  }
}
