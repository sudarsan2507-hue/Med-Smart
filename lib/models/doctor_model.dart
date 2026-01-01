import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final List<String> patientIds;

  DoctorModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.specialization,
    required this.patientIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'specialization': specialization,
      'patientIds': patientIds,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      specialization: map['specialization'] ?? 'General Practitioner',
      patientIds: List<String>.from(map['patientIds'] ?? []),
    );
  }
}
