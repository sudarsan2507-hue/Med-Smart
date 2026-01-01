import 'package:cloud_firestore/cloud_firestore.dart';

class ElderModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String bloodType;
  final List<String> medicalConditions;
  final List<String> caregiverIds; // User IDs of caregivers

  ElderModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.bloodType,
    required this.medicalConditions,
    required this.caregiverIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'bloodType': bloodType,
      'medicalConditions': medicalConditions,
      'caregiverIds': caregiverIds,
    };
  }

  factory ElderModel.fromMap(Map<String, dynamic> map, String id) {
    return ElderModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      age: map['age'] ?? 0,
      bloodType: map['bloodType'] ?? '',
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      caregiverIds: List<String>.from(map['caregiverIds'] ?? []),
    );
  }
}
