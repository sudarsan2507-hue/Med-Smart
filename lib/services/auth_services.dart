// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  // Current Firebase user (nullable)
  User? get currentUser => _auth.currentUser;

  // Register with email & password + create Firestore profile
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'elder', // default role
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update display name
    await cred.user?.updateDisplayName(displayName);

    // Create Firestore profile (Base)
    await _fire.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'email': email.trim(),
      'displayName': displayName,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create Role-Specific Profile
    if (role == 'elder') {
      await _fire.collection('elders').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': displayName,
        'email': email.trim(),
        'caregiverIds': [],
      });
    } else if (role == 'caregiver') {
      await _fire.collection('caregivers').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': displayName,
        'email': email.trim(),
        'linkedElderIds': [],
      });
    } else if (role == 'doctor') {
      await _fire.collection('doctors').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': displayName,
        'email': email.trim(),
        'specialization': 'General Practitioner',
        'patientIds': [],
      });
    }

    // Optionally send email verification
    await cred.user?.sendEmailVerification();

    return cred;
  }

  // Sign in with email & password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred;
  }

  // Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Firestore user doc snapshot
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) {
    return _fire.collection('users').doc(uid).get();
  }

  // Optional: update role (admin-only action)
  Future<void> updateUserRole(String uid, String role) async {
    await _fire.collection('users').doc(uid).update({'role': role});
  }
}
