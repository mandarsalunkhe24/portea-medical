import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/professional_model.dart';
import '../models/review_model.dart';
import '../data/mock_data.dart';

class ProfessionalsProvider extends ChangeNotifier {
  List<Professional> _professionals = [];
  List<Review> _reviews = [];
  bool _isLoading = true;

  // Filter state
  String _selectedRole = 'All';
  String _selectedLanguage = 'All';
  double _minRating = 0.0;
  int _minExperience = 0;
  String _sortBy = 'rating'; // 'rating', 'experience', 'price_asc', 'price_desc'
  String _searchQuery = '';

  List<Professional> get allProfessionals => _professionals;
  List<Review> get allReviews => _reviews;
  bool get isLoading => _isLoading;

  String get selectedRole => _selectedRole;
  String get selectedLanguage => _selectedLanguage;
  double get minRating => _minRating;
  int get minExperience => _minExperience;
  String get sortBy => _sortBy;
  String get searchQuery => _searchQuery;

  ProfessionalsProvider() {
    _initProfessionalsAndReviews();
  }

  Future<void> _initProfessionalsAndReviews() async {
    _isLoading = true;
    notifyListeners();

    try {
      _professionals = List<Professional>.from(MockData.professionals);
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = prefs.getString(AppConstants.prefReviewsKey);

      if (reviewsJson != null && reviewsJson.isNotEmpty) {
        final decoded = json.decode(reviewsJson) as List<dynamic>;
        _reviews = decoded.map((r) => Review.fromMap(Map<String, dynamic>.from(r))).toList();
      } else {
        _reviews = List<Review>.from(MockData.reviews);
        await _saveReviewsToPrefs();
      }

      // Recalculate ratings
      _recalculateAllRatings();
    } catch (e) {
      debugPrint('Error init professionals: $e');
      _professionals = List<Professional>.from(MockData.professionals);
      _reviews = List<Review>.from(MockData.reviews);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setMinRating(double rating) {
    _minRating = rating;
    notifyListeners();
  }

  void setMinExperience(int years) {
    _minExperience = years;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _selectedRole = 'All';
    _selectedLanguage = 'All';
    _minRating = 0.0;
    _minExperience = 0;
    _sortBy = 'rating';
    _searchQuery = '';
    notifyListeners();
  }

  List<Professional> get filteredProfessionals {
    return _professionals.where((p) {
      // Role filter
      if (_selectedRole != 'All' && !p.role.toLowerCase().contains(_selectedRole.toLowerCase())) {
        return false;
      }
      // Language filter
      if (_selectedLanguage != 'All' && !p.languages.contains(_selectedLanguage)) {
        return false;
      }
      // Rating filter
      if (p.rating < _minRating) {
        return false;
      }
      // Experience filter
      if (p.experienceYears < _minExperience) {
        return false;
      }
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesSpecialization = p.specializations.any((s) => s.toLowerCase().contains(query));
        final matchesRole = p.role.toLowerCase().contains(query);
        final matchesTitle = p.title.toLowerCase().contains(query);
        if (!matchesName && !matchesSpecialization && !matchesRole && !matchesTitle) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'rating') {
          return b.rating.compareTo(a.rating);
        } else if (_sortBy == 'experience') {
          return b.experienceYears.compareTo(a.experienceYears);
        } else if (_sortBy == 'price_asc') {
          return a.pricePerVisit.compareTo(b.pricePerVisit);
        } else if (_sortBy == 'price_desc') {
          return b.pricePerVisit.compareTo(a.pricePerVisit);
        }
        return 0;
      });
  }

  Professional? getProfessionalById(String id) {
    try {
      return _professionals.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Review> getReviewsForProfessional(String professionalId) {
    return _reviews.where((r) => r.professionalId == professionalId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addReview(Review review) async {
    _reviews.insert(0, review);
    _recalculateRatingFor(review.professionalId);
    notifyListeners();
    await _saveReviewsToPrefs();
  }

  void _recalculateRatingFor(String profId) {
    final profReviews = _reviews.where((r) => r.professionalId == profId).toList();
    if (profReviews.isEmpty) return;

    final index = _professionals.indexWhere((p) => p.id == profId);
    if (index == -1) return;

    final prof = _professionals[index];
    final totalStars = profReviews.fold<double>(0, (sum, r) => sum + r.rating);
    final avgRating = (totalStars / profReviews.length);

    final Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in profReviews) {
      final rounded = r.rating.round().clamp(1, 5);
      distribution[rounded] = (distribution[rounded] ?? 0) + 1;
    }

    _professionals[index] = prof.copyWith(
      rating: double.parse(avgRating.toStringAsFixed(2)),
      reviewCount: profReviews.length,
      ratingDistribution: distribution,
    );
  }

  void _recalculateAllRatings() {
    for (final p in _professionals) {
      _recalculateRatingFor(p.id);
    }
  }

  Future<void> _saveReviewsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_reviews.map((r) => r.toMap()).toList());
    await prefs.setString(AppConstants.prefReviewsKey, jsonString);
  }
}
