import 'package:flutter/material.dart';
import 'package:medsmart/models/medication_model.dart';
import 'package:medsmart/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class AddMedicationScreen extends StatefulWidget {
  final String elderId;
  const AddMedicationScreen({super.key, required this.elderId});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fs = FirestoreService();

  final _nameC = TextEditingController();
  final _dosageC = TextEditingController();
  final _instructionsC = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final List<String> _frequencies = ["08:00"];

  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final med = MedicationModel(
        id: const Uuid().v4(),
        name: _nameC.text,
        dosage: _dosageC.text,
        instructions: _instructionsC.text,
        startDate: _startDate,
        endDate: _endDate,
        frequency: _frequencies,
        elderId: widget.elderId,
      );

      await _fs.addMedication(med);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Medication")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _nameC,
              decoration: const InputDecoration(labelText: "Medication Name", hintText: "e.g. Paracetamol"),
              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
            ),
            TextFormField(
              controller: _dosageC,
              decoration: const InputDecoration(labelText: "Dosage", hintText: "e.g. 500mg"),
              validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
            ),
            TextFormField(
              controller: _instructionsC,
              decoration: const InputDecoration(labelText: "Instructions", hintText: "e.g. " "Take after food" ""),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Start Date"),
              subtitle: Text("${_startDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (d != null) setState(() => _startDate = d);
              },
            ),
            ListTile(
              title: const Text("End Date"),
              subtitle: Text("${_endDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _endDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (d != null) setState(() => _endDate = d);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading ? const CircularProgressIndicator() : const Text("Save Medication"),
            ),
          ]),
        ),
      ),
    );
  }
}
