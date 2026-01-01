import 'package:flutter/material.dart';
import 'package:medsmart/models/vital_model.dart';
import 'package:medsmart/services/firestore_service.dart';

class LogVitalsScreen extends StatefulWidget {
  final String elderId;
  const LogVitalsScreen({super.key, required this.elderId});

  @override
  State<LogVitalsScreen> createState() => _LogVitalsScreenState();
}

class _LogVitalsScreenState extends State<LogVitalsScreen> {
  final _fs = FirestoreService();
  final _hrC = TextEditingController();
  final _bpC = TextEditingController();
  final _oxC = TextEditingController();
  bool _loading = false;

  Future<void> _log() async {
    if (_hrC.text.isEmpty || _bpC.text.isEmpty || _oxC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _loading = true);
    try {
      final vital = VitalModel(
        id: "", // Firestore generates ID
        heartRate: int.tryParse(_hrC.text) ?? 0,
        bloodPressure: _bpC.text,
        oxygenLevel: double.tryParse(_oxC.text) ?? 0,
        timestamp: DateTime.now(),
        elderId: widget.elderId,
      );

      await _fs.logVital(vital);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vitals recorded successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log My Vitals")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _hrC, decoration: const InputDecoration(labelText: "Heart Rate (bpm)"), keyboardType: TextInputType.number),
            TextField(controller: _bpC, decoration: const InputDecoration(labelText: "Blood Pressure (e.g. 120/80)"), keyboardType: TextInputType.text),
            TextField(controller: _oxC, decoration: const InputDecoration(labelText: "Oxygen Level (%)"), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _log,
              child: _loading ? const CircularProgressIndicator() : const Text("Save Vitals"),
            ),
          ],
        ),
      ),
    );
  }
}
