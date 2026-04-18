import 'package:flutter/material.dart';
import 'package:total_x/user/presentation/pages/otp_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpPage(
                      phone: phoneController.text,
                    ),
                  ),
                );
              },
              child: const Text("Send OTP"),
            )
          ],
        ),
      ),
    );
  }
}