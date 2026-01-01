import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String type; // 'sos', 'fall', 'boundary', 'inactive'
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String message;
  final DateTime timestamp;
  final bool isResolved;
  final String elderId;
  final Map<String, double>? location; // {'lat': 0.0, 'lng': 0.0}

  AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.isResolved,
    required this.elderId,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isResolved': isResolved,
      'elderId': elderId,
      'location': location,
    };
  }

  factory AlertModel.fromMap(Map<String, dynamic> map, String docId) {
    return AlertModel(
      id: docId,
      type: map['type'] ?? '',
      severity: map['severity'] ?? 'medium',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isResolved: map['isResolved'] ?? false,
      elderId: map['elderId'] ?? '',
      location: map['location'] != null
          ? Map<String, double>.from(map['location'])
          : null,
    );
  }
}
