from pathlib import Path
import re


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected one match, found {count}')
    return text.replace(old, new, 1)


sleep_path = Path('lib/features/sleep/presentation/sleep_screen.dart')
sleep = sleep_path.read_text(encoding='utf-8')
sleep = sleep.replace("import '../../stories/domain/relief_story.dart';\n", '')
sleep = replace_once(
    sleep,
    """                        if (widget.storiesPreviewEnabled) ...[
                          const SizedBox(height: ReleafSpacing.sm),
                          _OwnerPreviewEntry(
                            onPressed: () =>
                                context.push(AppRoutes.storiesPreview),
                          ),
                        ],
""",
    '',
    'remove old owner preview entry',
)
sleep = replace_once(
    sleep,
    """                          onSelected: (category) {
                            setState(() => _selectedCategory = category);
                          },
""",
    """                          onSelected: (category) {
                            if (category == SleepCategory.stories &&
                                widget.storiesPreviewEnabled) {
                              context.push(AppRoutes.storiesPreview);
                              return;
                            }
                            setState(() => _selectedCategory = category);
                          },
""",
    'route Stories gateway',
)
sleep = replace_once(
    sleep,
    """    if (category == SleepCategory.stories) {
      return _StoryCollections(catalog: catalog, onOpen: onOpen);
    }
""",
    """    if (category == SleepCategory.stories) {
      return const _StoriesUnavailableNotice();
    }
""",
    'replace inline Story collections',
)
story_section = re.compile(
    r'class _StoryCollections extends StatelessWidget \{.*?'
    r'(?=class _CategoryGateways extends StatelessWidget)',
    re.S,
)
replacement = """class _StoriesUnavailableNotice extends StatelessWidget {
  const _StoriesUnavailableNotice();

  @override
  Widget build(BuildContext context) {
    return const _SectionTitle(
      eyebrow: 'STORIES',
      title: 'Bedtime stories',
      description:
          'Narrated titles are being prepared for the dedicated library. Check back soon.',
    );
  }
}

"""
sleep, count = story_section.subn(replacement, sleep, count=1)
if count != 1:
    raise SystemExit(
        f'remove empty Story collections: expected one match, found {count}'
    )
sleep = replace_once(
    sleep,
    """                                  child: Text(
                                    category.label,
                                    style: ReleafTypography.cardTitle,
                                  ),
""",
    """                                  child: Text(
                                    category.label,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: ReleafTypography.cardTitle.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
""",
    'prevent category title wrapping',
)
empty_collection = re.compile(
    r'\nclass _EmptyCollection extends StatelessWidget \{.*?'
    r'(?=\nclass _Header extends StatelessWidget)',
    re.S,
)
sleep, count = empty_collection.subn('\n', sleep, count=1)
if count != 1:
    raise SystemExit(
        f'remove empty collection widget: expected one match, found {count}'
    )
owner_entry = re.compile(
    r'\nclass _OwnerPreviewEntry extends StatelessWidget \{.*?'
    r'(?=\nclass _SleepPremiumPreview extends StatelessWidget)',
    re.S,
)
sleep, count = owner_entry.subn('\n', sleep, count=1)
if count != 1:
    raise SystemExit(
        f'remove owner preview widget: expected one match, found {count}'
    )
sleep_path.write_text(sleep, encoding='utf-8')


test_path = Path('test/sleep_experience_test.dart')
tests = test_path.read_text(encoding='utf-8')


def replace_test(start_name: str, next_name: str, replacement_text: str) -> None:
    global tests
    pattern = re.compile(
        r"  testWidgets\('" + re.escape(start_name)
        + r"'.*?(?=  testWidgets\('" + re.escape(next_name) + r"')",
        re.S,
    )
    tests, test_count = pattern.subn(replacement_text, tests, count=1)
    if test_count != 1:
        raise SystemExit(
            f'test {start_name}: expected one match, found {test_count}'
        )


replace_test(
    'Sleep discovery exposes the frozen taxonomy and collections',
    'asset-pending Story is visible without a start action',
    """  testWidgets('Sleep discovery exposes four clear category gateways', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    for (final category in SleepCategory.values) {
      expect(
        find.byKey(Key('sleep-category-${category.name}')),
        findsOneWidget,
      );
    }
    expect(find.text('Tonight'), findsOneWidget);
    expect(find.text('Popular'), findsNothing);
    await _selectCategory(tester, SleepCategory.stories);
    expect(find.text('Bedtime stories'), findsOneWidget);
    expect(find.text('Night Mysteries'), findsNothing);
    expect(find.text('Fiction Escapes'), findsNothing);
    expect(find.text('Wonder Journeys'), findsNothing);
    expect(find.text('Drift Through History'), findsNothing);
    expect(find.text('See all'), findsNothing);
    expect(find.byKey(const Key('sleep-open-sound-library')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

""",
)
replace_test(
    'asset-pending Story is visible without a start action',
    'each Story collection exposes its See all destination',
    """  testWidgets('pending Story drafts stay out of customer discovery', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    await _selectCategory(tester, SleepCategory.stories);
    expect(find.byKey(const Key('sleep-content-ST-DC-004')), findsNothing);
    expect(find.text('AUDIO IN PRODUCTION'), findsNothing);
    expect(find.text('Bedtime stories'), findsOneWidget);
  });

""",
)
replace_test(
    'each Story collection exposes its See all destination',
    'category filter shows only the selected content family',
    """  testWidgets('standard Sleep view never renders empty Story collections', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
    );

    await _selectCategory(tester, SleepCategory.stories);
    expect(find.text('Bedtime stories'), findsOneWidget);
    expect(find.text('Dream Classics'), findsNothing);
    expect(find.text('See all'), findsNothing);
  });

""",
)
replace_test(
    'Sleep keeps the separate owner preview behind its flag',
    'Sleep remains usable at 320px with large text',
    """  testWidgets('Sleep removes the duplicate owner-preview row', (
    tester,
  ) async {
    final state = await _testState();
    await _pumpSleep(
      tester,
      preferences: state.preferences,
      progress: state.progress,
      storiesPreviewEnabled: true,
    );

    expect(find.byKey(const Key('sleep-stories-preview')), findsNothing);
    expect(find.text('OWNER PREVIEW'), findsNothing);
    expect(find.byKey(const Key('sleep-category-stories')), findsOneWidget);
  });

""",
)
test_path.write_text(tests, encoding='utf-8')


workflow_path = Path('.github/workflows/flutter_p0.yml')
workflow = workflow_path.read_text(encoding='utf-8')
workflow = replace_once(
    workflow,
    '            --dart-define=RELEAF_PREMIUM_PREVIEW=true\n',
    '            --dart-define=RELEAF_PREMIUM_PREVIEW=true \\\n'
    '            --dart-define=RELIEF_STORIES_PREVIEW=true\n',
    'enable Stories in Premium Preview APK',
)
workflow_path.write_text(workflow, encoding='utf-8')
