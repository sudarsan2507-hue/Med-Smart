import 'package:flutter/material.dart';
import 'package:medsmart/models/elder_model.dart';
import 'package:medsmart/services/firestore_service.dart';

class ElderProfileScreen extends StatefulWidget {
  final ElderModel elder;
  const ElderProfileScreen({super.key, required this.elder});

  @override
  State<ElderProfileScreen> createState() => _ElderProfileScreenState();
}

class _ElderProfileScreenState extends State<ElderProfileScreen> {
  final _fs = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameC;
  late TextEditingController _phoneC;
  late TextEditingController _ageC;
  late TextEditingController _bloodC;
  late TextEditingController _conditionsC;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.elder.name);
    _phoneC = TextEditingController(text: widget.elder.phone);
    _ageC = TextEditingController(text: widget.elder.age.toString());
    _bloodC = TextEditingController(text: widget.elder.bloodType);
    _conditionsC = TextEditingController(text: widget.elder.medicalConditions.join(", "));
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final updatedElder = ElderModel(
        uid: widget.elder.uid,
        name: _nameC.text,
        email: widget.elder.email,
        phone: _phoneC.text,
        age: int.tryParse(_ageC.text) ?? 0,
        bloodType: _bloodC.text,
        medicalConditions: _conditionsC.text.split(",").map((e) => e.trim()).toList(),
        caregiverIds: widget.elder.caregiverIds,
      );

      await _fs.createElderProfile(updatedElder); // Re-uses build to update
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!")));
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
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(controller: _nameC, decoration: const InputDecoration(labelText: "Full Name")),
            TextFormField(controller: _phoneC, decoration: const InputDecoration(labelText: "Phone")),
            TextFormField(controller: _ageC, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
            TextFormField(controller: _bloodC, decoration: const InputDecoration(labelText: "Blood Type")),
            TextFormField(controller: _conditionsC, decoration: const InputDecoration(labelText: "Medical Conditions (comma separated)")),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _update,
              child: _loading ? const CircularProgressIndicator() : const Text("Update Profile"),
            ),
          ]),
        ),
      ),
    );
  }
}
