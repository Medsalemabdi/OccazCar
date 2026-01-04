import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppLogoutButton extends StatelessWidget {
  const AppLogoutButton({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();


  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => _logout(context),
      tooltip: 'Se déconnecter',
    );
  }
}
