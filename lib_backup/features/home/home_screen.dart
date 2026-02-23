// FILE: lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// IMPORTANT:
// HomeScreen jest w: lib/features/home/home_screen.dart
// więc ../progress/... wskazuje na: lib/features/progress/...
import '../progress/data/leaves_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const int _goalLeaves = 50; // MVP: stały cel (później ustawienia profilu)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leavesState = ref.watch(leavesNotifierProvider);

    final total = leavesState.totalLeaves;
    final progress = (_goalLeaves <= 0) ? 0.0 : (total / _goalLeaves).clamp(0.0, 1.0);

    final todayDoneCount = [
      leavesState.habitDone,
      leavesState.reliefDone,
      leavesState.brainDone,
    ].where((x) => x).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF154314),
        foregroundColor: const Color(0xFFFCF6DB),
        title: const Text(
          'Bring Releaf to your life.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GreetingCard(),
                      const SizedBox(height: 14),

                      _ProgressCard(
                        totalLeaves: total,
                        goalLeaves: _goalLeaves,
                        progress: progress,
                        todayDoneCount: todayDoneCount,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Today',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E4D2B),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 10),

                      _StatusRow(
                        label: 'Habits',
                        done: leavesState.habitDone,
                        onTap: () => context.go('/habits'),
                      ),
                      const SizedBox(height: 10),
                      _StatusRow(
                        label: 'Relief',
                        done: leavesState.reliefDone,
                        onTap: () => context.go('/relief'),
                      ),
                      const SizedBox(height: 10),
                      _StatusRow(
                        label: 'Brain',
                        done: leavesState.brainDone,
                        onTap: () => context.go('/brain'),
                      ),

                      const Spacer(),

                      FilledButton(
                        onPressed: () => _startDailyLoop(context, ref),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Start Daily Loop',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startDailyLoop(BuildContext context, WidgetRef ref) {
    final state = ref.read(leavesNotifierProvider);

    if (!state.reliefDone) {
      context.go('/relief');
      return;
    }
    if (!state.habitDone) {
      context.go('/habits');
      return;
    }
    if (!state.brainDone) {
      context.go('/brain');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Day Complete'),
        content: const Text('You have completed all activities for today!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, Joanna! 👋',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E4D2B),
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Small steps. Real progress.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4E6B57),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int totalLeaves;
  final int goalLeaves;
  final double progress;
  final int todayDoneCount;

  const _ProgressCard({
    required this.totalLeaves,
    required this.goalLeaves,
    required this.progress,
    required this.todayDoneCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leaves: $totalLeaves / $goalLeaves',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E4D2B),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFDDEAD7),
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Today status: $todayDoneCount / 3',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4E6B57),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool done;
  final VoidCallback onTap;

  const _StatusRow({
    required this.label,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = done ? Icons.check_circle : Icons.radio_button_unchecked;
    final color = done ? const Color(0xFF2E7D32) : const Color(0xFF7A8E80);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDEAD7)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E4D2B),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF1E4D2B)),
          ],
        ),
      ),
    );
  }
}