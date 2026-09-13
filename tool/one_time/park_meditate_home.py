from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected exactly one match, found {count}")
    return text.replace(old, new, 1)


home_path = Path('lib/features/home/home_screen.dart')
home = home_path.read_text(encoding='utf-8')

home = replace_once(
    home,
    "import '../meditation/application/meditation_library_controller.dart';\n"
    "import '../meditation/data/meditation_catalog.dart';\n"
    "import '../meditation/domain/meditation_content.dart';\n",
    "",
    'remove Home meditation imports',
)

home = replace_once(
    home,
    "    final meditationCatalog = ref.watch(meditationCatalogProvider);\n"
    "    final meditationLibrary = ref.watch(meditationLibraryControllerProvider);\n"
    "    final focus = ref.watch(homeFocusProvider);\n"
    "    final showIntro = ref.watch(homeIntroProvider);\n"
    "    final hasPremiumEntitlement = ref\n"
    "        .watch(subscriptionControllerProvider)\n"
    "        .isPremium;\n"
    "    final currentSound = soundCatalog.getById(soundState.currentTrackId ?? '');\n"
    "    final recentMeditation = _recentAccessibleMeditation(\n"
    "      catalog: meditationCatalog,\n"
    "      library: meditationLibrary,\n"
    "      isPremium: hasPremiumEntitlement,\n"
    "    );\n\n"
    "    final now = ref.watch(homeNowProvider);\n"
    "    final dailyInsight = DailyInsightCatalog.forDate(now);\n"
    "    final suggestedMeditation = _suggestedMeditation(\n"
    "      catalog: meditationCatalog,\n"
    "      library: meditationLibrary,\n"
    "      isPremium: hasPremiumEntitlement,\n"
    "    );\n",
    "    final focus = ref.watch(homeFocusProvider);\n"
    "    final showIntro = ref.watch(homeIntroProvider);\n"
    "    final currentSound = soundCatalog.getById(soundState.currentTrackId ?? '');\n\n"
    "    final now = ref.watch(homeNowProvider);\n"
    "    final dailyInsight = DailyInsightCatalog.forDate(now);\n",
    'remove Home meditation discovery state',
)

home = replace_once(
    home,
    "      brainDone: leaves.brainDone,\n"
    "      isPremium: hasPremiumEntitlement,\n"
    "      suggestedMeditation: suggestedMeditation,\n",
    "      brainDone: leaves.brainDone,\n",
    'remove recommendation meditation arguments',
)

home = replace_once(
    home,
    "                              if (activeSession.hasActive ||\n"
    "                                  currentSound != null ||\n"
    "                                  recentMeditation != null) ...[",
    "                              if (activeSession.hasActive ||\n"
    "                                  currentSound != null) ...[",
    'remove recent meditation from Continue gate',
)

home = replace_once(
    home,
    "                                else if (recentMeditation != null)\n"
    "                                  _ContinueCard(\n"
    "                                    eyebrow: 'RECENT MEDITATION',\n"
    "                                    title: recentMeditation.title,\n"
    "                                    subtitle:\n"
    "                                        'Return to a practice you used recently.',\n"
    "                                    icon: Icons.spa_outlined,\n"
    "                                    onPressed: () => context.push(\n"
    "                                      AppRoutes.meditationSessionFor(\n"
    "                                        recentMeditation.id,\n"
    "                                      ),\n"
    "                                    ),\n"
    "                                  ),\n",
    "",
    'remove recent meditation Continue card',
)

home = replace_once(
    home,
    "  required bool brainDone,\n"
    "  required bool isPremium,\n"
    "  required MeditationContent suggestedMeditation,\n",
    "  required bool brainDone,\n",
    'simplify Home recommendation signature',
)

