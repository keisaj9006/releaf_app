import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/session/session_manager.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),

          if (session.hasActive)
            Positioned(
              left: 12,
              right: 12,
              bottom: 80,
              child: _ResumePill(
                title: session.title,
                subtitle: session.subtitle,
                onResume: () {
                  context.push(session.resumeRoute, extra: session.extra);
                },
                onDismiss: () {
                  ref.read(sessionManagerProvider.notifier).clear();
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Habits'),
          NavigationDestination(icon: Icon(Icons.self_improvement_outlined), label: 'Relief'),
          NavigationDestination(icon: Icon(Icons.extension_outlined), label: 'Brain'),
        ],
      ),
    );
  }
}

class _ResumePill extends StatelessWidget {
  const _ResumePill({
    required this.title,
    required this.subtitle,
    required this.onResume,
    required this.onDismiss,
  });

  final String title;
  final String subtitle;
  final VoidCallback onResume;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white.withOpacity(0.90),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onResume,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Dismiss',
                onPressed: onDismiss,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}