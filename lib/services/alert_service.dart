import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:medsmart/models/vital_model.dart';
import 'package:medsmart/services/firestore_service.dart';
import 'package:medsmart/services/notification_service.dart';
import 'package:medsmart/models/alert_model.dart';
import 'package:medsmart/services/n8n_service.dart';

class AlertService {
  final _fs = FirestoreService();
  final _ns = NotificationService();
  final _n8n = N8nService();
  StreamSubscription? _vitalsSubscription;

  void startVitalsMonitoring(String userId) {
    _vitalsSubscription?.cancel();
    
    debugPrint("AlertService: Monitoring vitals for user: $userId");
    // Listen to the most recent vital entry
    _vitalsSubscription = _fs.getVitalsHistory(userId, limit: 1).listen((vitals) {
      debugPrint("AlertService: Received vitals update: ${vitals.length} items");
      if (vitals.isNotEmpty) {
        _checkVitalsRange(vitals.first);
      }
    });
  }

  void stopMonitoring() {
    _vitalsSubscription?.cancel();
  }

  Future<void> _checkVitalsRange(VitalModel vital) async {
    debugPrint("AlertService: Checking vitals: HR=${vital.heartRate}, BP=${vital.bloodPressure}, O2=${vital.oxygenLevel}");
    List<String> violations = [];

    if (vital.heartRate < 50) {
      violations.add("Low Heart Rate: ${vital.heartRate} bpm");
    } else if (vital.heartRate > 120) {
      violations.add("High Heart Rate: ${vital.heartRate} bpm");
    }

    if (vital.oxygenLevel < 90) {
      violations.add("Low Oxygen Level: ${vital.oxygenLevel}%");
    }

    // Basic BP parsing (e.g., "120/80")
    try {
      final parts = vital.bloodPressure.split('/');
      final systolic = int.tryParse(parts[0]) ?? 0;
      final diastolic = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      if (systolic > 140) {
        violations.add("High Blood Pressure (Systolic): $systolic");
      } else if (systolic < 90 && systolic > 0) {
        violations.add("Low Blood Pressure (Systolic): $systolic");
      }

      if (diastolic > 90) {
        violations.add("High Blood Pressure (Diastolic): $diastolic");
      } else if (diastolic < 60 && diastolic > 0) {
        violations.add("Low Blood Pressure (Diastolic): $diastolic");
      }
    } catch (e) {
      // Ignore parsing errors
    }

    if (violations.isNotEmpty) {
      final message = violations.join(", ");
      debugPrint("AlertService: Vitals out of range! Triggering alert: $message");
      
      // 1. Show Local Notification
      try {
        await _ns.showNotification(
          title: "🚨 Health Alert!",
          body: message,
        );
      } catch (e) {
        debugPrint("AlertService: Error showing local notification: $e");
      }

      // 2. Log Alert to Firestore so Caregivers/Doctors see it
      final alert = AlertModel(
        id: "", // Auto-gen
        type: "Critical Vitals Alert",
        message: message,
        timestamp: DateTime.now(),
        elderId: vital.elderId,
        isResolved: false,
        severity: "high",
      );
      await _fs.createAlert(alert);
      debugPrint("AlertService: Alert logged to Firestore successfully.");

      // 3. Forward to n8n for external (SMS/Email/WhatsApp) processing
      await _n8n.sendAlert(
        type: "Critical Vitals Alert",
        message: message,
        elderId: vital.elderId,
        metadata: {
          'heartRate': vital.heartRate,
          'bloodPressure': vital.bloodPressure,
          'oxygenLevel': vital.oxygenLevel,
        },
      );
    } else {
      debugPrint("AlertService: Vitals within safe range.");
    }
  }
}
