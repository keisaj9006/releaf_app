import 'package:flutter/material.dart';

import '../../features/brain/presentation/brain_screen.dart';

/// Legacy compatibility entry point.
///
/// The product has one canonical Brain hub. Keeping this class prevents old
/// routes/imports from breaking while ensuring they cannot surface the retired
/// Laser/Reactivator placeholder grid.
@Deprecated('Use BrainScreen from features/brain/presentation instead.')
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) => const BrainScreen();
}
