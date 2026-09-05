import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../routing/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/releaf_design_tokens.dart';
import '../../../theme/widgets/releaf_artwork.dart';
import '../../../theme/widgets/releaf_components.dart';
import '../application/relief_paywall_hooks.dart';
import '../data/reset_catalog.dart';
import '../domain/models/reset_content.dart';
import '../domain/models/reset_launch_options.dart';
import '../domain/reset_access_policy.dart';
import 'reset_session_preview_sheet.dart';

class ReliefScreen extends ConsumerStatefulWidget {
  const ReliefScreen({super.key});

  @override
  ConsumerState<ReliefScreen> createState() => _ReliefScreenState();
}

class _ReliefScreenState extends ConsumerState<ReliefScreen> {
  static const _maxContentWidth = 720.0;
  static const _categoryOrder = [
    QuickResetCategory.breath,
    QuickResetCategory.noBreath,
    QuickResetCategory.situational,
    QuickResetCategory.lifeUpgrade,
  ];

  final _availableNowKey = GlobalKey();
  PageController? _categoryController;
  PageController? _sessionController;
  PageController? _deepController;
  double? _configuredWidth;
  QuickResetCategory? _selectedCategory;

  PageController get _categories => _categoryController!;
  PageController get _sessions => _sessionController!;
  PageController get _deep => _deepController!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = math.min(
      MediaQuery.sizeOf(context).width,
      _maxContentWidth,
    );
    if (_configuredWidth == width) return;

