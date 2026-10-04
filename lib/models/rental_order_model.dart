import 'dart:convert';

class TrackingEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  TrackingEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory TrackingEvent.fromMap(Map<String, dynamic> map) {
    return TrackingEvent(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: DateTime.parse(
          map['timestamp'] ?? DateTime.now().toIso8601String()),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class RentalOrder {
  final String id;
  final String equipmentId;
  final String equipmentName;
  final String equipmentImage;
  final double monthlyRate;
  final int durationMonths;
  final double deposit;
  final double totalCost;
  final String deliveryAddress;
  final DateTime orderDate;
  final String currentStatus; // 'Order Placed', 'Packed', 'Out for Delivery', 'Delivered'
  final String deliveryAgentName;
  final String deliveryAgentPhone;
  final String etaString;
  final List<TrackingEvent> trackingHistory;

  RentalOrder({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.equipmentImage,
    required this.monthlyRate,
    required this.durationMonths,
    required this.deposit,
    required this.totalCost,
    required this.deliveryAddress,
    required this.orderDate,
    this.currentStatus = 'Order Placed',
    this.deliveryAgentName = 'Ramesh Verma',
    this.deliveryAgentPhone = '+919820011223',
    this.etaString = 'Today by 4:00 PM',
    required this.trackingHistory,
  });

  RentalOrder copyWith({
    String? currentStatus,
    String? etaString,
    List<TrackingEvent>? trackingHistory,
  }) {
    return RentalOrder(
      id: id,
      equipmentId: equipmentId,
      equipmentName: equipmentName,
      equipmentImage: equipmentImage,
      monthlyRate: monthlyRate,
      durationMonths: durationMonths,
      deposit: deposit,
      totalCost: totalCost,
      deliveryAddress: deliveryAddress,
      orderDate: orderDate,
      currentStatus: currentStatus ?? this.currentStatus,
      deliveryAgentName: deliveryAgentName,
      deliveryAgentPhone: deliveryAgentPhone,
      etaString: etaString ?? this.etaString,
      trackingHistory: trackingHistory ?? this.trackingHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'equipmentImage': equipmentImage,
      'monthlyRate': monthlyRate,
      'durationMonths': durationMonths,
      'deposit': deposit,
      'totalCost': totalCost,
      'deliveryAddress': deliveryAddress,
      'orderDate': orderDate.toIso8601String(),
      'currentStatus': currentStatus,
      'deliveryAgentName': deliveryAgentName,
      'deliveryAgentPhone': deliveryAgentPhone,
      'etaString': etaString,
      'trackingHistory': trackingHistory.map((e) => e.toMap()).toList(),
    };
  }

  factory RentalOrder.fromMap(Map<String, dynamic> map) {
    return RentalOrder(
      id: map['id'] ?? '',
      equipmentId: map['equipmentId'] ?? '',
      equipmentName: map['equipmentName'] ?? '',
      equipmentImage: map['equipmentImage'] ?? '',
      monthlyRate: (map['monthlyRate'] as num?)?.toDouble() ?? 0.0,
      durationMonths: map['durationMonths'] ?? 1,
      deposit: (map['deposit'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: map['deliveryAddress'] ?? '',
      orderDate: DateTime.parse(
          map['orderDate'] ?? DateTime.now().toIso8601String()),
      currentStatus: map['currentStatus'] ?? 'Order Placed',
      deliveryAgentName: map['deliveryAgentName'] ?? 'Ramesh Verma',
      deliveryAgentPhone: map['deliveryAgentPhone'] ?? '+919820011223',
      etaString: map['etaString'] ?? 'Today by 4:00 PM',
      trackingHistory: (map['trackingHistory'] as List<dynamic>?)
              ?.map((e) => TrackingEvent.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());
  factory RentalOrder.fromJson(String source) =>
      RentalOrder.fromMap(json.decode(source));
}
