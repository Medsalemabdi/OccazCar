// @/OccazCar/lib/features/auth/ui/login_screen.dartimport 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      // 1. TENTATIVE DE CONNEXION
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. VÉRIFICATION DE L'EMAIL
      if (credential.user != null && !credential.user!.emailVerified) {
        // L'email n'est pas vérifié : on déconnecte immédiatement pour empêcher l'accès
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  "Veuillez vérifier votre email avant de vous connecter."),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: "OK",
                textColor: Colors.white,
                onPressed: () {
                  // Fermer la snackbar
                },
              ),
            ),
          );
        }
        return; // On arrête ici, pas de redirection automatique car signOut() a été appelé
      }

      // Si on arrive ici, l'email est vérifié (ou null), la redirection sera automatique via main.dart

    } on FirebaseAuthException catch (e) {
      // En cas d'erreur (mot de passe incorrect, etc.)
      if (mounted) {
        String message = "Erreur de connexion.";
        if (e.code == 'user-not-found') {
          message = "Aucun utilisateur trouvé pour cet email.";
        } else if (e.code == 'wrong-password') {
          message = "Mot de passe incorrect.";
        } else if (e.code == 'invalid-email') {
          message = "Format d'email invalide.";
        } else if (e.code == 'user-disabled') {
          message = "Ce compte a été désactivé.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
                decoration: const InputDecoration(
                    labelText: 'Email', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                v == null || v.isEmpty ? 'Email requis' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Mot de passe', prefixIcon: Icon(Icons.lock)),
                validator: (v) =>
                v == null || v.isEmpty ? 'Mot de passe requis' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
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
