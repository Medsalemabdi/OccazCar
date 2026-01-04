import 'package:flutter/material.dart';
import 'package:occazcar/features/buyer/ui/buyer_home_screen.dart'; // buyer
import 'package:occazcar/features/users/services/user_service.dart';
import 'package:occazcar/features/dashboard/dashboard_screen.dart'; // seller


class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Utilisateur introuvable')),
          );
        }

        final user = snapshot.data!;

        if (user.role == 'seller') {
          return const DashboardScreen();
        }

        if (user.role == 'buyer') {
          return const BuyerHomeScreen();
        }

        return const Scaffold(
          body: Center(child: Text('Rôle inconnu')),
        );
      },
    );
  }
}
