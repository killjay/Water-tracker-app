import 'package:cloud_firestore/cloud_firestore.dart';

class WaterEntryModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final double amount; // in ml
  final String? cupSize; // Name of the cup size used
  final String dayKey; // Format: "YYYY-MM-DD" for efficient querying

  WaterEntryModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.amount,
    this.cupSize,
    required this.dayKey,
  });

  factory WaterEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return WaterEntryModel(
      id: id,
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      cupSize: map['cupSize'],
      dayKey: map['dayKey'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'amount': amount,
      'cupSize': cupSize,
      'dayKey': dayKey,
    };
  }

  WaterEntryModel copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    double? amount,
    String? cupSize,
    String? dayKey,
  }) {
    return WaterEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      cupSize: cupSize ?? this.cupSize,
      dayKey: dayKey ?? this.dayKey,
    );
  }
}
