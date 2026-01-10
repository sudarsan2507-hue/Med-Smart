import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock Data
  final String userName = "Grandpa Joe";
  bool isTaken = false;

  @override
  Widget build(BuildContext context) {
    // Format date: "Monday, August 12"
    final String todayDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGradientHeader(userName, todayDate),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // "NOW" Section Header
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "NOW",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                         color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // The BIG Card
                  _buildNextMedicationCard(context),
                  
                  const SizedBox(height: 40),
                  
                  // Up Next List
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "LATER TODAY",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                         color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMedicationTile(context, "Metformin", "1 Tablet", "12:30 PM", Icons.local_dining, Colors.orange),
                  _buildMedicationTile(context, "Atorvastatin", "1 Tablet", "8:00 PM", Icons.bedtime, Colors.indigo),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBigBottomNav(context),
    );
  }

  Widget _buildGradientHeader(String name, String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF009688), // Teal
            const Color(0xFF004D40), // Dark Teal
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
             color: const Color(0xFF009688).withValues(alpha: 0.3),
             blurRadius: 15,
             offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Good Morning,",
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              date,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMedicationCard(BuildContext context) {
    if (isTaken) {
      return Card(
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(24),
           side: BorderSide(color: Colors.green.shade200, width: 2),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              Text(
                "Great Job!",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.green.shade800,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You took your meds.",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
               SizedBox(
                width: double.infinity,
                 child: TextButton.icon(
                  onPressed: () => setState(() => isTaken = false),
                  icon: const Icon(Icons.undo, size: 28),
                  label: const Text("Undo", style: TextStyle(fontSize: 20)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                 ),
               ),
            ],
          ),
        ),
      );
    }

    return Card(
      // Default CardTheme from AppTheme applies here (elevation, shape, etc.)
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Colored Top Strip
            Container(
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFFFF7043), // Salmon Accent
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                       Container(
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: const Color(0xFFE0F2F1), // Light Teal
                           borderRadius: BorderRadius.circular(16),
                         ),
                         child: const Icon(Icons.medication, size: 40, color: Color(0xFF009688)),
                       ),
                       const SizedBox(width: 20),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               "Lisinopril",
                               style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                 fontSize: 28,
                               ),
                             ),
                             const SizedBox(height: 4),
                             Text(
                               "10 mg • 1 Tablet",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                             ),
                           ],
                         ),
                       ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => isTaken = true);
                      },
                      style: ElevatedButton.styleFrom(
                         shadowColor: const Color(0xFF009688).withValues(alpha: 0.5),
                         elevation: 8,
                      ),
                      child: const Text("I TOOK IT"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                       onPressed: () {},
                       style: TextButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 20),
                         foregroundColor: Colors.grey.shade500,
                       ),
                       child: Text(
                         "SKIP FOR NOW",
                         style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                       ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationTile(BuildContext context, String name, String dose, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: color.withValues(alpha: 0.1),
                 shape: BoxShape.circle,
               ),
               child: Icon(icon, size: 32, color: color),
             ),
             const SizedBox(width: 20),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     name, 
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     "$dose • $time", 
                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                   ),
                 ],
               ),
             ),
             Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBigBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
         boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
        iconSize: 28,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home_rounded)),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.calendar_month_rounded)),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.person_rounded)),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
