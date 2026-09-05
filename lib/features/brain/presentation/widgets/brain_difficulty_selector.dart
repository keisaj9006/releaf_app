import 'package:flutter/material.dart';

import '../../../../theme/releaf_design_tokens.dart';

enum BrainDifficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        BrainDifficulty.easy => 'Easy',
        BrainDifficulty.medium => 'Medium',
        BrainDifficulty.hard => 'Hard',
      };
}

class BrainDifficultySelector extends StatelessWidget {
  const BrainDifficultySelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.accent,
    this.enabled = true,
  });

  final BrainDifficulty value;
  final ValueChanged<BrainDifficulty> onChanged;
  final Color accent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Difficulty. ${value.label} selected.',
      child: Container(
        key: const Key('brain-difficulty-selector'),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xD9111620),
          borderRadius: BorderRadius.circular(ReleafRadii.pill),
          border: Border.all(
            color: accent.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            for (final difficulty in BrainDifficulty.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _DifficultyButton(
                    difficulty: difficulty,
                    selected: value == difficulty,
                    enabled: enabled,
                    accent: accent,
                    onPressed: () => onChanged(difficulty),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.difficulty,
    required this.selected,
    required this.enabled,
    required this.accent,
    required this.onPressed,
  });

  final BrainDifficulty difficulty;
  final bool selected;
  final bool enabled;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '${difficulty.label} difficulty',
      child: SizedBox(
        height: 38,
        child: FilledButton(
          key: Key('brain-difficulty-${difficulty.name}'),
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            elevation: 0,
            backgroundColor: selected
                ? accent.withValues(alpha: 0.18)
                : Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: selected
                ? ReleafColors.textPrimary
                : ReleafColors.textSecondary,
            disabledForegroundColor: ReleafColors.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ReleafRadii.pill),
              side: BorderSide(
                color: selected
                    ? accent.withValues(alpha: 0.38)
                    : Colors.transparent,
              ),
            ),
          ),
          child: Text(
            difficulty.label,
            style: ReleafTypography.meta.copyWith(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
