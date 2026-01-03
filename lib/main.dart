import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medsmart/screens/home_screen.dart';
import 'package:medsmart/screens/link_elder_screen.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/test_database_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // Initialize Notifications
    await NotificationService().init();
    
    // Disable persistence on Web safely if needed later
    // For now, let's get the app running first.
    
    runApp(const MyApp());
  } catch (e) {
    debugPrint("Initialization Error: $e");
    // Still try to run the app or a simple error app
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Init Error: $e")))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedSmart',
      theme: ThemeData(
        useMaterial3: true, 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        "/home": (_) => const HomeScreen(),
        "/test_db": (_) => const TestDatabaseScreen(),
        "/link_elder": (_) => const LinkElderScreen(),
      },
    );
  }
}

