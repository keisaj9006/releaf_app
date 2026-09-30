import 'package:flutter/material.dart';

import '../../../theme/releaf_design_tokens.dart';
import '../domain/models/reset_content.dart';

String resetDiscoveryLabel(ResetDiscoveryGroup group) => switch (group) {
  ResetDiscoveryGroup.breathingMethods => 'Breathing methods',
  ResetDiscoveryGroup.situationalCalm => 'Calm for a situation',
  ResetDiscoveryGroup.bodyMindReset => 'Body & mind reset',
};

String resetDiscoveryDescription(ResetDiscoveryGroup group) => switch (group) {
  ResetDiscoveryGroup.breathingMethods =>
    'Choose a paced method with its own timing.',
  ResetDiscoveryGroup.situationalCalm =>
    'A short practice for a moment you can name.',
  ResetDiscoveryGroup.bodyMindReset =>
    'Ground, move or release without a breathing drill.',
};

class ResetDiscoverySelector extends StatelessWidget {
  const ResetDiscoverySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final ResetDiscoveryGroup selected;
  final ValueChanged<ResetDiscoveryGroup> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 600
            ? (constraints.maxWidth - 2 * ReleafSpacing.sm) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: ReleafSpacing.sm,
          runSpacing: ReleafSpacing.sm,
          children: [
            for (final group in ResetDiscoveryGroup.values)
              SizedBox(
                width: width,
                child: Semantics(
                  button: true,
                  selected: selected == group,
                  label:
                      '${resetDiscoveryLabel(group)}. ${resetDiscoveryDescription(group)}',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: Key('reset-group-${group.name}'),
                      onTap: () => onChanged(group),
                      borderRadius: BorderRadius.circular(ReleafRadii.large),
                      child: Ink(
                        padding: const EdgeInsets.all(ReleafSpacing.md),
                        decoration: BoxDecoration(
                          color: selected == group
                              ? ReleafColors.surface
                              : ReleafColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(
                            ReleafRadii.large,
                          ),
                          border: Border.all(
                            color: selected == group
                                ? ReleafColors.sage
                                : ReleafColors.borderSoft,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                resetDiscoveryLabel(group),
                                style: ReleafTypography.cardTitle,
                              ),
                            ),
                            const SizedBox(width: ReleafSpacing.sm),
                            Icon(
                              selected == group
                                  ? Icons.check_circle_rounded
                                  : Icons.chevron_right_rounded,
                              color: selected == group
                                  ? ReleafColors.sage
                                  : ReleafColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
