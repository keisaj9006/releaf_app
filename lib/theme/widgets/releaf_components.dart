import 'package:flutter/material.dart';

import '../releaf_design_tokens.dart';

class ReleafSectionHeading extends StatelessWidget {
  const ReleafSectionHeading({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: ReleafTypography.eyebrow),
        const SizedBox(height: ReleafSpacing.xs),
        Text(description, style: ReleafTypography.body),
      ],
    );
  }
}

class ReleafPremiumBadge extends StatelessWidget {
  const ReleafPremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Premium content',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ReleafColors.premiumSoft,
          borderRadius: BorderRadius.circular(ReleafRadii.pill),
          border: Border.all(
            color: ReleafColors.premium.withValues(alpha: 0.34),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: ReleafColors.premium,
              ),
              SizedBox(width: 5),
              Text(
                'Premium',
                style: TextStyle(
                  color: ReleafColors.premium,
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReleafRoundIconButton extends StatelessWidget {
  const ReleafRoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isWarm = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isWarm;

  @override
  Widget build(BuildContext context) {
    final accent = isWarm ? ReleafColors.premium : ReleafColors.sage;

    return Semantics(
      button: true,
      label: tooltip,
      child: Container(
        width: ReleafControlSizes.standard,
        height: ReleafControlSizes.standard,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.09),
          shape: BoxShape.circle,
          border: Border.all(color: accent.withValues(alpha: 0.30)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: 20, color: accent),
        ),
      ),
    );
  }
}

class ReleafPressableCard extends StatefulWidget {
  const ReleafPressableCard({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.all(ReleafSpacing.md),
    this.warmAccent = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final bool warmAccent;

  @override
  State<ReleafPressableCard> createState() => _ReleafPressableCardState();
}

class _ReleafPressableCardState extends State<ReleafPressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.warmAccent
        ? ReleafColors.premium
        : ReleafColors.sage;

    return AnimatedScale(
      scale: _pressed ? 0.992 : 1,
      duration: ReleafMotion.quick,
      curve: ReleafMotion.emphasisCurve,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ReleafColors.surface,
          borderRadius: BorderRadius.circular(ReleafRadii.large),
          border: Border.all(
            color: widget.warmAccent
                ? accent.withValues(alpha: 0.25)
                : ReleafColors.borderSoft,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(
                alpha: widget.warmAccent ? 0.055 : 0.035,
              ),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(ReleafRadii.large),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: widget.onPressed == null
                ? null
                : (value) => setState(() => _pressed = value),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
