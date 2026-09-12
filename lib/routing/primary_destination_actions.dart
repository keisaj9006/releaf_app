import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/relief/data/reset_catalog.dart';
import '../theme/releaf_design_tokens.dart';
import '../theme/widgets/releaf_components.dart';
import 'app_routes.dart';

/// Immediate account and free Emergency access from the audio destinations.
class PrimaryDestinationActions extends StatelessWidget {
  const PrimaryDestinationActions({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      ReleafRoundIconButton(
        icon: Icons.favorite_outline_rounded,
        tooltip: 'Open Emergency Calm',
        accentColor: ReleafFeatureAccents.emergency,
        onPressed: () => context.push(
          AppRoutes.reliefSessionFor(ResetCatalog.emergencySessionId),
        ),
      ),
      const SizedBox(width: ReleafSpacing.sm),
      ReleafRoundIconButton(
        icon: Icons.person_outline_rounded,
        tooltip: 'Account and Premium',
        onPressed: () => context.push(AppRoutes.account),
      ),
    ],
  );
}