home = replace_once(
    home,
    "  if (hour >= 20 || hour < 5) {\n"
    "    if (!isPremium) {\n"
    "      return _HomeRecommendation(\n"
    "        eyebrow: 'SUGGESTED NOW',\n"
    "        title: 'Let the Day Go',\n"
    "        description:\n"
    "            'A free night practice for setting down unfinished tasks and moving into a quieter part of the day.',\n"
    "        reason: 'Suggested from the time of day.',\n"
    "        meta: '6 min • Free • Sleep meditation',\n"
    "        route: AppRoutes.meditationSessionFor('let-the-day-go-6'),\n"
    "        artwork: ReleafArtworkVariant.ambient,\n"
    "        icon: Icons.bedtime_outlined,\n"
    "        warm: true,\n"
    "      );\n"
    "    }\n\n"
    "    return const _HomeRecommendation(\n"
    "      eyebrow: 'SUGGESTED NOW',\n"
    "      title: 'Sleep sounds',\n"
    "      description:\n"
    "          'Choose a quiet soundscape and set a timer for your evening.',\n"
    "      reason: 'Suggested from the time of day.',\n"
    "      meta: 'Sleep • Sound • Timer',\n"
    "      route: AppRoutes.sleep,\n"
    "      artwork: ReleafArtworkVariant.ambient,\n"
    "      icon: Icons.bedtime_outlined,\n"
    "      warm: true,\n"
    "    );\n"
    "  }\n",
    "  if (hour >= 20 || hour < 5) {\n"
    "    return const _HomeRecommendation(\n"
    "      eyebrow: 'SUGGESTED NOW',\n"
    "      title: 'Sleep sounds',\n"
    "      description:\n"
    "          'Choose a quiet soundscape and set a timer for your evening.',\n"
    "      reason: 'Suggested from the time of day.',\n"
    "      meta: 'Sleep • Sound • Timer',\n"
    "      route: AppRoutes.sleep,\n"
    "      artwork: ReleafArtworkVariant.ambient,\n"
    "      icon: Icons.bedtime_outlined,\n"
    "      warm: true,\n"
    "    );\n"
    "  }\n",
    'route all night recommendations to Sleep',
)

home = replace_once(
    home,
    "  if (focus == HomeFocus.mindfulness) {\n"
    "    return _meditationRecommendation(\n"
    "      item: suggestedMeditation,\n"
    "      eyebrow: 'SUGGESTED FOR YOUR FOCUS',\n"
    "      reason: 'Matches your focus: Build mindfulness.',\n"
    "    );\n"
    "  }\n",
    "  if (focus == HomeFocus.mindfulness) {\n"
    "    return const _HomeRecommendation(\n"
    "      eyebrow: 'SUGGESTED FOR YOUR FOCUS',\n"
    "      title: 'Back to the Room',\n"
    "      description:\n"
    "          'A short sensory reset to bring attention back to the present moment.',\n"
    "      reason: 'Matches your focus: Build mindfulness.',\n"
    "      meta: '3 min • Free • Grounding',\n"
    "      route: '/relief/session/back-to-room',\n"
    "      artwork: ReleafArtworkVariant.grounding,\n"
    "      icon: Icons.explore_outlined,\n"
    "    );\n"
    "  }\n",
    'keep mindfulness focus inside active Reset pillar',
)

home = replace_once(
    home,
    "  if (focus == HomeFocus.sleep && hour >= 17) {\n"
    "    if (isPremium) {\n"
    "      return const _HomeRecommendation(\n"
    "        eyebrow: 'SUGGESTED FOR YOUR FOCUS',\n"
    "        title: 'Tonight',\n"
    "        description:\n"
    "            'Choose a quiet soundscape, adjust the volume and set a timer. No voice or instructions.',\n"
    "        reason: 'Matches your focus: Sleep easier.',\n"
    "        meta: 'Sleep • Sound • Timer',\n"
    "        route: AppRoutes.sleep,\n"
    "        artwork: ReleafArtworkVariant.ambient,\n"
    "        icon: Icons.bedtime_outlined,\n"
    "        warm: true,\n"
    "      );\n"
    "    }\n\n"
    "    return _HomeRecommendation(\n"
    "      eyebrow: 'SUGGESTED FOR YOUR FOCUS',\n"
    "      title: 'Let the Day Go',\n"
    "      description:\n"
    "          'Use the free night practice before choosing anything longer.',\n"
    "      reason: 'Matches your focus: Sleep easier.',\n"
    "      meta: '6 min • Free • Sleep meditation',\n"
    "      route: AppRoutes.meditationSessionFor('let-the-day-go-6'),\n"
    "      artwork: ReleafArtworkVariant.ambient,\n"
    "      icon: Icons.bedtime_outlined,\n"
    "      warm: true,\n"
    "    );\n"
    "  }\n",
    "  if (focus == HomeFocus.sleep && hour >= 17) {\n"
    "    return const _HomeRecommendation(\n"
    "      eyebrow: 'SUGGESTED FOR YOUR FOCUS',\n"
    "      title: 'Tonight',\n"
    "      description:\n"
    "          'Choose a quiet soundscape, adjust the volume and set a timer. No voice or instructions.',\n"
    "      reason: 'Matches your focus: Sleep easier.',\n"
    "      meta: 'Sleep • Sound • Timer',\n"
    "      route: AppRoutes.sleep,\n"
    "      artwork: ReleafArtworkVariant.ambient,\n"
    "      icon: Icons.bedtime_outlined,\n"
    "      warm: true,\n"
    "    );\n"
    "  }\n",
    'keep Sleep focus sound-first for all users',
)

