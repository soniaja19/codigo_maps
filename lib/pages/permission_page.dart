import 'package:flutter/material.dart';

class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/location2.png",
              height: 220.0,
            ),
            const Text(
                "Para usar todas las funcionalidades del aplicativo debes de activar el GPS"),
            const SizedBox(
              height: 12.0,
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text(
                "Activar GPS",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
