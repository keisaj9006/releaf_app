import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/session/session_manager.dart';
import '../features/relief/data/reset_catalog.dart';
import '../theme/releaf_design_tokens.dart';
import 'app_routes.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),

          if (session.hasActive && navigationShell.currentIndex != 0)
            Positioned(
              left: 12,
              right: 12,
              bottom: 80,
              child: _ResumePill(
                title: session.title,
                subtitle: session.subtitle,
                onResume: () {
                  context.push(session.resumeRoute, extra: session.extra);
                },
                onDismiss: () {
                  ref.read(sessionManagerProvider.notifier).clear();
                },
              ),
            ),
        ],
      ),
      floatingActionButton: navigationShell.currentIndex == 1
          ? null
          : FloatingActionButton.small(
              tooltip: 'Open Emergency Grounding',
              backgroundColor: ReleafColors.premiumSoft,
              foregroundColor: ReleafColors.premium,
              shape: CircleBorder(
                side: BorderSide(
                  color: ReleafColors.premium.withValues(alpha: 0.38),
                ),
              ),
              onPressed: () {
                context.push(
                  AppRoutes.reliefSessionFor(ResetCatalog.emergencySessionId),
                );
              },
              child: const Icon(Icons.health_and_safety_outlined),
            ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            height: 82,
            backgroundColor: ReleafColors.backgroundRaised,
            indicatorColor: ReleafColors.sage.withValues(alpha: 0.16),
            surfaceTintColor: Colors.transparent,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? ReleafColors.textPrimary
                    : ReleafColors.textMuted,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected ? ReleafColors.sage : ReleafColors.textMuted,
                size: 22,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            label: 'Reset',
          ),
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            label: 'Brain',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            label: 'Meditate',
          ),
          NavigationDestination(
            icon: Icon(Icons.bedtime_outlined),
            label: 'Sleep',
          ),
          ],
        ),
      ),
    );
  }
}

class _ResumePill extends StatelessWidget {
  const _ResumePill({
    required this.title,
    required this.subtitle,
    required this.onResume,
    required this.onDismiss,
  });

  final String title;
  final String subtitle;
  final VoidCallback onResume;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(ReleafRadii.large),
      color: ReleafColors.surfaceElevated.withValues(alpha: 0.97),
      child: InkWell(
        borderRadius: BorderRadius.circular(ReleafRadii.large),
        onTap: onResume,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ReleafRadii.large),
            border: Border.all(color: ReleafColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x50000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
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
                  shape: BoxShape.circle,
                  color: ReleafColors.sage.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 21,
                  color: ReleafColors.sage,
                ),
              ),
              const SizedBox(width: ReleafSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ReleafTypography.meta.copyWith(
                        color: ReleafColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Dismiss',
                onPressed: onDismiss,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: ReleafColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
