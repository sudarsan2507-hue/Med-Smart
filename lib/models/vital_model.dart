import 'package:cloud_firestore/cloud_firestore.dart';

class VitalModel {
  final String id;
  final int heartRate;
  final String bloodPressure;
  final double oxygenLevel;
  final DateTime timestamp;
  final String elderId;

  VitalModel({
    required this.id,
    required this.heartRate,
    required this.bloodPressure,
    required this.oxygenLevel,
    required this.timestamp,
    required this.elderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'oxygenLevel': oxygenLevel,
      'timestamp': Timestamp.fromDate(timestamp),
      'elderId': elderId,
    };
  }

  factory VitalModel.fromMap(Map<String, dynamic> map, String docId) {
    return VitalModel(
      id: docId,
      heartRate: map['heartRate'] ?? 0,
      bloodPressure: map['bloodPressure'] ?? '',
      oxygenLevel: (map['oxygenLevel'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      elderId: map['elderId'] ?? '',
    );
  }
}
