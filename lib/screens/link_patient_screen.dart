import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/elder_model.dart';

class LinkPatientScreen extends StatefulWidget {
  const LinkPatientScreen({super.key});

  @override
  State<LinkPatientScreen> createState() => _LinkPatientScreenState();
}

class _LinkPatientScreenState extends State<LinkPatientScreen> {
  final _fs = FirestoreService();
  final _emailC = TextEditingController();
  bool _searching = false;
  ElderModel? _foundElder;
  String? _error;

  Future<void> _search() async {
    if (_emailC.text.isEmpty) return;
    setState(() {
      _searching = true;
      _error = null;
      _foundElder = null;
    });

    try {
      final elder = await _fs.findElderByEmail(_emailC.text);
      if (elder == null) {
        setState(() => _error = "Patient not found with this email.");
      } else {
        setState(() => _foundElder = elder);
      }
    } catch (e) {
      setState(() => _error = "Error searching: $e");
    } finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _link() async {
    if (_foundElder == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _searching = true);
    try {
      await _fs.linkDoctorToElder(
        elderId: _foundElder!.uid,
        doctorId: user.uid,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully added ${_foundElder!.name} to your patients!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
       setState(() => _error = "Error adding patient: $e");
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Patient")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Search for your patient by their registered email address.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailC,
              decoration: const InputDecoration(
                labelText: "Patient's Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _searching ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text("Search Patient"),
              ),
            ),
            const SizedBox(height: 24),
            if (_searching) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_foundElder != null)
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(_foundElder!.name),
                  subtitle: Text(_foundElder!.email),
                  trailing: ElevatedButton(
                    onPressed: _searching ? null : _link,
                    child: const Text("Add Patient"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
