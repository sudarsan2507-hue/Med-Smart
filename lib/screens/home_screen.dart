import 'package:flutter/material.dart';
import 'package:medsmart/services/auth_services.dart';
import 'package:medsmart/services/firestore_service.dart';
import 'package:medsmart/models/elder_model.dart';
import 'package:medsmart/models/caregiver_model.dart';
import 'package:medsmart/models/medication_model.dart';
import 'package:medsmart/screens/add_medication_screen.dart';
import 'package:medsmart/screens/elder_profile_screen.dart';
import 'package:medsmart/screens/elder_detail_screen.dart';
import 'package:medsmart/screens/log_vitals_screen.dart';
import 'package:medsmart/models/doctor_model.dart';
import 'package:medsmart/models/vital_model.dart';
import 'link_elder_screen.dart';
import 'link_patient_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    return FutureBuilder(
      future: auth.getUserDoc(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userData = snapshot.data?.data();
        final role = userData?['role'] ?? 'elder';

        if (role == 'caregiver') {
          return const CaregiverDashboard();
        } else if (role == 'doctor') {
          return const DoctorDashboard();
        } else {
          return const ElderDashboard();
        }
      },
    );
  }
}

// ... ElderDashboard and CaregiverDashboard (previously defined)

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Portal"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () => AuthService().signOut(), icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<DoctorModel>(
        stream: fs.getDoctorStream(user!.uid),
        builder: (context, doctorSnapshot) {
          if (doctorSnapshot.hasError) return Center(child: Text("Error: ${doctorSnapshot.error}"));
          if (!doctorSnapshot.hasData) return const Center(child: CircularProgressIndicator());

          final doctor = doctorSnapshot.data!;
          final patientIds = doctor.patientIds;

          return Column(
            children: [
              _buildDoctorHeader(doctor),
              if (patientIds.isEmpty)
                Expanded(child: _buildEmptyPatients(context))
              else
                Expanded(
                  child: StreamBuilder<List<ElderModel>>(
                    stream: fs.getDoctorsPatients(patientIds),
                    builder: (context, patientsSnapshot) {
                      if (!patientsSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final patients = patientsSnapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("My Patients (${patients.length})", 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                TextButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LinkPatientScreen()),
                                  ),
                                  icon: const Icon(Icons.person_add),
                                  label: const Text("Add New"),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: patients.length,
                              itemBuilder: (context, index) {
                                final patient = patients[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: const CircleAvatar(child: Icon(Icons.person)),
                                    title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text("Age: ${patient.age} | ${patient.bloodType}"),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ElderDetailScreen(elder: patient)),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LinkPatientScreen()),
        ),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDoctorHeader(DoctorModel doctor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border(bottom: BorderSide(color: Colors.indigo.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dr. ${doctor.name}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
          Text(doctor.specialization, style: TextStyle(fontSize: 16, color: Colors.indigo.shade700)),
          const SizedBox(height: 10),
          const Text("Manage your patients and monitor their health metrics remotely.", 
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyPatients(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outlined, size: 80, color: Colors.indigo.shade200),
          const SizedBox(height: 16),
          const Text("No patients added to your list yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LinkPatientScreen()),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            icon: const Icon(Icons.search),
            label: const Text("Search and Add Patients"),
          ),
        ],
      ),
    );
  }
}

// ... ElderDashboard and CaregiverDashboard (keep existing implementations)


class ElderDashboard extends StatelessWidget {
  const ElderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final fs = FirestoreService();

    return StreamBuilder<ElderModel>(
      stream: fs.getElderStream(user!.uid),
      builder: (context, elderSnapshot) {
        if (elderSnapshot.hasError) {
          // If no elder profile exists yet, show a welcome/initial configuration button
          return _buildInitialSetup(context, user.uid, user.displayName ?? "User", user.email ?? "");
        }
        if (!elderSnapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final elder = elderSnapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text("Hi, ${elder.name}"),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ElderProfileScreen(elder: elder)),
                ),
              ),
              IconButton(onPressed: () => AuthService().signOut(), icon: const Icon(Icons.logout))
            ],
          ),
          body: Column(
            children: [
              _buildHeader(elder),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LogVitalsScreen(elderId: elder.uid)),
                        ),
                        icon: const Icon(Icons.add_task),
                        label: const Text("Log My Vitals"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade100),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<MedicationModel>>(
                  stream: fs.getMedicationsForElder(elder.uid),
                  builder: (context, medsSnapshot) {
                    if (!medsSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final meds = medsSnapshot.data!;

                    return ListView(
                      children: [
                        _buildVitalsSummary(context, fs, elder.uid),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Medications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        if (meds.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text("No medications added yet.")),
                          )
                        else
                          ...meds.map((med) => Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.medication, color: Colors.teal),
                                  title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("${med.dosage} - ${med.instructions}"),
                                  trailing: Text(med.frequency.join(", ")),
                                ),
                              )),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddMedicationScreen(elderId: elder.uid)),
            ),
            label: const Text("Add Medication"),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildVitalsSummary(BuildContext context, FirestoreService fs, String elderId) {
    return StreamBuilder<List<VitalModel>>(
      stream: fs.getVitalsHistory(elderId, limit: 1),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Vitals Error: ${snapshot.error}", style: const TextStyle(color: Colors.red, fontSize: 12)),
          );
        }
        if (!snapshot.hasData) return const SizedBox.shrink();
        final vitals = snapshot.data!;
        if (vitals.isEmpty) return const SizedBox.shrink();

        final latest = vitals.first;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Latest Vitals Recorded", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _vitalItem("HR", "${latest.heartRate}", Icons.favorite, Colors.red),
                  _vitalItem("BP", latest.bloodPressure, Icons.speed, Colors.blue),
                  _vitalItem("O2", "${latest.oxygenLevel}%", Icons.air, Colors.orange),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _vitalItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHeader(ElderModel elder) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.teal.shade50,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome back, ${elder.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Manage your health status below:"),
        ],
      ),
    );
  }

  Widget _buildInitialSetup(BuildContext context, String uid, String name, String email) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Let's set up your profile, Elder!"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final fs = FirestoreService();
                await fs.createElderProfile(ElderModel(
                  uid: uid,
                  name: name,
                  email: email,
                  phone: "",
                  age: 0,
                  bloodType: "Unknown",
                  medicalConditions: [],
                  caregiverIds: [],
                ));
              },
              child: const Text("Initialize My Profile"),
            ),
          ],
        ),
      ),
    );
  }
}

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Caregiver Dashboard"),
        actions: [
          IconButton(onPressed: () => AuthService().signOut(), icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<CaregiverModel>(
        stream: fs.getCaregiverStream(user!.uid),
        builder: (context, caregiverSnapshot) {
          if (caregiverSnapshot.hasError) return Center(child: Text("Error: ${caregiverSnapshot.error}"));
          if (!caregiverSnapshot.hasData) return const Center(child: CircularProgressIndicator());

          final caregiver = caregiverSnapshot.data!;
          final elderIds = caregiver.linkedElderIds;

          if (elderIds.isEmpty) {
            return _buildEmptyState(context);
          }

          return StreamBuilder<List<ElderModel>>(
            stream: fs.getCaregiversElders(elderIds),
            builder: (context, eldersSnapshot) {
              if (eldersSnapshot.hasError) return Center(child: Text("Error: ${eldersSnapshot.error}"));
              if (!eldersSnapshot.hasData) return const Center(child: CircularProgressIndicator());

              final elders = eldersSnapshot.data!;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("My Elders (${elders.length})", style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.teal),
                          onPressed: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => const LinkElderScreen())
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: elders.length,
                      itemBuilder: (context, index) {
                        final elder = elders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(elder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Email: ${elder.email}"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ElderDetailScreen(elder: elder)),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No elders linked yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const LinkElderScreen())
            ), 
            icon: const Icon(Icons.add), 
            label: const Text("Link Your First Elder")
          ),
        ],
      ),
    );
  }
}
