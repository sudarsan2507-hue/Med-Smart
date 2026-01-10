import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/elder_model.dart';

class LinkElderScreen extends StatefulWidget {
  const LinkElderScreen({super.key});

  @override
  State<LinkElderScreen> createState() => _LinkElderScreenState();
}

class _LinkElderScreenState extends State<LinkElderScreen> {
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
        setState(() => _error = "Elder not found with this email.");
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
      await _fs.linkCaregiverToElder(
        elderId: _foundElder!.uid,
        caregiverId: user.uid,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully linked with ${_foundElder!.name}!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
       setState(() => _error = "Error linking: $e");
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Link with Elder")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailC,
              decoration: const InputDecoration(
                labelText: "Elder's Email Address",
                hintText: "Enter the email your elder used to register",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searching ? null : _search,
              child: _searching ? const CircularProgressIndicator() : const Text("Search Elder"),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_foundElder != null)
              Card(
                child: ListTile(
                  title: Text(_foundElder!.name),
                  subtitle: Text(_foundElder!.email),
                  trailing: ElevatedButton(
                    onPressed: _searching ? null : _link,
                    child: const Text("Link & Add"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