    _configuredWidth = width;
    _categoryController = _replaceController(
      _categoryController,
      _viewportFraction(
        contentWidth: width,
        railMaxWidth: 470,
        targetFraction: 0.82,
        cardMaxWidth: 390,
      ),
    );
    _sessionController = _replaceController(
      _sessionController,
      _viewportFraction(
        contentWidth: width,
        railMaxWidth: 600,
        targetFraction: 0.78,
        cardMaxWidth: 360,
      ),
    );
    _deepController = _replaceController(
      _deepController,
      _viewportFraction(
        contentWidth: width,
        railMaxWidth: 660,
        targetFraction: 0.84,
        cardMaxWidth: 520,
      ),
    );
  }

  double _viewportFraction({
    required double contentWidth,
    required double railMaxWidth,
    required double targetFraction,
    required double cardMaxWidth,
  }) {
    final railWidth = math.min(
      math.max(1.0, contentWidth - ReleafSpacing.screen),
      railMaxWidth,
    );
    final cardWidth = math.min(contentWidth * targetFraction, cardMaxWidth);
    return (cardWidth / railWidth).clamp(0.48, 0.94).toDouble();
  }

  PageController _replaceController(
    PageController? current,
    double viewportFraction,
  ) {
    var page = current?.initialPage ?? 0;
    if (current != null &&
        current.hasClients &&
        current.position.hasContentDimensions) {
      page = (current.page ?? page).round();
    }
    current?.dispose();
    return PageController(
      initialPage: page,
      viewportFraction: viewportFraction,
    );
  }

  @override
  void dispose() {
    _categoryController?.dispose();
    _sessionController?.dispose();
    _deepController?.dispose();
    super.dispose();
  }

  Future<void> _openSession(
    BuildContext context,
    ResetContent session,
    bool isPremiumUser,
  ) async {
    final accessPolicy = ref.read(resetAccessPolicyProvider);
    final canAccess = accessPolicy.canAccess(
      session,
      hasPremiumEntitlement: isPremiumUser,
    );

    final preview = await showResetSessionPreview(
      context,
      session: session,
      isLocked: !canAccess,
    );
    if (preview == null || !context.mounted) return;

    if (preview.action == ResetSessionPreviewAction.unlock) {
      await maybeShowPaywall(context, ref, force: true);
      return;
    }

    final latestPremiumState =
        ref.read(subscriptionControllerProvider).isPremium;
    if (!accessPolicy.canAccess(
      session,
      hasPremiumEntitlement: latestPremiumState,
    )) {
      await maybeShowPaywall(context, ref, force: true);
      return;
    }

    await _launchSession(
      context,
      session,
      preview.options,
    );
  }

  Future<void> _launchSession(
    BuildContext context,
    ResetContent session,
    ResetLaunchOptions options,
  ) async {
    await reliefStarted(ref);

    if (!context.mounted) return;
    final helpedALot = await context.push<bool>(
      AppRoutes.reliefSessionFor(session.id),
      extra: options,
    );

    if (helpedALot == null || !context.mounted) return;

    await reliefCompleted(ref, helpedALot: helpedALot);

    if (context.mounted && helpedALot) {
      await maybeShowPaywall(
        context,
        ref,
        softOffer: true,
      );
    }
  }

  Future<void> _focusCategory(QuickResetCategory category) async {
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    if (_selectedCategory != category) {
      setState(() => _selectedCategory = category);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    final sectionContext = _availableNowKey.currentContext;
    if (sectionContext != null && sectionContext.mounted) {
      await Scrollable.ensureVisible(
        sectionContext,
        alignment: 0.08,
        duration: reducedMotion ? Duration.zero : ReleafMotion.standard,
        curve: ReleafMotion.entranceCurve,
      );
    }

    if (!mounted || !_sessions.hasClients) return;
    _sessions.jumpToPage(0);
  }

  Future<void> _clearCategoryFilter() async {
    if (_selectedCategory == null) return;
    setState(() => _selectedCategory = null);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted && _sessions.hasClients) {
      _sessions.jumpToPage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(resetCatalogProvider);
    final regularContent = catalog.getRegularContent();
    final allQuickSessions = regularContent
        .where((session) => session.level == ResetLevel.quick)
        .toList();
    final quickSessions = _selectedCategory == null
        ? allQuickSessions
        : allQuickSessions
            .where((session) => session.quickCategory == _selectedCategory)
            .toList();
    final deepSessions = regularContent
        .where((session) => session.level == ResetLevel.deep)
        .toList();
    final accessPolicy = ref.watch(resetAccessPolicyProvider);
    final isPremiumUser = ref.watch(subscriptionControllerProvider).isPremium;

    return Theme(
      data: AppTheme.premiumDark(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: ReleafColors.background,
          body: Stack(
            children: [
              const Positioned.fill(child: _ResetBackdrop()),
              SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    key: const Key('reset-content-column'),
                    constraints: const BoxConstraints(
                      maxWidth: _maxContentWidth,
                    ),
                    child: CustomScrollView(
                      key: const Key('reset-scroll-view'),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  ReleafSpacing.screen,
                                  ReleafSpacing.lg,
                                  ReleafSpacing.screen,
                                  0,
                                ),
                                child: _ResetHeader(
                                  onEmergencyPressed: () {
                                    context.push(
                                      AppRoutes.reliefSessionFor(
                                        ResetCatalog.emergencySessionId,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xxl),
                              const _SectionPadding(
                                child: ReleafSectionHeading(
                                  title: 'Quick Reset',
                                  description: 'Feel steadier in 2–4 minutes.',
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.lg),
                              _EditorialRail(
                                semanticsLabel:
                                    'Quick Reset categories carousel',
                                railKey: const Key('reset-category-carousel'),
                                controller: _categories,
                                height: 266,
                                maxWidth: 470,
                                itemCount: _categoryOrder.length,
                                itemBuilder: (context, index) {
                                  final category = _categoryOrder[index];
                                  final count = allQuickSessions
                                      .where(
                                        (session) =>
                                            session.quickCategory == category,
                                      )
                                      .length;
                                  return _EditorialCategoryCard(
                                    category: category,
                                    sessionCount: count,
                                    onPressed: count == 0
                                        ? null
                                        : () => _focusCategory(category),
                                  );
                                },
                              ),
                              const SizedBox(height: ReleafSpacing.sm),
                              _SectionPadding(
                                child: _RailProgress(
                                  controller: _categories,
                                  itemCount: _categoryOrder.length,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              _SectionPadding(
                                key: _availableNowKey,
                                child: ReleafSectionHeading(
                                  title: _selectedCategory == null
                                      ? 'Available Now'
                                      : _categoryLabel(_selectedCategory!),
                                  description: _selectedCategory == null
                                      ? 'Small resets, ready when you are.'
                                      : _categoryDescription(
                                          _selectedCategory!,
                                        ),
                                ),
                              ),
                              if (_selectedCategory != null) ...[
                                const SizedBox(height: ReleafSpacing.sm),
                                _SectionPadding(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ActionChip(
                                      key: const Key(
                                        'reset-clear-category-filter',
                                      ),
                                      avatar: const Icon(
                                        Icons.close_rounded,
                                        size: 15,
                                      ),
                                      label: const Text('Show all resets'),
                                      onPressed: _clearCategoryFilter,
                                      backgroundColor:
                                          ReleafColors.surfaceSoft,
                                      side: const BorderSide(
                                        color: ReleafColors.borderSoft,
                                      ),
                                      labelStyle:
                                          ReleafTypography.meta.copyWith(
                                        color: ReleafColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: ReleafSpacing.lg),
                              _EditorialRail(
                                semanticsLabel:
                                    'Available Reset sessions carousel',
                                railKey: const Key('reset-session-rail'),
                                controller: _sessions,
                                height: 202,
                                maxWidth: 600,
                                itemCount: quickSessions.length,
                                itemBuilder: (context, index) {
                                  final session = quickSessions[index];
                                  return _QuickSessionCard(
                                    session: session,
                                    isLocked: !accessPolicy.canAccess(
                                      session,
                                      hasPremiumEntitlement: isPremiumUser,
                                    ),
                                    onPressed: () => _openSession(
                                      context,
                                      session,
                                      isPremiumUser,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              const _SectionPadding(
                                child: ReleafSectionHeading(
                                  title: 'Deep Reset',
                                  description:
                                      'Go deeper with guided 8-minute protocols.',
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xs),
                              const _SectionPadding(
                                child: Text(
                                  'Choose an 8-minute protocol for the state you are in.',
                                  style: ReleafTypography.meta,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.lg),
                              _EditorialRail(
                                semanticsLabel:
                                    'Deep Reset protocols carousel',
                                railKey: const Key('reset-deep-rail'),
                                controller: _deep,
                                height: 252,
                                maxWidth: 660,
                                itemCount: deepSessions.length,
                                itemBuilder: (context, index) {
                                  final session = deepSessions[index];
                                  return _DeepResetCard(
                                    session: session,
                                    isLocked: !accessPolicy.canAccess(
                                      session,
                                      hasPremiumEntitlement: isPremiumUser,
                                    ),
                                    onPressed: () => _openSession(
                                      context,
                                      session,
                                      isPremiumUser,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                              const _SectionPadding(
                                child: ReleafSectionHeading(
                                  title: 'Sound',
                                  description:
                                      'Ambient audio for quiet, focus and unwinding.',
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.lg),
                              _SectionPadding(
                                child: _SoundGatewayCard(
                                  onPressed: () =>
                                      context.push(AppRoutes.sound),
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.section),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetBackdrop extends StatelessWidget {
  const _ResetBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1712),
            ReleafColors.background,
            Color(0xFF070C0A),
          ],
          stops: [0, 0.36, 1],
        ),
      ),
    );
  }
}

class _ResetHeader extends StatelessWidget {
  const _ResetHeader({required this.onEmergencyPressed});

  final VoidCallback onEmergencyPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: 10,
            top: -35,
            width: 180,
            height: 150,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.34,
                child: ReleafLivingForm(
                  variant: ReleafArtworkVariant.ambient,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text('Reset', style: ReleafTypography.display),
                    ),
                    const SizedBox(width: ReleafSpacing.md),
                    ReleafRoundIconButton(
                      key: const Key('reset-emergency-action'),
                      icon: Icons.health_and_safety_outlined,
                      tooltip: 'Open Emergency Calm',
                      onPressed: onEmergencyPressed,
                      isWarm: false,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'What do you need right now?',
                  style: ReleafTypography.body.copyWith(
                    color: ReleafColors.textPrimary,
                    fontSize: 16,
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

class _SectionPadding extends StatelessWidget {
  const _SectionPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ReleafSpacing.screen),
      child: child,
    );
  }
}

typedef _RailItemBuilder = Widget Function(BuildContext context, int index);

class _EditorialRail extends StatelessWidget {
  const _EditorialRail({
    required this.semanticsLabel,
    required this.railKey,
    required this.controller,
    required this.height,
    required this.maxWidth,
    required this.itemCount,
    required this.itemBuilder,
  });

  final String semanticsLabel;
  final Key railKey;
  final PageController controller;
  final double height;
  final double maxWidth;
  final int itemCount;
  final _RailItemBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticsLabel,
      child: Padding(
        padding: const EdgeInsets.only(left: ReleafSpacing.screen),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(constraints.maxWidth, maxWidth);
            final responsiveHeight =
                MediaQuery.sizeOf(context).width < 360 ? height + 40 : height;
            return Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: width,
                height: responsiveHeight,
                child: PageView.builder(
                  key: railKey,
                  controller: controller,
                  itemCount: itemCount,
                  padEnds: false,
                  pageSnapping: true,
                  allowImplicitScrolling: true,
                  clipBehavior: Clip.none,
                  physics: const PageScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    return _RailPageTransform(
                      controller: controller,
                      index: index,
                      child: itemBuilder(context, index),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RailPageTransform extends StatelessWidget {
  const _RailPageTransform({
    required this.controller,
    required this.index,
    required this.child,
  });

  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: controller,
      child: Padding(
        padding: const EdgeInsets.only(
          top: ReleafSpacing.xs,
          right: ReleafSpacing.sm,
          bottom: ReleafSpacing.sm,
        ),
        child: child,
      ),
      builder: (context, child) {
        if (reducedMotion ||
            !controller.hasClients ||
            !controller.position.hasContentDimensions) {
          return child!;
        }
        final page = controller.page ?? controller.initialPage.toDouble();
        final distance = (page - index).abs().clamp(0.0, 1.0).toDouble();
        return Transform.scale(
          alignment: Alignment.centerLeft,
          scale: 1 - (distance * 0.035),
          child: Opacity(
            opacity: 1 - (distance * 0.13),
            child: child,
          ),
        );
      },
    );
  }
}

class _RailProgress extends StatelessWidget {
  const _RailProgress({required this.controller, required this.itemCount});

  final PageController controller;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        var activePage = controller.initialPage;
        if (controller.hasClients &&
            controller.position.hasContentDimensions) {
          activePage = (controller.page ?? activePage).round();
        }
        return Row(
          children: [
            for (var index = 0; index < itemCount; index++) ...[
              AnimatedContainer(
                duration: reducedMotion ? Duration.zero : ReleafMotion.quick,
                curve: ReleafMotion.emphasisCurve,
                width: index == activePage ? 22 : 6,
                height: 4,
                decoration: BoxDecoration(
                  color: index == activePage
                      ? ReleafColors.sage
                      : ReleafColors.border,
                  borderRadius: BorderRadius.circular(ReleafRadii.pill),
                ),
              ),
              if (index != itemCount - 1)
                const SizedBox(width: ReleafSpacing.xs),
            ],
          ],
        );
      },
    );
  }
}

class _EditorialCategoryCard extends StatelessWidget {
  const _EditorialCategoryCard({
    required this.category,
    required this.sessionCount,
    required this.onPressed,
  });

  final QuickResetCategory category;
  final int sessionCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final available = sessionCount > 0;
    final countLabel = available
        ? '$sessionCount ${sessionCount == 1 ? 'session' : 'sessions'}'
        : 'More coming';

    return Semantics(
      container: true,
      excludeSemantics: true,
      button: available,
      enabled: available,
      onTap: onPressed,
      label: '${_categoryLabel(category)} category. '
          '${_categoryDescription(category)} $countLabel. '
          '${available ? 'Shows matching sessions.' : 'Not available yet.'}',
      child: ReleafPressableCard(
        key: Key('reset-category-${category.name}'),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ReleafArtwork(variant: _categoryArtwork(category)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x10000000),
                    Color(0x33000000),
                    Color(0xE6000000),
                  ],
                  stops: [0, 0.46, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ReleafSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _GlassLabel(
                      label: countLabel,
                      isMuted: !available,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _categoryLabel(category),
                    style: ReleafTypography.sectionTitle.copyWith(
                      fontSize: 23,
                      letterSpacing: -0.55,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.xs),
                  Text(
                    _categoryDescription(category),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.body.copyWith(
                      color: ReleafColors.textPrimary.withValues(alpha: 0.78),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.md),
                  Row(
                    children: [
                      Text(
                        available ? 'Explore' : 'In development',
                        style: ReleafTypography.meta.copyWith(
                          color: available
                              ? ReleafColors.textPrimary
                              : ReleafColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (available) ...[
                        const SizedBox(width: ReleafSpacing.xs),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: ReleafColors.textPrimary,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSessionCard extends StatelessWidget {
  const _QuickSessionCard({
    required this.session,
    required this.isLocked,
    required this.onPressed,
  });

  final ResetContent session;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      enabled: true,
      onTap: onPressed,
      label: '${session.title}. ${_sessionPurpose(session)} '
          '${_durationLabel(session.durationSeconds)}. '
          '${_sessionTypeLabel(session)}. '
          '${session.isPremium ? 'Premium, opens session preview.' : 'Free, opens session preview.'}',
      child: ReleafPressableCard(
        key: Key('reset-session-${session.id}'),
        onPressed: onPressed,
        warmAccent: session.isPremium,
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ReleafArtwork(variant: _sessionArtwork(session)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x05000000),
                    Color(0x52000000),
                    Color(0xEE000000),
                  ],
                  stops: [0, 0.44, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ReleafSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _GlassLabel(
                            label: _sessionTypeLabel(session),
                          ),
                        ),
                      ),
                      const SizedBox(width: ReleafSpacing.xs),
                      if (session.isPremium)
                        const ReleafPremiumBadge()
                      else
                        const _GlassLabel(label: 'Free', isSage: true),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.cardTitle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: ReleafSpacing.xxs),
                  Text(
                    _sessionPurpose(session),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ReleafTypography.meta.copyWith(
                      color: ReleafColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: ReleafSpacing.sm),
                  Row(
                    children: [
                      Text(
                        _durationLabel(session.durationSeconds),
                        style: ReleafTypography.meta.copyWith(
                          color: ReleafColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _CircularAffordance(isLocked: isLocked),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeepResetCard extends StatelessWidget {
  const _DeepResetCard({
    required this.session,
    required this.isLocked,
    required this.onPressed,
  });

  final ResetContent session;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      enabled: true,
      onTap: onPressed,
      label: '${session.title}. ${_durationLabel(session.durationSeconds)} '
          'Deep Reset protocol. Premium, opens session preview.',
      child: ReleafPressableCard(
        key: Key('reset-session-${session.id}'),
        onPressed: onPressed,
        warmAccent: true,
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ReleafArtwork(variant: _sessionArtwork(session)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0x15000000),
                    Color(0x66000000),
                    Color(0xF2000000),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(ReleafSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _GlassLabel(
                            label: 'Deep Reset',
                            isWarm: true,
                          ),
                        ),
                      ),
                      SizedBox(width: ReleafSpacing.xs),
                      ReleafPremiumBadge(),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 2,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ReleafColors.premium,
                          borderRadius: BorderRadius.circular(
                            ReleafRadii.pill,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: ReleafColors.glowPremium,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: ReleafSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ReleafTypography.sectionTitle.copyWith(
                                fontSize: 22,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: ReleafSpacing.xxs),
                            Text(
                              session.isLegacyCompatible
                                  ? 'Current 3-minute protocol'
                                  : '${_durationLabel(session.durationSeconds)} protocol',
                              style: ReleafTypography.meta.copyWith(
                                color: ReleafColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: ReleafSpacing.sm),
                      _CircularAffordance(isLocked: isLocked, isWarm: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundGatewayCard extends StatelessWidget {
  const _SoundGatewayCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTap: onPressed,
      label: 'Open Sound. Ambient audio player and sound library.',
      child: ReleafPressableCard(
        key: const Key('reset-sound-gateway'),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return SizedBox(
              height: compact ? 230 : 190,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ReleafArtwork(
                    variant: ReleafArtworkVariant.ambient,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0x10000000),
                          Color(0x52000000),
                          Color(0xEE000000),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(ReleafSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _GlassLabel(
                                label: 'AMBIENT AUDIO',
                                isSage: true,
                              ),
                              const Spacer(),
                              Text(
                                'Sound Space',
                                style: ReleafTypography.sectionTitle.copyWith(
                                  fontSize: 23,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: ReleafSpacing.xxs),
                              Text(
                                'Play real bundled audio with looping, favorites '
                                'and a sleep timer.',
                                style: ReleafTypography.meta.copyWith(
                                  color: ReleafColors.textSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: ReleafSpacing.md),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ReleafColors.sage.withValues(alpha: 0.10),
                            border: Border.all(
                              color: ReleafColors.sage.withValues(alpha: 0.30),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.graphic_eq_rounded,
                            color: ReleafColors.sage,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GlassLabel extends StatelessWidget {
  const _GlassLabel({
    required this.label,
    this.isSage = false,
    this.isWarm = false,
    this.isMuted = false,
  });

  final String label;
  final bool isSage;
  final bool isWarm;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final color = isWarm
        ? ReleafColors.premium
        : isSage
        ? ReleafColors.sage
        : isMuted
        ? ReleafColors.textSecondary
        : ReleafColors.textPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ReleafTypography.meta.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CircularAffordance extends StatelessWidget {
  const _CircularAffordance({this.isLocked = false, this.isWarm = false});

  final bool isLocked;
  final bool isWarm;

  @override
  Widget build(BuildContext context) {
    final accent = isWarm ? ReleafColors.premium : ReleafColors.textPrimary;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      alignment: Alignment.center,
      child: Icon(
        isLocked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
        size: 16,
        color: accent,
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

String _categoryLabel(QuickResetCategory category) {
  return switch (category) {
    QuickResetCategory.situational => 'Situational',
    QuickResetCategory.breath => 'Breath',
    QuickResetCategory.noBreath => 'No-Breath',
    QuickResetCategory.lifeUpgrade => 'Life Upgrade',
  };
}

String _categoryDescription(QuickResetCategory category) {
  return switch (category) {
    QuickResetCategory.situational => 'For moments that hit fast.',
    QuickResetCategory.breath => 'Use your breath to shift your state.',
    QuickResetCategory.noBreath =>
      'Ground your body without a breathing drill.',
    QuickResetCategory.lifeUpgrade =>
      'Small practices for stronger everyday regulation.',
  };
}

ReleafArtworkVariant _categoryArtwork(QuickResetCategory category) {
  return switch (category) {
    QuickResetCategory.situational => ReleafArtworkVariant.situational,
    QuickResetCategory.breath => ReleafArtworkVariant.breath,
    QuickResetCategory.noBreath => ReleafArtworkVariant.noBreath,
    QuickResetCategory.lifeUpgrade => ReleafArtworkVariant.lifeUpgrade,
  };
}

ReleafArtworkVariant _sessionArtwork(ResetContent session) {
  return switch (session.id) {
    '60s-grounding' => ReleafArtworkVariant.grounding,
    'back-to-room' => ReleafArtworkVariant.noBreath,
    'jaw-shoulders' => ReleafArtworkVariant.grounding,
    'name-the-thought' => ReleafArtworkVariant.focus,
    'object-anchor' => ReleafArtworkVariant.grounding,
    'sound-anchor' => ReleafArtworkVariant.ambient,
    'press-release' => ReleafArtworkVariant.noBreath,
    'make-room' => ReleafArtworkVariant.focus,
    'one-small-next-step' => ReleafArtworkVariant.lifeUpgrade,
    'equal-rhythm' => ReleafArtworkVariant.breath,
    'before-interview' => ReleafArtworkVariant.situational,
    'before-presentation' => ReleafArtworkVariant.calm,
    'after-conflict' => ReleafArtworkVariant.focus,
    'panic-spike' => ReleafArtworkVariant.grounding,
    'overthinking-night' => ReleafArtworkVariant.focus,
    'social-pressure' => ReleafArtworkVariant.situational,
    'travel-stress' => ReleafArtworkVariant.ambient,
    'work-overwhelm' => ReleafArtworkVariant.lifeUpgrade,
    'wired-steady' => ReleafArtworkVariant.breath,
    'tension-body-scan' => ReleafArtworkVariant.grounding,
    'overwhelm-stability' => ReleafArtworkVariant.lifeUpgrade,
    'evening-unwind' => ReleafArtworkVariant.ambient,
    'anger-release' => ReleafArtworkVariant.noBreath,
    'overthinking-let-go' => ReleafArtworkVariant.focus,
    '90s-calm-down' => ReleafArtworkVariant.calm,
    'longer-exhale' => ReleafArtworkVariant.breath,
    '5min-focus' => ReleafArtworkVariant.focus,
    _ => ReleafArtworkVariant.ambient,
  };
}

String _sessionPurpose(ResetContent session) {
  return switch (session.id) {
    '60s-grounding' => 'Return attention to your body.',
    'back-to-room' => 'Ground attention through what you can see, feel and hear.',
    'jaw-shoulders' => 'Release tension held around the jaw and shoulders.',
    'name-the-thought' => 'Create a little distance from a looping thought.',
    'object-anchor' => 'Narrow attention to one real object in front of you.',
    'sound-anchor' => 'Reconnect with the room through nearby and distant sounds.',
    'press-release' => 'Use gentle pressure and release to notice a change in tension.',
    'make-room' => 'Stop fighting the moment and create space around what is here.',
    'one-small-next-step' => 'Turn overwhelm into one small, realistic next action.',
    'equal-rhythm' => 'Settle into a smooth, even five-count rhythm.',
    'before-interview' => 'Reduce the mental load and keep only the first useful step.',
    'before-presentation' => 'Release tension and narrow attention to how you begin.',
    'after-conflict' => 'Create space between activation and your next response.',
    'panic-spike' => 'Reconnect with the room through fast sensory grounding.',
    'overthinking-night' => 'Step back from a looping thought without solving it tonight.',
    'social-pressure' => 'Move attention away from self-monitoring and back to the room.',
    'travel-stress' => 'Ground in what is stable and focus on the next travel step.',
    'work-overwhelm' => 'Reduce the workload in your head to one visible next action.',
    'wired-steady' => 'Move from wired energy toward a steadier breathing rhythm.',
    'tension-body-scan' => 'Scan the body slowly and notice where effort can soften.',
    'overwhelm-stability' => 'Separate the whole problem from the one action that matters now.',
    'evening-unwind' => 'Set down the unfinished day without requiring perfect calm.',
    'anger-release' => 'Give activation time to settle before choosing the next response.',
    'overthinking-let-go' => 'Create distance from repetitive thinking and return to the present.',
    '90s-calm-down' => 'Slow the pace and soften tension.',
    'longer-exhale' => 'Settle into a slightly longer, gentler exhale.',
    '5min-focus' => 'Anchor attention through your senses.',
    _ => session.summary ?? 'A guided reset for the present moment.',
  };
}

String _sessionTypeLabel(ResetContent session) {
  if (session.quickCategory != null) {
    return _categoryLabel(session.quickCategory!);
  }

  return switch (session.modality) {
    ResetModality.breathing => 'Breathing',
    ResetModality.grounding => 'Grounding',
    ResetModality.guidedPractice => 'Guided',
  };
}
