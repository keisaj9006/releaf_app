// FILE: lib/features/bootstrap/bootstrap_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A simple bootstrap screen. It shows a loading indicator and navigates
/// to the home route after the first frame. This screen can be used as
/// the initial entry point of the app.
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home route on the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}