// @/OccazCar/lib/features/auth/ui/login_screen.dart

import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. ON IMPORTE LE SERVICE OFFICIEL
import 'package:flutter/material.dart';

// On n'importe plus votre 'AuthService' personnel.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // On n'a plus besoin de 'AuthService _authService = AuthService();'

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. LA FONCTION DE CONNEXION QUI DÉCLENCHE LA REDIRECTION
  Future<void> _login() async {
    // Valide le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Affiche le spinner
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. ON APPELLE DIRECTEMENT FIREBASE AUTH
      // C'est cette ligne qui va "crier" à main.dart : "L'UTILISATEUR EST CONNECTÉ !"
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Si ça réussit, ON NE FAIT RIEN DE PLUS. La redirection est maintenant automatique.
      // Pas besoin de 'Navigator.push' ici.

    } on FirebaseAuthException catch (e) {
      // En cas d'erreur (mot de passe incorrect, etc.), on prévient l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Email ou mot de passe incorrect."),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // Quoi qu'il arrive, on arrête le chargement
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bienvenue 👋',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.isEmpty ? 'Email requis' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock)),
                validator: (v) => v == null || v.isEmpty ? 'Mot de passe requis' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                // 4. ON APPELLE LA NOUVELLE FONCTION _login
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text("Pas encore de compte ? S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
