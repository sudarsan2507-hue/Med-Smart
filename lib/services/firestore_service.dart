import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';
import '../models/vital_model.dart';
import '../models/alert_model.dart';
import '../models/elder_model.dart';
import '../models/caregiver_model.dart';
import '../models/doctor_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Collection Refs ---
  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _eldersRef => _db.collection('elders');
  CollectionReference get _medsRef => _db.collection('medications');
  CollectionReference get _vitalsRef => _db.collection('vitals');
  CollectionReference get _alertsRef => _db.collection('alerts');

  // --- Elder Management ---

  Future<void> createElderProfile(ElderModel elder) async {
    await _eldersRef.doc(elder.uid).set(elder.toMap());
    // Also update the main user doc to role=elder if not set
    await _usersRef.doc(elder.uid).update({'role': 'elder'});
  }

  Stream<ElderModel> getElderStream(String elderId) {
    return _eldersRef.doc(elderId).snapshots().map((doc) {
      if (!doc.exists) throw Exception("Elder profile not found");
      return ElderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Future<ElderModel?> findElderByEmail(String email) async {
    final query = await _eldersRef.where('email', isEqualTo: email.trim()).limit(1).get();
    if (query.docs.isEmpty) return null;
    return ElderModel.fromMap(query.docs.first.data() as Map<String, dynamic>, query.docs.first.id);
  }

  // --- Caregiver Management ---

  Future<void> createCaregiverProfile(String uid, String name, String email) async {
    await _db.collection('caregivers').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'linkedElderIds': [],
    });
    // Update main user doc
    await _usersRef.doc(uid).update({'role': 'caregiver'});
  }

  Stream<CaregiverModel> getCaregiverStream(String caregiverId) {
    return _db.collection('caregivers').doc(caregiverId).snapshots().map((doc) {
      if (!doc.exists) throw Exception("Caregiver profile not found");
      return CaregiverModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Stream<List<ElderModel>> getCaregiversElders(List<String> elderIds) {
    if (elderIds.isEmpty) return Stream.value([]);
    return _eldersRef
        .where(FieldPath.documentId, whereIn: elderIds)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ElderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> linkCaregiverToElder({required String elderId, required String caregiverId}) async {
    final batch = _db.batch();
    
    // Add caregiver ID to Elder's list
    batch.set(_eldersRef.doc(elderId), {
      'caregiverIds': FieldValue.arrayUnion([caregiverId])
    }, SetOptions(merge: true));

    // Add elder ID to Caregiver's list
    batch.set(_db.collection('caregivers').doc(caregiverId), {
      'linkedElderIds': FieldValue.arrayUnion([elderId])
    }, SetOptions(merge: true));

    await batch.commit();
  }

  // --- Doctor Management ---

  Stream<DoctorModel> getDoctorStream(String doctorId) {
    return _db.collection('doctors').doc(doctorId).snapshots().map((doc) {
      if (!doc.exists) throw Exception("Doctor profile not found");
      return DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Stream<List<ElderModel>> getDoctorsPatients(List<String> userIds) {
    if (userIds.isEmpty) return Stream.value([]);
    return _eldersRef
        .where(FieldPath.documentId, whereIn: userIds)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ElderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> linkDoctorToElder({required String elderId, required String doctorId}) async {
    final batch = _db.batch();
    
    // Add doctor ID to Elder's list (if we add such a field later, for now we just link doc to elder in doctors collection)
    batch.set(_db.collection('doctors').doc(doctorId), {
      'patientIds': FieldValue.arrayUnion([elderId])
    }, SetOptions(merge: true));

    await batch.commit();
  }

  // --- Medications ---

  Future<void> addMedication(MedicationModel med) async {
    await _medsRef.doc(med.id).set(med.toMap());
  }

  Stream<List<MedicationModel>> getMedicationsForElder(String elderId) {
    return _medsRef.where('elderId', isEqualTo: elderId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MedicationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  // --- Vitals ---

  Future<void> logVital(VitalModel vital) async {
    await _vitalsRef.add(vital.toMap()); // Auto-ID is fine for vitals logs
  }

  Stream<List<VitalModel>> getVitalsHistory(String elderId, {int limit = 20}) {
    return _vitalsRef
        .where('elderId', isEqualTo: elderId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => VitalModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  // --- Alerts ---

  Future<void> createAlert(AlertModel alert) async {
    await _alertsRef.add(alert.toMap());
  }

  Stream<List<AlertModel>> getActiveAlerts(String elderId) {
    return _alertsRef
        .where('elderId', isEqualTo: elderId)
        .where('isResolved', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AlertModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
}
