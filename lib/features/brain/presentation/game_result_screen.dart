// FILE: lib/features/brain/presentation/game_result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../progress/data/leaves_repository.dart';
import '../../../routing/app_routes.dart';

/// Spójny ekran końca gry:
/// - pokazuje score (lokalny wynik gry)
/// - przyznaje dzienny bonus Brain tylko raz (przez LeavesNotifier)
/// - daje jasne wyjście z flow
class GameResultScreen extends ConsumerStatefulWidget {
  final int? score;
  const GameResultScreen({super.key, this.score});

  @override
  ConsumerState<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends ConsumerState<GameResultScreen> {
  bool _awardHandled = false;
  String? _rewardMessage;

  @override
  void initState() {
    super.initState();

    // Robimy to po pierwszym buildzie, ale tylko raz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _awardBrainIfNeeded();
    });
  }

  Future<void> _awardBrainIfNeeded() async {
    if (_awardHandled || !mounted) return;
    _awardHandled = true;

    final leavesNotifier = ref.read(leavesNotifierProvider.notifier);

    // ✅ Repo decyduje, czy dać nagrodę (raz dziennie + bonus 3/3)
    final result = await leavesNotifier.markBrainDone();

    if (!mounted || result == null) return;

    HapticFeedback.lightImpact();

    final msg = result.hasBonus
        ? '+${result.totalAdded} leaves • Perfect day bonus!'
        : '+${result.totalAdded} leaves';

    setState(() {
      _rewardMessage = msg;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.brain),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),

              if (widget.score != null) ...[
                Text(
                  'Score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.score}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (_rewardMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _rewardMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.brain),
                  child: const Text('Back to Brain'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.dailyLoop),
                  child: const Text('Continue Daily Loop'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}