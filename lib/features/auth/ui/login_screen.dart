import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs pour récupérer le texte des champs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Clé pour le formulaire, utile pour la validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Il est important de "nettoyer" les contrôleurs quand le widget est détruit
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centre les éléments verticalement
            crossAxisAlignment: CrossAxisAlignment.stretch, // Étire les éléments horizontalement
            children: [
              const Text(
                'Bienvenue !',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Champ de texte pour l'email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ de texte pour le mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: true, // Masque le mot de passe
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Bouton de connexion
              ElevatedButton(
                onPressed: () {
                  // Vérifie si le formulaire est valide
                  if (_formKey.currentState!.validate()) {
                    // Si oui, on peut procéder à la logique de connexion
                    String email = _emailController.text;
                    String password = _passwordController.text;

                    // TODO: Implémenter la logique d'authentification ici
                    print('Email: $email, Password: $password');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connexion en cours...')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 15),

              // Lien pour aller vers la page d'inscription
              // ...
              // Lien pour aller vers la page d'inscription
              TextButton(
                onPressed: () {
                  // Navigue vers l'écran d'inscription en utilisant la route nommée
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Pas encore de compte ? S\'inscrire'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
