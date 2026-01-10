import 'package:flutter/material.dart';
import 'package:medsmart/models/elder_model.dart';
import 'package:medsmart/models/medication_model.dart';
import 'package:medsmart/models/vital_model.dart';
import 'package:medsmart/services/firestore_service.dart';
import 'package:medsmart/services/auth_services.dart';
import 'prescribe_medication_screen.dart';

class ElderDetailScreen extends StatelessWidget {
  final ElderModel elder;
  const ElderDetailScreen({super.key, required this.elder});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Monitoring: ${elder.name}"),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            _buildVitalsSection(context, fs),
            _buildMedicationsSection(context, fs),
            _buildDoctorActions(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorActions(BuildContext context) {
    final auth = AuthService();
    return FutureBuilder(
      future: auth.getUserDoc(auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final role = snapshot.data?.data()?['role'];
        if (role != 'doctor') return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrescribeMedicationScreen(
                    elderId: elder.uid,
                    elderName: elder.name,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              icon: const Icon(Icons.add_moderator),
              label: const Text("Write New Prescription"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.teal.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Basic Information", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip("Age: ${elder.age}"),
              const SizedBox(width: 8),
              _infoChip("Blood: ${elder.bloodType}"),
            ],
          ),
          const SizedBox(height: 8),
          Text("Medical Conditions:", style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 8,
            children: elder.medicalConditions.map((c) => Chip(label: Text(c), visualDensity: VisualDensity.compact)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildVitalsSection(BuildContext context, FirestoreService fs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Vitals", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          StreamBuilder<List<VitalModel>>(
            stream: fs.getVitalsHistory(elder.uid, limit: 1),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Error fetching vitals: ${snapshot.error}", 
                  style: const TextStyle(color: Colors.red, fontSize: 12));
              }
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final vitals = snapshot.data!;
              if (vitals.isEmpty) return const Text("No vitals logged yet.");

              final latest = vitals.first;
              return Card(
                elevation: 0,
                color: Colors.blueGrey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _vitalDetail("Heart Rate", "${latest.heartRate} bpm", Icons.favorite, Colors.red),
                      _vitalDetail("BP", latest.bloodPressure, Icons.speed, Colors.blue),
                      _vitalDetail("Oxygen", "${latest.oxygenLevel}%", Icons.air, Colors.orange),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _vitalDetail(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMedicationsSection(BuildContext context, FirestoreService fs) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Active Medications", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          StreamBuilder<List<MedicationModel>>(
            stream: fs.getMedicationsForElder(elder.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final meds = snapshot.data!;
              if (meds.isEmpty) return const Text("No medications assigned.");

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meds.length,
                itemBuilder: (context, index) {
                  final med = meds[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.medication, color: Colors.white)),
                    title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${med.dosage} • ${med.instructions}"),
                        if (med.prescribedBy != null)
                          Text("Prescribed by: ${med.prescribedBy}", 
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.indigo)),
                      ],
                    ),
                    trailing: Text(med.frequency.join(", "), style: const TextStyle(color: Colors.teal)),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
