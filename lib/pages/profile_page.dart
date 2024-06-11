import 'package:budgetplannertracker/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final _auth = AuthService();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _auth.getCurrentUser()!;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          user.displayName!.toUpperCase(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email!,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            _auth.logout();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Sign Out',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
