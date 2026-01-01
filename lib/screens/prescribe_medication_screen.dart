import 'package:flutter/material.dart';
import 'package:medsmart/models/medication_model.dart';
import 'package:medsmart/services/firestore_service.dart';
import 'package:medsmart/services/auth_services.dart';
import 'package:uuid/uuid.dart';

class PrescribeMedicationScreen extends StatefulWidget {
  final String elderId;
  final String elderName;
  const PrescribeMedicationScreen({super.key, required this.elderId, required this.elderName});

  @override
  State<PrescribeMedicationScreen> createState() => _PrescribeMedicationScreenState();
}

class _PrescribeMedicationScreenState extends State<PrescribeMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fs = FirestoreService();
  final _auth = AuthService();

  final _nameC = TextEditingController();
  final _dosageC = TextEditingController();
  final _instructionsC = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final List<String> _frequencies = ["08:00", "20:00"];

  bool _loading = false;

  Future<void> _prescribe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      final med = MedicationModel(
        id: const Uuid().v4(),
        name: _nameC.text,
        dosage: _dosageC.text,
        instructions: _instructionsC.text,
        startDate: _startDate,
        endDate: _endDate,
        frequency: _frequencies,
        elderId: widget.elderId,
        prescribedBy: user?.displayName ?? "Doctor",
      );

      await _fs.addMedication(med);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prescription saved successfully!")));
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
      appBar: AppBar(
        title: const Text("Write Prescription"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Patient: ${widget.elderName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: "Medication Name", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageC,
                decoration: const InputDecoration(labelText: "Dosage (e.g. 1 pill twice daily)", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsC,
                decoration: const InputDecoration(labelText: "Clinical Instructions", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text("Frequency & Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
              const ListTile(
                leading: Icon(Icons.access_time),
                title: Text("Twice daily (Default)"),
                subtitle: Text("08:00, 20:00"),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _prescribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("SIGN & SAVE PRESCRIPTION"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
