import 'package:cloud_firestore/cloud_firestore.dart';

class CaregiverModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final List<String> linkedElderIds;

  CaregiverModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.linkedElderIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'linkedElderIds': linkedElderIds,
    };
  }

  factory CaregiverModel.fromMap(Map<String, dynamic> map, String id) {
    return CaregiverModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      linkedElderIds: List<String>.from(map['linkedElderIds'] ?? []),
    );
  }
}
