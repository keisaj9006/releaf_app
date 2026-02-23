import 'package:flutter/material.dart';

class ResetScreen extends StatelessWidget {
  const ResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.self_improvement),
            title: Text("Szybka medytacja"),
            subtitle: Text("2-minuty relaksu i oddechu"),
          ),
          ListTile(
            leading: Icon(Icons.nightlight),
            title: Text("Sen i regeneracja"),
            subtitle: Text("Porady na lepszy sen i balans"),
          ),
        ],
      ),
    );
  }
}
