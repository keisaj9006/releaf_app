import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/brain/presentation/widgets/brain_difficulty_selector.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

class TrailSwitchScreen extends StatefulWidget {
  const TrailSwitchScreen({
    super.key,
    required this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?> onFinish;
  final int trainingLevel;

  @override
  State<TrailSwitchScreen> createState() => _TrailSwitchScreenState();
}

class _TrailSwitchScreenState extends State<TrailSwitchScreen> {
  static const _accent = Color(0xFFF1BC73);
  static const _distractorLabels = <String>[
    '◇',
    '○',
    '△',
    '＋',
    '✦',
    '□',
    '⌁',
    '×',
  ];

  BrainDifficulty _difficulty = BrainDifficulty.medium;
  late List<_TrailNode> _nodes;
  late List<String> _targets;

  int _nextOrder = 0;
  int _mistakes = 0;
  bool _started = false;
  bool _finished = false;
  String _feedback = 'Follow the sequence as quickly and accurately as you can.';

  int get _trainingLevel => widget.trainingLevel.clamp(1, 12).toInt();
  int get _levelIndex => _trainingLevel - 1;

  int get _targetCount {
    final base = switch (_difficulty) {
      BrainDifficulty.easy => 6,
      BrainDifficulty.medium => 8,
      BrainDifficulty.hard => 10,
    };
    return (base + (_levelIndex ~/ 2)).clamp(6, 16).toInt();
  }

  int get _distractorCount {
    if (_difficulty != BrainDifficulty.hard) return 0;
    return (3 + (_levelIndex ~/ 3)).clamp(3, 6).toInt();
  }

  int get _gridSide {
    final total = _targetCount + _distractorCount;
    if (total <= 9) return 3;
    if (total <= 16) return 4;
    return 5;
  }

  int get _difficultyMultiplier => switch (_difficulty) {
        BrainDifficulty.easy => 1,
        BrainDifficulty.medium => 2,
        BrainDifficulty.hard => 3,
      };

  bool get _canChangeDifficulty => !_started && !_finished;

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  void _changeDifficulty(BrainDifficulty difficulty) {
    if (!_canChangeDifficulty) return;
    setState(() {
      _difficulty = difficulty;
      _nextOrder = 0;
      _mistakes = 0;
      _feedback = _instructionFor(difficulty);
      _resetBoard();
    });
  }

  String _instructionFor(BrainDifficulty difficulty) {
    return switch (difficulty) {
      BrainDifficulty.easy => 'Tap the numbers in ascending order.',
      BrainDifficulty.medium =>
        'Alternate number and letter: 1 → A → 2 → B → …',
      BrainDifficulty.hard =>
        'Alternate number and letter while ignoring the distractor symbols.',
    };
  }

  void _resetBoard() {
    _targets = _buildTargets();
    final nodes = <_TrailNode>[
      for (var order = 0; order < _targets.length; order++)
        _TrailNode(
          id: 'target-$order',
          label: _targets[order],
          order: order,
        ),
      for (var index = 0; index < _distractorCount; index++)
        _TrailNode(
          id: 'distractor-$index',
          label: _distractorLabels[index % _distractorLabels.length],
        ),
    ];

    nodes.shuffle(
      math.Random(
        3011 +
            (_trainingLevel * 1487) +
            (_difficulty.index * 4999),
      ),
    );
    _nodes = nodes;
  }

  List<String> _buildTargets() {
    if (_difficulty == BrainDifficulty.easy) {
      return List<String>.generate(
        _targetCount,
        (index) => '${index + 1}',
      );
    }

    final result = <String>[];
    var number = 1;
    var letter = 0;

    while (result.length < _targetCount) {
      result.add('$number');
      if (result.length >= _targetCount) break;
      result.add(String.fromCharCode('A'.codeUnitAt(0) + letter));
      number++;
      letter++;
    }

    return result;
  }

  void _tapNode(_TrailNode node) {
    if (_finished) return;
    _started = true;

    if (node.order == _nextOrder) {
      _nextOrder++;
      HapticFeedback.selectionClick();

      if (_nextOrder >= _targets.length) {
        _finished = true;
        HapticFeedback.mediumImpact();
        setState(() {
          _feedback = 'Trail complete.';
        });
        _completeSession();
        return;
      }

      setState(() {
        _feedback = 'Good. Next: ${_targets[_nextOrder]}';
      });
      return;
    }

    _mistakes++;
    HapticFeedback.lightImpact();
    setState(() {
      _feedback = node.order == null
          ? 'Ignore distractors. Next: ${_targets[_nextOrder]}'
          : 'Not yet. Next: ${_targets[_nextOrder]}';
    });
  }

  void _completeSession() {
    final score = math
        .max(
          0,
          (_targets.length * 18 * _difficultyMultiplier) +
              (_trainingLevel * 8) -
              (_mistakes * 12),
        )
        .toInt();
    widget.onFinish(score);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _targets.isEmpty ? 0.0 : _nextOrder / _targets.length;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          toolbarHeight: 72,
          backgroundColor: const Color(0xEB17120A),
          surfaceTintColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VISUAL SEARCH & SWITCHING',
                style: ReleafTypography.eyebrow.copyWith(
                  color: _accent,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Trail Switch',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  'L$_trainingLevel',
                  key: const Key('trail-switch-training-level'),
                  style: ReleafTypography.meta.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Exit Trail Switch',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF211A0F),
                      ReleafColors.background,
                      Color(0xFF080705),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 700;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      ReleafSpacing.screen,
                      compact ? ReleafSpacing.sm : ReleafSpacing.md,
                      ReleafSpacing.screen,
                      ReleafSpacing.xl,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BrainDifficultySelector(
                              value: _difficulty,
                              enabled: _canChangeDifficulty,
                              accent: _accent,
                              onChanged: _changeDifficulty,
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Wrap(
                              spacing: ReleafSpacing.xs,
                              runSpacing: ReleafSpacing.xs,
                              children: [
                                _TrailStat(
                                  label: 'NEXT',
                                  value: _finished
                                      ? 'DONE'
                                      : _targets[_nextOrder],
                                ),
                                _TrailStat(
                                  label: 'STEPS',
                                  value: '$_nextOrder/${_targets.length}',
                                ),
                                _TrailStat(
                                  label: 'ERRORS',
                                  value: '$_mistakes',
                                ),
                              ],
                            ),
                            const SizedBox(height: ReleafSpacing.sm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                ReleafRadii.pill,
                              ),
                              child: LinearProgressIndicator(
                                key: const Key('trail-switch-progress'),
                                value: progress,
                                minHeight: 6,
                                backgroundColor:
                                    _accent.withValues(alpha: 0.10),
                                valueColor:
                                    const AlwaysStoppedAnimation(_accent),
                              ),
                            ),
                            SizedBox(
                              height: compact
                                  ? ReleafSpacing.md
                                  : ReleafSpacing.xl,
                            ),
                            Container(
                              key: const Key('trail-switch-board'),
                              padding: EdgeInsets.all(
                                compact ? ReleafSpacing.md : ReleafSpacing.lg,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xF0252016),
                                    Color(0xF00F1210),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  ReleafRadii.extraLarge,
                                ),
                                border: Border.all(
                                  color: _accent.withValues(alpha: 0.24),
                                ),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: GridView.builder(
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: _nodes.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _gridSide,
                                    crossAxisSpacing:
                                        compact ? 8 : ReleafSpacing.sm,
                                    mainAxisSpacing:
                                        compact ? 8 : ReleafSpacing.sm,
                                  ),
                                  itemBuilder: (context, index) {
                                    final node = _nodes[index];
                                    final completed = node.order != null &&
                                        node.order! < _nextOrder;
                                    final distractor = node.order == null;

                                    return Semantics(
                                      button: true,
                                      label: distractor
                                          ? 'Distractor ${node.label}'
                                          : 'Trail item ${node.label}',
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          ReleafRadii.medium,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          key: Key(
                                            'trail-switch-${node.id}',
                                          ),
                                          onTap: _finished
                                              ? null
                                              : () => _tapNode(node),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              color: completed
                                                  ? _accent.withValues(
                                                      alpha: 0.14,
                                                    )
                                                  : distractor
                                                      ? const Color(
                                                          0xFF171713,
                                                        )
                                                      : const Color(
                                                          0xFF242017,
                                                        ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                ReleafRadii.medium,
                                              ),
                                              border: Border.all(
                                                color: completed
                                                    ? _accent.withValues(
                                                        alpha: 0.42,
                                                      )
                                                    : distractor
                                                        ? ReleafColors
                                                            .borderSoft
                                                        : _accent.withValues(
                                                            alpha: 0.20,
                                                          ),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                node.label,
                                                style: ReleafTypography
                                                    .sectionTitle
                                                    .copyWith(
                                                  fontSize: compact ? 18 : 22,
                                                  color: completed
                                                      ? _accent.withValues(
                                                          alpha: 0.55,
                                                        )
                                                      : distractor
                                                          ? ReleafColors
                                                              .textMuted
                                                          : ReleafColors
                                                              .textPrimary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              _feedback,
                              key: const Key('trail-switch-feedback'),
                              textAlign: TextAlign.center,
                              style: ReleafTypography.body.copyWith(
                                color: ReleafColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.md),
                            Text(
                              _instructionFor(_difficulty),
                              textAlign: TextAlign.center,
                              style: ReleafTypography.meta.copyWith(
                                color: _accent,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.sm),
                            Text(
                              'Trail Switch practises visual scanning and ordered attention. The score reflects this task only and is not a clinical or intelligence measure.',
                              textAlign: TextAlign.center,
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textMuted,
                                fontSize: 10,
                                height: 1.45,
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
          ],
        ),
      ),
    );
  }
}

class _TrailNode {
  const _TrailNode({
    required this.id,
    required this.label,
    this.order,
  });

  final String id;
  final String label;
  final int? order;
}

class _TrailStat extends StatelessWidget {
  const _TrailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xD91A1710),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: _TrailSwitchScreenState._accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textMuted,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
