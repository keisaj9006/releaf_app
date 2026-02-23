// FILE: lib/features/legal/disclaimer_screen.dart
import 'package:flutter/material.dart';

/// A simple disclaimer page used to display legal notices to the user.
class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disclaimer')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'This application is intended for informational and wellness purposes '
            'only. It does not provide medical advice and should not be used as a '
            'substitute for professional diagnosis or treatment.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}