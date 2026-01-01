// @/OccazCar/lib/main.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importez vos écrans
import 'package:occazcar/features/auth/ui/login_screen.dart';
import 'package:occazcar/features/auth/ui/register_screen.dart';
import 'package:occazcar/features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ====================================================================
  //               LA LIGNE DE CODE QUI RÈGLE VOTRE PROBLÈME
  //
  // On force la déconnexion à chaque redémarrage de l'application.
  // C'est une astuce uniquement pour la phase de DÉVELOPPEMENT.
  await FirebaseAuth.instance.signOut();
  // ====================================================================

  runApp(const MyApp());
}

// Le reste de votre fichier MyApp est parfait et ne change pas.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OccazCar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        // ... votre thème ...
      ),
      // Votre StreamBuilder est parfait, il n'a pas besoin d'être changé.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            // L'utilisateur est connecté -> Dashboard
            return const DashboardScreen();
          }
          // L'utilisateur n'est pas connecté -> Login
          return const LoginScreen();
        },
      ),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
