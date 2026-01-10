import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String instructions; // e.g., "Take with food"
  final DateTime startDate;
  final DateTime endDate;
  final List<String> frequency; // e.g., ["08:00", "20:00"]
  final String elderId;
  final String? prescribedBy; // Doctor's name or ID

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    required this.elderId,
    this.prescribedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'frequency': frequency,
      'elderId': elderId,
      'prescribedBy': prescribedBy,
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map, String docId) {
    return MedicationModel(
      id: docId,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      instructions: map['instructions'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      frequency: List<String>.from(map['frequency'] ?? []),
      elderId: map['elderId'] ?? '',
      prescribedBy: map['prescribedBy'],
    );
  }
}