home = replace_once(
    home,
    "  return _meditationRecommendation(\n"
    "    item: suggestedMeditation,\n"
    "    eyebrow: 'SUGGESTED NOW',\n"
    "    reason: 'Reset and Brain are already complete today.',\n"
    "  );\n"
    "}\n\n"
    "MeditationContent? _recentAccessibleMeditation({\n"
    "  required MeditationCatalog catalog,\n"
    "  required MeditationLibraryState library,\n"
    "  required bool isPremium,\n"
    "}) {\n"
    "  for (final id in library.recentIds) {\n"
    "    final item = catalog.getById(id);\n"
    "    if (item == null) continue;\n"
    "    if (item.isPremium && !isPremium) continue;\n"
    "    return item;\n"
    "  }\n"
    "  return null;\n"
    "}\n\n"
    "MeditationContent _suggestedMeditation({\n"
    "  required MeditationCatalog catalog,\n"
    "  required MeditationLibraryState library,\n"
    "  required bool isPremium,\n"
    "}) {\n"
    "  bool accessible(MeditationContent item) => !item.isPremium || isPremium;\n\n"
    "  final foundations = catalog\n"
    "      .getSeries(MeditationCatalog.foundationsSeriesId)\n"
    "      .where(accessible)\n"
    "      .toList(growable: false);\n\n"
    "  for (final item in foundations) {\n"
    "    if (!library.isCompleted(item.id)) return item;\n"
    "  }\n\n"
    "  final available = catalog\n"
    "      .getAll()\n"
    "      .where(accessible)\n"
    "      .where((item) => item.category != MeditationCategory.unguided)\n"
    "      .toList(growable: false);\n\n"
    "  for (final item in available) {\n"
    "    if (!library.isCompleted(item.id)) return item;\n"
    "  }\n\n"
    "  if (foundations.isNotEmpty) return foundations.first;\n"
    "  return available.first;\n"
    "}\n\n"
    "_HomeRecommendation _meditationRecommendation({\n"
    "  required MeditationContent item,\n"
    "  required String eyebrow,\n"
    "  required String reason,\n"
    "}) {\n"
    "  final minutes = item.durationSeconds ~/ 60;\n"
    "  final access = item.isPremium ? 'Premium' : 'Free';\n\n"
    "  return _HomeRecommendation(\n"
    "    eyebrow: eyebrow,\n"
    "    title: item.title,\n"
    "    description: item.subtitle,\n"
    "    reason: reason,\n"
    "    meta: '$minutes min • $access • Meditation',\n"
    "    route: AppRoutes.meditationSessionFor(item.id),\n"
    "    artwork: _homeArtworkForMeditation(item.category),\n"
    "    icon: Icons.spa_outlined,\n"
    "  );\n"
    "}\n\n"
    "ReleafArtworkVariant _homeArtworkForMeditation(MeditationCategory category) {\n"
    "  return switch (category) {\n"
    "    MeditationCategory.anxiety => ReleafArtworkVariant.calm,\n"
    "    MeditationCategory.body => ReleafArtworkVariant.grounding,\n"
    "    MeditationCategory.everyday => ReleafArtworkVariant.lifeUpgrade,\n"
    "    MeditationCategory.unguided => ReleafArtworkVariant.ambient,\n"
    "    MeditationCategory.startHere ||\n"
    "    MeditationCategory.focus ||\n"
    "    MeditationCategory.mind => ReleafArtworkVariant.focus,\n"
    "  };\n"
    "}\n",
    "  return const _HomeRecommendation(\n"
    "    eyebrow: 'SUGGESTED NOW',\n"
    "    title: 'Back to the Room',\n"
    "    description:\n"
    "        'A short sensory reset when you want one more deliberate pause in the day.',\n"
    "    reason: 'Reset and Brain are already complete today.',\n"
    "    meta: '3 min • Free • Grounding',\n"
    "    route: '/relief/session/back-to-room',\n"
    "    artwork: ReleafArtworkVariant.grounding,\n"
    "    icon: Icons.explore_outlined,\n"
    "  );\n"
    "}\n",
    'remove Home meditation helper graph',
)

