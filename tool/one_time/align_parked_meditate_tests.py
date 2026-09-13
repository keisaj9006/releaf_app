from pathlib import Path

path = Path('test/primary_wellbeing_tabs_test.dart')
text = path.read_text(encoding='utf-8')

old_one = """    expect(find.text('Sound'), findsWidgets);
    expect(find.byKey(const Key('sound-emergency-action')), findsOneWidget);
    expect(find.byKey(const Key('sound-open-meditate')), findsOneWidget);
    expect(find.byKey(const Key('sound-open-sleep')), findsOneWidget);
"""
new_one = """    expect(find.text('Sound'), findsWidgets);
    expect(find.byKey(const Key('sound-emergency-action')), findsOneWidget);
    expect(find.byKey(const Key('sound-open-meditate')), findsNothing);
    expect(find.byKey(const Key('sound-open-sleep')), findsOneWidget);
"""
if text.count(old_one) != 1:
    raise SystemExit(f'legacy Sound expectation: expected 1 match, found {text.count(old_one)}')
text = text.replace(old_one, new_one, 1)

old_two = """    await tester.tap(find.byKey(const Key('sleep-open-sound-library')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sound-open-meditate')), findsOneWidget);
    await tester.tap(find.byKey(const Key('sound-open-meditate')));
    await tester.pumpAndSettle();
    expect(find.text('MEDITATION'), findsOneWidget);
    expect(find.byKey(const Key('meditation-back')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sound-open-sleep')), findsOneWidget);
"""
new_two = """    await tester.tap(find.byKey(const Key('sleep-open-sound-library')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sound-open-meditate')), findsNothing);
    expect(find.byKey(const Key('sound-open-sleep')), findsOneWidget);
"""
if text.count(old_two) != 1:
    raise SystemExit(f'Sleep legacy shortcut expectation: expected 1 match, found {text.count(old_two)}')
text = text.replace(old_two, new_two, 1)

path.write_text(text, encoding='utf-8')
print('Updated stale Sound/Meditate expectations only.')
