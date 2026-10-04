import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/equipment_model.dart';
import '../models/rental_order_model.dart';
import '../data/mock_data.dart';

class EquipmentProvider extends ChangeNotifier {
  List<Equipment> _equipmentList = [];
  List<RentalOrder> _rentalOrders = [];
  bool _isLoading = true;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Equipment> get allEquipment => _equipmentList;
  List<RentalOrder> get rentalOrders => _rentalOrders;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  EquipmentProvider() {
    _initEquipment();
  }

  Future<void> _initEquipment() async {
    _isLoading = true;
    notifyListeners();

    try {
      _equipmentList = List<Equipment>.from(MockData.equipmentList);
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(AppConstants.prefRentalsKey);

      if (ordersJson != null && ordersJson.isNotEmpty) {
        final decoded = json.decode(ordersJson) as List<dynamic>;
        _rentalOrders = decoded
            .map((o) => RentalOrder.fromMap(Map<String, dynamic>.from(o)))
            .toList();
      } else {
        // Initial sample rental order
        final sampleOrder = RentalOrder(
          id: 'EQ-RNT-5021',
          equipmentId: 'eq_002',
          equipmentName: 'Medical Oxygen Concentrator (5L/10L)',
          equipmentImage:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&q=80&w=500',
          monthlyRate: 3499.0,
          durationMonths: 1,
          deposit: 5000.0,
          totalCost: 8499.0,
          deliveryAddress:
              'Flat 402, Green Meadows, Sector 15, Kharghar, Navi Mumbai',
          orderDate: DateTime.now().subtract(const Duration(hours: 3)),
          currentStatus: 'Out for Delivery',
          deliveryAgentName: 'Ramesh Verma',
          deliveryAgentPhone: '+919820011223',
          etaString: 'Today by 4:30 PM',
          trackingHistory: [
            TrackingEvent(
              title: 'Order Placed & Sanitization Requested',
              description: 'Payment verified and equipment allocated from warehouse.',
              timestamp: DateTime.now().subtract(const Duration(hours: 3)),
              isCompleted: true,
            ),
            TrackingEvent(
              title: 'Sterilized & Packed in Secure Crate',
              description: 'Sanitized with medical grade agent and sealed.',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              isCompleted: true,
            ),
            TrackingEvent(
              title: 'Out for Delivery (Portea Medical Logistics)',
              description: 'Technician on route with demo manual and installation kit.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
              isCompleted: true,
            ),
            TrackingEvent(
              title: 'Delivered & Installed at Home',
              description: 'Patient/attendant training provided and checklist signed.',
              timestamp: DateTime.now().add(const Duration(hours: 1)),
              isCompleted: false,
            ),
          ],
        );
        _rentalOrders = [sampleOrder];
        await _saveRentalsToPrefs();
      }
    } catch (e) {
      debugPrint('Error init equipment: $e');
      _equipmentList = List<Equipment>.from(MockData.equipmentList);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Equipment> get filteredEquipment {
    return _equipmentList.where((eq) {
      if (_selectedCategory != 'All' && eq.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = eq.name.toLowerCase().contains(q);
        final matchesCat = eq.category.toLowerCase().contains(q);
        final matchesDesc = eq.description.toLowerCase().contains(q);
        if (!matchesName && !matchesCat && !matchesDesc) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Equipment? getEquipmentById(String id) {
    try {
      return _equipmentList.firstWhere((eq) => eq.id == id);
    } catch (_) {
      return null;
    }
  }

  RentalOrder? getRentalOrderById(String id) {
    try {
      return _rentalOrders.firstWhere((ro) => ro.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create and save a new rental order
  Future<RentalOrder> createRentalOrder({
    required Equipment equipment,
    required int durationMonths,
    required double totalCost,
    required String deliveryAddress,
  }) async {
    final now = DateTime.now();
    final newOrder = RentalOrder(
      id: 'EQ-RNT-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      equipmentId: equipment.id,
      equipmentName: equipment.name,
      equipmentImage: equipment.imageUrl,
      monthlyRate: equipment.monthlyRate,
      durationMonths: durationMonths,
      deposit: equipment.deposit,
      totalCost: totalCost,
      deliveryAddress: deliveryAddress,
      orderDate: now,
      currentStatus: 'Order Placed',
      deliveryAgentName: 'Ramesh Verma',
      deliveryAgentPhone: '+919820011223',
      etaString: 'Tomorrow by 2:00 PM',
      trackingHistory: [
        TrackingEvent(
          title: 'Order Placed & Sanitization Requested',
          description: 'Payment verified and equipment allocated from warehouse.',
          timestamp: now,
          isCompleted: true,
        ),
        TrackingEvent(
          title: 'Sterilized & Packed in Secure Crate',
          description: 'Sanitized with medical grade agent and sealed.',
          timestamp: now.add(const Duration(hours: 2)),
          isCompleted: false,
        ),
        TrackingEvent(
          title: 'Out for Delivery (Portea Medical Logistics)',
          description: 'Technician on route with demo manual and installation kit.',
          timestamp: now.add(const Duration(hours: 4)),
          isCompleted: false,
        ),
        TrackingEvent(
          title: 'Delivered & Installed at Home',
          description: 'Patient/attendant training provided and checklist signed.',
          timestamp: now.add(const Duration(hours: 6)),
          isCompleted: false,
        ),
      ],
    );

    _rentalOrders.insert(0, newOrder);
    notifyListeners();
    await _saveRentalsToPrefs();
    return newOrder;
  }

  /// Simulate next delivery stage for interactive demo
  Future<void> simulateNextDeliveryStage(String orderId) async {
    final index = _rentalOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = _rentalOrders[index];
    final stages = ['Order Placed', 'Packed', 'Out for Delivery', 'Delivered'];
    final currentIndex = stages.indexOf(order.currentStatus);

    if (currentIndex < stages.length - 1) {
      final nextStatus = stages[currentIndex + 1];
      final updatedHistory = List<TrackingEvent>.from(order.trackingHistory);

      for (int i = 0; i <= currentIndex + 1; i++) {
        if (i < updatedHistory.length) {
          updatedHistory[i] = TrackingEvent(
            title: updatedHistory[i].title,
            description: updatedHistory[i].description,
            timestamp: DateTime.now(),
            isCompleted: true,
          );
        }
      }

      String newEta = order.etaString;
      if (nextStatus == 'Delivered') {
        newEta = 'Delivered successfully';
      } else if (nextStatus == 'Out for Delivery') {
        newEta = 'Arriving in 30 mins';
      }

      _rentalOrders[index] = order.copyWith(
        currentStatus: nextStatus,
        etaString: newEta,
        trackingHistory: updatedHistory,
      );
      notifyListeners();
      await _saveRentalsToPrefs();
    }
  }

  Future<void> _saveRentalsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_rentalOrders.map((o) => o.toMap()).toList());
    await prefs.setString(AppConstants.prefRentalsKey, jsonString);
  }
}
