import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../domain/models/reset_content.dart';
import '../domain/models/reset_launch_options.dart';

enum ResetSessionPreviewAction { start, unlock }

class ResetSessionPreviewResult {
  const ResetSessionPreviewResult({
    required this.action,
    required this.options,
  });

  final ResetSessionPreviewAction action;
  final ResetLaunchOptions options;
}

Future<ResetSessionPreviewResult?> showResetSessionPreview(
  BuildContext context, {
  required ResetContent session,
  required bool isLocked,
}) {
  return showModalBottomSheet<ResetSessionPreviewResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.68),
    builder: (_) => _ResetSessionPreviewSheet(
      session: session,
      isLocked: isLocked,
    ),
  );
}

class _ResetSessionPreviewSheet extends StatefulWidget {
  const _ResetSessionPreviewSheet({
    required this.session,
    required this.isLocked,
  });

  final ResetContent session;
  final bool isLocked;

  @override
  State<_ResetSessionPreviewSheet> createState() =>
      _ResetSessionPreviewSheetState();
}

class _ResetSessionPreviewSheetState
    extends State<_ResetSessionPreviewSheet> {
  var _options = const ResetLaunchOptions();

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final size = MediaQuery.sizeOf(context);
    final maxHeight = math.min(size.height * 0.90, 780.0);
    final compact = size.width < 360;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: maxHeight,
        ),
        child: Material(
          key: const Key('reset-session-preview-sheet'),
          color: ReleafColors.backgroundRaised,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ReleafRadii.extraLarge),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PreviewArtworkHeader(
                  session: session,
                  compact: compact,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? ReleafSpacing.md : ReleafSpacing.xl,
                    ReleafSpacing.lg,
                    compact ? ReleafSpacing.md : ReleafSpacing.xl,
                    ReleafSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PreviewMeta(session: session),
                      const SizedBox(height: ReleafSpacing.lg),
                      Text(
                        _sessionPurpose(session),
                        style: ReleafTypography.body.copyWith(
                          color: ReleafColors.textPrimary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.lg),
                      const Text(
                        'WHAT TO EXPECT',
                        style: ReleafTypography.eyebrow,
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      for (final instruction
                          in session.instructions.take(2)) ...[
                        _ExpectationRow(text: instruction),
                        const SizedBox(height: ReleafSpacing.xs),
                      ],
                      const SizedBox(height: ReleafSpacing.lg),
                      const Text(
                        'SESSION SETUP',
                        style: ReleafTypography.eyebrow,
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      _SessionPreferenceTile(
                        key: const Key('reset-preview-guidance-toggle'),
                        icon: Icons.subtitles_rounded,
                        title: 'Guidance text',
                        subtitle: 'Show the current step during the session.',
                        value: _options.showGuidanceText,
                        onChanged: (value) {
                          setState(() {
                            _options = _options.copyWith(
                              showGuidanceText: value,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: ReleafSpacing.xs),
                      _SessionPreferenceTile(
                        key: const Key('reset-preview-timer-toggle'),
                        icon: Icons.timer_outlined,
                        title: 'Session timer',
                        subtitle: 'Keep the countdown visible.',
                        value: _options.showSessionTimer,
                        onChanged: (value) {
                          setState(() {
                            _options = _options.copyWith(
                              showSessionTimer: value,
                            );
                          });
                        },
                      ),
                      if (session.audioAsset == null) ...[
                        const SizedBox(height: ReleafSpacing.sm),
                        Text(
                          'Voice guidance will be added with the guided-audio player. '
                          'This preview only shows controls that work today.',
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: ReleafSpacing.xl),
                      _PrimaryPreviewAction(
                        session: session,
                        isLocked: widget.isLocked,
                        onPressed: () {
                          Navigator.of(context).pop(
                            ResetSessionPreviewResult(
                              action: widget.isLocked
                                  ? ResetSessionPreviewAction.unlock
                                  : ResetSessionPreviewAction.start,
                              options: _options,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: ReleafSpacing.sm),
                      Center(
                        child: Text(
                          'You can stop at any time.',
                          style: ReleafTypography.meta.copyWith(
                            color: ReleafColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewArtworkHeader extends StatelessWidget {
  const _PreviewArtworkHeader({
    required this.session,
    required this.compact,
    required this.onClose,
  });

  final ResetContent session;
  final bool compact;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 250 : 285,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ReleafArtwork(variant: _sessionArtwork(session)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.03),
                  Colors.black.withValues(alpha: 0.14),
                  ReleafColors.backgroundRaised.withValues(alpha: 0.96),
                ],
                stops: const [0.12, 0.60, 1],
              ),
            ),
          ),
          Positioned(
            top: ReleafSpacing.sm,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: ReleafColors.textPrimary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(ReleafRadii.pill),
                ),
              ),
            ),
          ),
          Positioned(
            top: ReleafSpacing.md,
            right: ReleafSpacing.md,
            child: ReleafRoundIconButton(
              key: const Key('reset-preview-close'),
              icon: Icons.close_rounded,
              tooltip: 'Close session preview',
              onPressed: onClose,
            ),
          ),
          Positioned(
            left: compact ? ReleafSpacing.md : ReleafSpacing.xl,
            right: compact ? ReleafSpacing.md : ReleafSpacing.xl,
            bottom: ReleafSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session.isPremium)
                  const Padding(
                    padding: EdgeInsets.only(bottom: ReleafSpacing.sm),
                    child: ReleafPremiumBadge(),
                  ),
                Text(
                  session.title,
                  style: ReleafTypography.display.copyWith(
                    fontSize: compact ? 28 : 34,
                  ),
                ),
                const SizedBox(height: ReleafSpacing.xs),
                Text(
                  _previewSubtitle(session),
                  style: ReleafTypography.body.copyWith(
                    color: ReleafColors.textPrimary.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewMeta extends StatelessWidget {
  const _PreviewMeta({required this.session});

  final ResetContent session;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ReleafSpacing.xs,
      runSpacing: ReleafSpacing.xs,
      children: [
        _MetaPill(
          icon: Icons.schedule_rounded,
          label: _durationLabel(session.durationSeconds),
        ),
        _MetaPill(
          icon: _modalityIcon(session.modality),
          label: _sessionTypeLabel(session),
        ),
        _MetaPill(
          icon: session.isPremium
              ? Icons.lock_outline_rounded
              : Icons.check_circle_outline_rounded,
          label: session.isPremium ? 'Premium' : 'Free',
          warm: session.isPremium,
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    this.warm = false,
  });

  final IconData icon;
  final String label;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    final accent = warm ? ReleafColors.premium : ReleafColors.sage;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textPrimary.withValues(alpha: 0.84),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpectationRow extends StatelessWidget {
  const _ExpectationRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: ReleafColors.sage,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: ReleafSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: ReleafTypography.body.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionPreferenceTile extends StatelessWidget {
  const _SessionPreferenceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: '$title. $subtitle',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ReleafColors.surfaceSoft,
          borderRadius: BorderRadius.circular(ReleafRadii.large),
          border: Border.all(color: ReleafColors.borderSoft),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReleafSpacing.md,
            vertical: ReleafSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: ReleafColors.sage.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19, color: ReleafColors.sage),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ReleafTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Switch.adaptive(
                value: value,
                activeTrackColor: ReleafColors.sage,
                activeThumbColor: ReleafColors.background,
                inactiveTrackColor: ReleafColors.surfaceElevated,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryPreviewAction extends StatelessWidget {
  const _PrimaryPreviewAction({
    required this.session,
    required this.isLocked,
    required this.onPressed,
  });

  final ResetContent session;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final warm = isLocked || session.isPremium;
    final background = warm ? ReleafColors.premium : ReleafColors.sage;
    final label = isLocked ? 'Unlock Premium' : 'Start reset';
    final icon = isLocked
        ? Icons.lock_open_rounded
        : Icons.play_arrow_rounded;

    return SizedBox(
      width: double.infinity,
      height: ReleafControlSizes.prominent,
      child: FilledButton.icon(
        key: Key(
          isLocked ? 'reset-preview-unlock' : 'reset-preview-start',
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: ReleafColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReleafRadii.pill),
          ),
        ),
      ),
    );
  }
}

String _durationLabel(int durationSeconds) {
  if (durationSeconds < 120) return '$durationSeconds sec';
  if (durationSeconds % 60 == 0) return '${durationSeconds ~/ 60} min';
  final minutes = durationSeconds ~/ 60;
  final seconds = durationSeconds % 60;
  return '$minutes min $seconds sec';
}

String _previewSubtitle(ResetContent session) {
  return switch (session.id) {
    '60s-grounding' => 'A quick sensory reset for the present moment.',
    '90s-calm-down' => 'A short breathing practice to slow the pace.',
    '5min-focus' => 'A focused sensory anchor for scattered attention.',
    '3min-breath' => 'The current focused Deep Reset breathing protocol.',
    _ => session.summary ?? 'A guided reset for the present moment.',
  };
}

String _sessionPurpose(ResetContent session) {
  return switch (session.id) {
    '60s-grounding' => 'Return attention to your body and immediate surroundings.',
    '90s-calm-down' => 'Slow the pace and soften tension with a brief breathing sequence.',
    '5min-focus' => 'Anchor attention through your senses and one clear point of focus.',
    '3min-breath' => 'Use a steady breathing pattern to create a longer, more focused reset.',
    _ => session.summary ?? 'A guided reset for the present moment.',
  };
}

String _sessionTypeLabel(ResetContent session) {
  if (session.level == ResetLevel.deep) return 'Deep Reset';
  return switch (session.modality) {
    ResetModality.breathing => 'Breathing',
    ResetModality.grounding => 'Grounding',
    ResetModality.guidedPractice => 'Guided',
  };
}

IconData _modalityIcon(ResetModality modality) {
  return switch (modality) {
    ResetModality.breathing => Icons.air_rounded,
    ResetModality.grounding => Icons.spa_outlined,
    ResetModality.guidedPractice => Icons.self_improvement_rounded,
  };
}

ReleafArtworkVariant _sessionArtwork(ResetContent session) {
  return switch (session.id) {
    '60s-grounding' => ReleafArtworkVariant.grounding,
    '90s-calm-down' => ReleafArtworkVariant.calm,
    '5min-focus' => ReleafArtworkVariant.focus,
    '3min-breath' => ReleafArtworkVariant.deepReset,
    _ => ReleafArtworkVariant.ambient,
  };
}
