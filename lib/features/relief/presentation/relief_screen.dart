// FILE: lib/features/relief/presentation/relief_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_catalog.dart';
import 'breathing_widget.dart';

class ReliefScreen extends ConsumerWidget {
  const ReliefScreen({super.key});

  void _openSession(BuildContext context, ReliefSession session) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BreathingWidget(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = const AudioCatalog();
    final sessions = catalog.getSessions();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F6E8),
        elevation: 0,
        foregroundColor: const Color(0xFF154314),
        title: const Text(
          'Relief',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: GridView.builder(
            itemCount: sessions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionTile(
                title: session.title,
                onTap: () => _openSession(context, session),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SessionTile({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDDEAD7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.spa, color: Color(0xFF2E7D32)),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E4D2B),
                fontSize: 15,
              ),
            ),
            const Spacer(),
            const Row(
              children: [
                Text(
                  'Start',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 18, color: Color(0xFF2E7D32)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}