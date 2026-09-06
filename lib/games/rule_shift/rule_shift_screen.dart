import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../routing/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import '../../theme/widgets/releaf_brain_artwork.dart';

class RuleShiftScreen extends StatefulWidget {
  const RuleShiftScreen({
    super.key,
    this.onFinish,
    this.trainingLevel = 1,
  });

  final ValueChanged<int?>? onFinish;
  final int trainingLevel;

  @override
  State<RuleShiftScreen> createState() => _RuleShiftScreenState();
}

class _RuleShiftScreenState extends State<RuleShiftScreen> {
  static const _trials = <_RuleShiftTrial>[
    _RuleShiftTrial(rule: _Rule.odd, value: 3, expected: true),
    _RuleShiftTrial(rule: _Rule.high, value: 4, expected: false),
    _RuleShiftTrial(rule: _Rule.odd, value: 8, expected: false),
    _RuleShiftTrial(rule: _Rule.high, value: 9, expected: true),
    _RuleShiftTrial(rule: _Rule.odd, value: 5, expected: true),
    _RuleShiftTrial(rule: _Rule.high, value: 2, expected: false),
    _RuleShiftTrial(rule: _Rule.odd, value: 6, expected: false),
    _RuleShiftTrial(rule: _Rule.high, value: 7, expected: true),
    _RuleShiftTrial(rule: _Rule.odd, value: 1, expected: true),
    _RuleShiftTrial(rule: _Rule.high, value: 5, expected: false),
    _RuleShiftTrial(rule: _Rule.odd, value: 4, expected: false),
    _RuleShiftTrial(rule: _Rule.high, value: 8, expected: true),
    _RuleShiftTrial(rule: _Rule.multipleOfThree, value: 6, expected: true),
    _RuleShiftTrial(rule: _Rule.multipleOfThree, value: 8, expected: false),
    _RuleShiftTrial(rule: _Rule.inRange, value: 5, expected: true),
    _RuleShiftTrial(rule: _Rule.inRange, value: 9, expected: false),
    _RuleShiftTrial(rule: _Rule.multipleOfThree, value: 9, expected: true),
    _RuleShiftTrial(rule: _Rule.inRange, value: 3, expected: true),
    _RuleShiftTrial(rule: _Rule.multipleOfThree, value: 4, expected: false),
    _RuleShiftTrial(rule: _Rule.inRange, value: 7, expected: true),
    _RuleShiftTrial(rule: _Rule.multipleOfThree, value: 3, expected: true),
    _RuleShiftTrial(rule: _Rule.inRange, value: 2, expected: false),
    _RuleShiftTrial(rule: _Rule.multipleOfThree, value: 7, expected: false),
  ];

  int _index = 0;
  int _score = 0;
  bool _locked = false;
  bool? _lastCorrect;

  int get _levelIndex => (widget.trainingLevel - 1).clamp(0, 11).toInt();
  int get _trialCount => 12 + _levelIndex;

  _RuleShiftTrial get _trial => _trials[_index];

