// FILE: lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Releaf')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Quick loop (3 minutes)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Relief (1 min) → Brain (1–2 min) → 1 Habit'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.go('${AppRoutes.home}/${AppRoutes.dailyLoop}'),
                      child: const Text('Start Daily Loop'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _QuickTile(
                    title: '1-minute relief',
                    subtitle: 'Breathing + optional audio',
                    icon: Icons.self_improvement_outlined,
                    onTap: () => context.go(AppRoutes.relief),
                  ),
                  _QuickTile(
                    title: '1 game',
                    subtitle: 'Fast focus session',
                    icon: Icons.extension_outlined,
                    onTap: () => context.go(AppRoutes.brain),
                  ),
                  _QuickTile(
                    title: '1 habit',
                    subtitle: 'Tap once to log today',
                    icon: Icons.checklist_outlined,
                    onTap: () => context.go(AppRoutes.habits),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}