home_path.write_text(home, encoding='utf-8')


test_path = Path('test/home_hub_test.dart')
test = test_path.read_text(encoding='utf-8')

test = replace_once(
    test,
    "        expect(find.text('Let the Day Go'), findsOneWidget);",
    "        expect(find.text('Sleep sounds'), findsOneWidget);",
    'update time-dependent Home test',
)

test = replace_once(
    test,
    "    expect(find.text('Mindfulness Basics'), findsOneWidget);",
    "    expect(find.text('Back to the Room'), findsOneWidget);",
    'update mindfulness focus test',
)

test = replace_once(
    test,
    "  testWidgets('Home Continue surfaces the most recent accessible meditation', (\n"
    "    WidgetTester tester,\n"
    "  ) async {\n"
    "    final preferences = await _preferences();\n"
    "    await preferences.setBool('releaf.home.intro.dismissed.v1', true);\n"
    "    await preferences.setStringList('meditation.recent_ids', [\n"
    "      'breath-and-body-4',\n"
    "    ]);\n\n"
    "    await _pumpHome(tester, preferences: preferences);\n\n"
    "    expect(find.text('CONTINUE'), findsOneWidget);\n"
    "    expect(find.text('RECENT MEDITATION'), findsOneWidget);\n"
    "    expect(find.text('Breath & Body'), findsOneWidget);\n"
    "    expect(\n"
    "      find.text('Return to a practice you used recently.'),\n"
    "      findsOneWidget,\n"
    "    );\n"
    "  });\n",
    "  testWidgets('Home does not rediscover recent meditation while parked', (\n"
    "    WidgetTester tester,\n"
    "  ) async {\n"
    "    final preferences = await _preferences();\n"
    "    await preferences.setBool('releaf.home.intro.dismissed.v1', true);\n"
    "    await preferences.setStringList('meditation.recent_ids', [\n"
    "      'breath-and-body-4',\n"
    "    ]);\n\n"
    "    await _pumpHome(tester, preferences: preferences);\n\n"
    "    expect(find.text('RECENT MEDITATION'), findsNothing);\n"
    "    expect(find.text('Breath & Body'), findsNothing);\n"
    "  });\n",
    'update recent meditation Home test',
)

test = replace_once(
    test,
    "  testWidgets(\n"
    "    'Home mindfulness recommendation advances with meditation progress',\n"
    "    (WidgetTester tester) async {\n",
    "  testWidgets(\n"
    "    'Home mindfulness recommendation stays in Reset despite meditation history',\n"
    "    (WidgetTester tester) async {\n",
    'rename mindfulness progress test',
)

test = replace_once(
    test,
    "      expect(find.text('Breath & Body'), findsOneWidget);\n"
    "      expect(\n"
    "        find.text('Matches your focus: Build mindfulness.'),\n",
    "      expect(find.text('Back to the Room'), findsOneWidget);\n"
    "      expect(\n"
    "        find.text('Matches your focus: Build mindfulness.'),\n",
    'update mindfulness history expectation',
)

test_path.write_text(test, encoding='utf-8')

print('Parked Meditate removed from Home discovery; direct Meditate routes remain untouched.')