  Future<void> _answer(bool answer) async {
    if (_locked) return;

    final correct = answer == _trial.expected;
    HapticFeedback.selectionClick();

    setState(() {
      _locked = true;
      _lastCorrect = correct;
      if (correct) _score += 100;
    });

    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;

    if (_index == _trialCount - 1) {
      widget.onFinish?.call(_score);
      return;
    }

    setState(() {
      _index += 1;
      _locked = false;
      _lastCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / _trialCount;

    return Theme(
      data: AppTheme.premiumDark(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ReleafBrainArtwork(
            variant: ReleafBrainArtworkVariant.ruleShift,
            intensity: 0.56,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xA9070B12),
                  Color(0xEA090D14),
                  ReleafColors.background,
                ],
                stops: [0, 0.50, 1],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 680;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  ReleafSpacing.screen,
                  compact ? ReleafSpacing.sm : ReleafSpacing.lg,
                  ReleafSpacing.screen,
                  ReleafSpacing.xl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Exit Rule Shift',
                              onPressed: () => context.go(AppRoutes.brain),
                              icon: const Icon(Icons.close_rounded),
                            ),
                            const SizedBox(width: ReleafSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ATTENTION · RULE SHIFT',
                                    style: ReleafTypography.eyebrow.copyWith(
                                      color: const Color(0xFFB59AF4),
                                      letterSpacing: 1.7,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Use the current rule. It changes every round.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: ReleafTypography.meta.copyWith(
                                      color: ReleafColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: compact
                              ? ReleafSpacing.lg
                              : ReleafSpacing.xxl,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            ReleafRadii.pill,
                          ),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: const Color(0xFF242A3B),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFB59AF4),
                            ),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.sm),
                        Text(
                          'LEVEL ${widget.trainingLevel} · ROUND ${_index + 1} OF $_trialCount',
                          textAlign: TextAlign.right,
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: compact
                              ? ReleafSpacing.lg
                              : ReleafSpacing.xxl,
                        ),
                        Semantics(
                          container: true,
                          label:
                              '${_trial.rule.semanticLabel}. Number ${_trial.value}.',
                          child: Container(
                            key: const Key('rule-shift-prompt'),
                            padding: EdgeInsets.symmetric(
                              horizontal: ReleafSpacing.xl,
                              vertical: compact ? 28 : 46,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xEA111623),
                              borderRadius: BorderRadius.circular(
                                ReleafRadii.extraLarge,
                              ),
                              border: Border.all(
                                color: const Color(0xFFB59AF4)
                                    .withValues(alpha: 0.24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8F72D8)
                                      .withValues(alpha: 0.12),
                                  blurRadius: 34,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _trial.rule.label,
                                  textAlign: TextAlign.center,
                                  style: ReleafTypography.eyebrow.copyWith(
                                    color: const Color(0xFFB59AF4),
                                  ),
                                ),
                                SizedBox(
                                  height: compact
                                      ? ReleafSpacing.md
                                      : ReleafSpacing.xl,
                                ),
                                Text(
                                  '${_trial.value}',
                                  textAlign: TextAlign.center,
                                  style: ReleafTypography.display.copyWith(
                                    fontSize: compact ? 72 : 92,
                                    height: 1,
                                    color: const Color(0xFFF1EEFF),
                                  ),
                                ),
                                const SizedBox(height: ReleafSpacing.lg),
                                AnimatedSwitcher(
                                  duration: ReleafMotion.quick,
                                  child: _lastCorrect == null
                                      ? Text(
                                          'Answer the rule, not the previous round.',
                                          key: const ValueKey('rule-hint'),
                                          textAlign: TextAlign.center,
                                          style: ReleafTypography.meta.copyWith(
                                            color: ReleafColors.textSecondary,
                                          ),
                                        )
                                      : Text(
                                          _lastCorrect!
                                              ? 'Correct'
                                              : 'Not this time',
                                          key: ValueKey(_lastCorrect),
                                          textAlign: TextAlign.center,
                                          style: ReleafTypography.cardTitle
                                              .copyWith(
                                            color: _lastCorrect!
                                                ? const Color(0xFF80CDB7)
                                                : const Color(0xFFE1A184),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: ReleafSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: OutlinedButton(
                                  key: const Key('rule-shift-no'),
                                  onPressed:
                                      _locked ? null : () => _answer(false),
                                  child: const Text('NO'),
                                ),
                              ),
                            ),
                            const SizedBox(width: ReleafSpacing.sm),
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: FilledButton(
                                  key: const Key('rule-shift-yes'),
                                  onPressed:
                                      _locked ? null : () => _answer(true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFD8D0FF),
                                    foregroundColor:
                                        const Color(0xFF161224),
                                  ),
                                  child: const Text('YES'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: ReleafSpacing.md),
                        Text(
                          'Score reflects performance in this exercise only.',
                          textAlign: TextAlign.center,
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _Rule {
  odd(
    label: 'IS THE NUMBER ODD?',
    semanticLabel: 'Rule: is the number odd',
  ),
  high(
    label: 'IS IT GREATER THAN 5?',
    semanticLabel: 'Rule: is the number greater than five',
  ),
  multipleOfThree(
    label: 'IS IT A MULTIPLE OF 3?',
    semanticLabel: 'Rule: is the number a multiple of three',
  ),
  inRange(
    label: 'IS IT BETWEEN 3 AND 7?',
    semanticLabel: 'Rule: is the number between three and seven inclusive',
  );

  const _Rule({
    required this.label,
    required this.semanticLabel,
  });

  final String label;
  final String semanticLabel;
}

class _RuleShiftTrial {
  const _RuleShiftTrial({
    required this.rule,
    required this.value,
    required this.expected,
  });

  final _Rule rule;
  final int value;
  final bool expected;
}
