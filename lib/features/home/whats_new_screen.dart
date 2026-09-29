import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';
import 'whats_new_content.dart';

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({
    super.key,
    required this.onContinue,
    required this.onEmergency,
    this.content = WhatsNewContent.current,
  });

  final Future<void> Function() onContinue;
  final VoidCallback onEmergency;
  final WhatsNewContent content;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                key: const Key('whats-new-scroll'),
                padding: const EdgeInsets.fromLTRB(
                  ReleafSpacing.screen,
                  ReleafSpacing.xl,
                  ReleafSpacing.screen,
                  ReleafSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      key: const Key('whats-new-emergency'),
                      onPressed: onEmergency,
                      icon: const Icon(Icons.emergency_outlined),
                      label: const Text('Emergency help'),
                    ),
                    const SizedBox(height: ReleafSpacing.md),
                    Text('RELEAF · 1.0', style: ReleafTypography.eyebrow),
                    const SizedBox(height: ReleafSpacing.md),
                    Semantics(
                      header: true,
                      child: Text(
                        content.heading,
                        style: ReleafTypography.display,
                      ),
                    ),
                    const SizedBox(height: ReleafSpacing.sm),
                    Text(content.introduction, style: ReleafTypography.body),
                    const SizedBox(height: ReleafSpacing.xl),
                    for (final item in content.items) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(ReleafSpacing.md),
                        decoration: BoxDecoration(
                          color: ReleafColors.surface,
                          borderRadius: BorderRadius.circular(
                            ReleafRadii.large,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                item.title,
                                style: ReleafTypography.cardTitle,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.xs),
                            Text(
                              item.description,
                              style: ReleafTypography.body,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ReleafSpacing.md),
                    ],
                    const SizedBox(height: ReleafSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('whats-new-continue'),
                        onPressed: () async => onContinue(),
                        child: const Text('Continue to Home'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
