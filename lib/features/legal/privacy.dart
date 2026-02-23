// FILE: lib/features/legal/privacy.dart
import 'package:flutter/material.dart';

/// A simple privacy policy page outlining how the app handles user data.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'We respect your privacy. This app stores your progress locally on your device '
            'using persistent storage (SharedPreferences). No personal data is sent to any '
            'remote server. The collected data includes your daily task completion flags '
            'and your total leaves count, which are used solely to enhance your experience '
            'within the app.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}