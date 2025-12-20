import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Trader AI Tutor'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Placeholder for Google Sign In
                // In a real app, you'd trigger Supabase Auth here
                // await Supabase.instance.client.auth.signInWithOAuth(Provider.google);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configure Supabase keys in core/constants.dart to sign in!')),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
