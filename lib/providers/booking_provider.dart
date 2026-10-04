import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/booking_model.dart';
import '../data/mock_data.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = true;

  List<Booking> get allBookings => _bookings;
  bool get isLoading => _isLoading;

  List<Booking> get upcomingBookings => _bookings
      .where((b) => b.status != 'Completed' && b.status != 'Cancelled')
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<Booking> get completedBookings => _bookings
      .where((b) => b.status == 'Completed')
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<Booking> get cancelledBookings => _bookings
      .where((b) => b.status == 'Cancelled')
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  int get totalBookingsCount => _bookings.length;
  int get completedVisitsCount => completedBookings.length;

  Booking? get nextUpcomingAppointment {
    final list = upcomingBookings;
    return list.isNotEmpty ? list.first : null;
  }

  BookingProvider() {
    _initBookings();
  }

  Future<void> _initBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString(AppConstants.prefBookingsKey);

      if (bookingsJson != null && bookingsJson.isNotEmpty) {
        final decoded = json.decode(bookingsJson) as List<dynamic>;
        _bookings = decoded
            .map((b) => Booking.fromMap(Map<String, dynamic>.from(b)))
            .toList();
      } else {
        _bookings = MockData.getInitialSampleBookings();
        await _saveBookingsToPrefs();
      }
    } catch (e) {
      debugPrint('Error init bookings: $e');
      _bookings = MockData.getInitialSampleBookings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if a slot is already booked for the given professional on that day
  bool isSlotAlreadyBooked({
    required String professionalId,
    required DateTime date,
    required String timeSlot,
    String? excludeBookingId,
  }) {
    return _bookings.any((b) {
      if (b.id == excludeBookingId) return false;
      if (b.status == 'Cancelled') return false;
      return b.professionalId == professionalId &&
          b.date.year == date.year &&
          b.date.month == date.month &&
          b.date.day == date.day &&
          b.timeSlot == timeSlot;
    });
  }

  /// Adds a new booking with double-booking prevention check
  Future<Map<String, dynamic>> createBooking(Booking booking) async {
    if (isSlotAlreadyBooked(
      professionalId: booking.professionalId,
      date: booking.date,
      timeSlot: booking.timeSlot,
    )) {
      return {
        'success': false,
        'message':
            'This slot is already booked for ${booking.professionalName}. Please select another time slot or date.',
      };
    }

    _bookings.insert(0, booking);
    notifyListeners();
    await _saveBookingsToPrefs();

    return {
      'success': true,
      'bookingId': booking.id,
      'message': 'Booking confirmed successfully!',
    };
  }

  /// Reschedule an existing booking
  Future<Map<String, dynamic>> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    required String newTimeSlot,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      return {'success': false, 'message': 'Booking not found.'};
    }

    final booking = _bookings[index];
    if (isSlotAlreadyBooked(
      professionalId: booking.professionalId,
      date: newDate,
      timeSlot: newTimeSlot,
      excludeBookingId: bookingId,
    )) {
      return {
        'success': false,
        'message': 'The selected new slot is unavailable. Please choose another.',
      };
    }

    _bookings[index] = booking.copyWith(
      date: newDate,
      timeSlot: newTimeSlot,
      status: 'Professional Assigned',
    );
    notifyListeners();
    await _saveBookingsToPrefs();

    return {'success': true, 'message': 'Booking rescheduled successfully.'};
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: 'Cancelled');
      notifyListeners();
      await _saveBookingsToPrefs();
      return true;
    }
    return false;
  }

  /// Update booking status (e.g. for timeline progression: Booked -> Professional Assigned -> On the way -> In Progress -> Completed)
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: newStatus);
      notifyListeners();
      await _saveBookingsToPrefs();
    }
  }

  /// Complete service with evidence
  Future<bool> completeBookingWithEvidence({
    required String bookingId,
    required ServiceCompletionEvidence evidence,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: 'Completed',
        evidence: evidence,
      );
      notifyListeners();
      await _saveBookingsToPrefs();
      return true;
    }
    return false;
  }

  /// Mark review submitted for a booking
  Future<void> markBookingReviewed(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(hasReview: true);
      notifyListeners();
      await _saveBookingsToPrefs();
    }
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveBookingsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_bookings.map((b) => b.toMap()).toList());
    await prefs.setString(AppConstants.prefBookingsKey, jsonString);
  }
}
