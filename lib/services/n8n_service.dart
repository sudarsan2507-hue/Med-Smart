import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class N8nService {
  // PLACEHOLDER: The user should provide their n8n webhook URL
  static const String _webhookUrl = 'http://localhost:5678/webhook-test/5aee8cf7-e433-479b-8a9b-0093a9c4f7fb';

  Future<void> sendAlert({
    required String type,
    required String message,
    required String elderId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event': 'health_alert',
          'type': type,
          'message': message,
          'elderId': elderId,
          'timestamp': DateTime.now().toIso8601String(),
          'metadata': metadata,
        }),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('N8nService: Alert successfully forwarded to n8n');
      } else {
        debugPrint('N8nService: n8n returned error status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('N8nService: Error connecting to n8n: $e');
    }
  }

  Future<void> sendMedicationReminder({
    required String medicationName,
    required String elderName,
    required String time,
  }) async {
    try {
      await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event': 'medication_reminder',
          'medication': medicationName,
          'patient': elderName,
          'scheduledTime': time,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      debugPrint('N8nService: Error sending reminder to n8n: $e');
    }
  }
}
