import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledTime;
  final String status; // 'pending', 'taken', 'missed', 'skipped'
  final DateTime? takenAt;
  final String elderId;

  ReminderModel({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledTime,
    required this.status,
    this.takenAt,
    required this.elderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'status': status,
      'takenAt': takenAt != null ? Timestamp.fromDate(takenAt!) : null,
      'elderId': elderId,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReminderModel(
      id: docId,
      medicationId: map['medicationId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      takenAt: map['takenAt'] != null ? (map['takenAt'] as Timestamp).toDate() : null,
      elderId: map['elderId'] ?? '',
    );
  }
}
