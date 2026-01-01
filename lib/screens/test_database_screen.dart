import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/medication_model.dart';
import '../models/vital_model.dart';
import '../models/alert_model.dart';

class TestDatabaseScreen extends StatefulWidget {
  const TestDatabaseScreen({super.key});

  @override
  State<TestDatabaseScreen> createState() => _TestDatabaseScreenState();
}

class _TestDatabaseScreenState extends State<TestDatabaseScreen> {
  final FirestoreService _fs = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _status;

  void _log(String msg) {
    setState(() => _status = msg);
    debugPrint(msg);
  }

  Future<void> _addMockMedication() async {
    _log("⏳ Sending request to Firestore...");
    final user = _auth.currentUser;
    if (user == null) {
      _log("Error: No user logged in");
      return;
    }

    try {
      final med = MedicationModel(
        id: const Uuid().v4(),
        name: "Test Panadol",
        dosage: "500mg",
        instructions: "Take after food",
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        frequency: ["09:00", "21:00"],
        elderId: user.uid,
      );
      await _fs.addMedication(med).timeout(const Duration(seconds: 20));
      _log("✅ Success: Added Medication ${med.id}");
    } catch (e) {
      _log("❌ Error: $e");
    }
  }

  Future<void> _addMockVital() async {
    _log("⏳ Sending request to Firestore...");
    final user = _auth.currentUser;
    if (user == null) {
      _log("Error: No user logged in");
      return;
    }

    try {
      final vital = VitalModel(
        id: const Uuid().v4(), 
        heartRate: 75,
        bloodPressure: '120/80',
        oxygenLevel: 98.0,
        timestamp: DateTime.now(),
        elderId: user.uid,
      );
      await _fs.logVital(vital).timeout(const Duration(seconds: 20));
      _log("✅ Success: Logged Vital (HR: 75, BP: 120/80, O2: 98%)");
    } catch (e) {
      _log("❌ Error: $e");
    }
  }

  Future<void> _triggerAlert() async {
     _log("⏳ Sending request to Firestore...");
    final user = _auth.currentUser;
    if (user == null) {
      _log("Error: No user logged in");
      return;
    }

    try {
      final alert = AlertModel(
        id: const Uuid().v4(),
        type: 'sos',
        severity: 'high',
        message: 'Test SOS Triggered!',
        timestamp: DateTime.now(),
        isResolved: false,
        elderId: user.uid,
      );
      await _fs.createAlert(alert).timeout(const Duration(seconds: 20));
      _log("✅ Success: Create Alert SOS");
    } catch (e) {
      _log("❌ Error: $e");
    }
  }

  Future<void> _runDiagnostics() async {
    _log("🔍 Starting Diagnostics...");
    final user = _auth.currentUser;
    if (user == null) {
      _log("❌ Auth Check: User NOT logged in");
      return;
    } else {
      _log("✅ Auth Check: Logged in as ${user.email}");
    }

    final db = FirebaseFirestore.instance;

    // 1. Connectivity / Read Test
    _log("⏳ Testing READ connection (5s timeout)...");
    try {
      // Try to read a non-existent doc. If online, this returns null instantly. 
      // If offline/blocked, this hangs.
      await db.collection('test_connectivity').doc('ping').get().timeout(const Duration(seconds: 5));
      _log("✅ READ Success: Connected to Firestore!");
    } catch (e) {
      _log("❌ READ Failed: $e");
      _log("⚠️ Conclusion: Network/Firewall is blocking Firestore.");
      return; // Stop here
    }

    // 2. Write Test
    _log("⏳ Testing WRITE permission (5s timeout)...");
    try {
      await db.collection('test_connectivity').doc('ping').set({
        'last_check': DateTime.now().toString(),
        'uid': user.uid
      }).timeout(const Duration(seconds: 5));
      _log("✅ WRITE Success: Connectivity is perfect!");
    } catch (e) {
      _log("❌ WRITE Failed: $e");
      _log("⚠️ Conclusion: Connected, but Security Rules blocked write.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Level 1 Verification")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user != null 
                  ? "Logged in as: ${user.email} (${user.uid})" 
                  : "⚠️ NOT LOGGED IN",
                style: TextStyle(
                  color: user != null ? Colors.green : Colors.red, 
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Diagnostic Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: _runDiagnostics,
                icon: const Icon(Icons.network_check),
                label: const Text("RUN CONNECTIVITY CHECK"),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey[200],
                width: double.infinity,
                height: 150, // Fixed height for log area
                child: SingleChildScrollView(
                  child: Text(
                    _status ?? "Ready to test...", 
                    style: const TextStyle(fontFamily: "monospace", fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _addMockMedication, child: const Text("1. Add Mock Medication")),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _addMockVital, child: const Text("2. Log Mock Vital")),
               const SizedBox(height: 10),
              ElevatedButton(onPressed: _triggerAlert, child: const Text("3. Trigger SOS Alert")),
              
              if (user == null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                    child: const Text("Go to Login Screen"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
