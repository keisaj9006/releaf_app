from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected exactly one match, found {count}")
    return text.replace(old, new, 1)


sound_path = Path('lib/features/sound/presentation/sound_screen.dart')
sound = sound_path.read_text(encoding='utf-8')

sound = replace_once(
    sound,
    "                              _SoundDestinations(\n"
    "                                onMeditate: () =>\n"
    "                                    context.push(AppRoutes.meditate),\n"
    "                                onSleep: () => context.push(AppRoutes.sleep),\n"
    "                              ),\n",
    "                              _SoundDestinations(\n"
    "                                onSleep: () => context.push(AppRoutes.sleep),\n"
    "                              ),\n",
    'remove Sound-to-Meditate route',
)

sound = replace_once(
    sound,
    "                'Long-form audio, meditation and sleep spaces for lower-stimulation moments.',\n",
    "                'Long-form audio and sleep spaces for lower-stimulation moments.',\n",
    'remove meditation from Sound header copy',
)

old_destinations = """class _SoundDestinations extends StatelessWidget {
  const _SoundDestinations({required this.onMeditate, required this.onSleep});

  final VoidCallback onMeditate;
  final VoidCallback onSleep;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 420;

        final meditate = _SoundDestinationCard(
          key: const Key('sound-open-meditate'),
          icon: Icons.spa_outlined,
          eyebrow: 'GUIDED',
          title: 'Meditate',
          description:
              'Voice-led practices with separate ambience and narration controls.',
          accent: ReleafFeatureAccents.meditation,
          onPressed: onMeditate,
        );
        final sleep = _SoundDestinationCard(
          key: const Key('sound-open-sleep'),
          icon: Icons.bedtime_outlined,
          eyebrow: 'NO VOICE',
          title: 'Sleep',
          description:
              'Low-stimulation tones and nature sound designed for the end of the day.',
          accent: ReleafFeatureAccents.sleep,
          onPressed: onSleep,
        );

        if (stacked) {
          return Column(
            children: [
              meditate,
              const SizedBox(height: ReleafSpacing.sm),
              sleep,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: meditate),
            const SizedBox(width: ReleafSpacing.sm),
            Expanded(child: sleep),
          ],
        );
      },
    );
  }
}
"""
new_destinations = """class _SoundDestinations extends StatelessWidget {
  const _SoundDestinations({required this.onSleep});

  final VoidCallback onSleep;

  @override
  Widget build(BuildContext context) {
    return _SoundDestinationCard(
      key: const Key('sound-open-sleep'),
      icon: Icons.bedtime_outlined,
      eyebrow: 'NO VOICE',
      title: 'Sleep',
      description:
          'Low-stimulation tones and nature sound designed for the end of the day.',
      accent: ReleafFeatureAccents.sleep,
      onPressed: onSleep,
    );
  }
}
"""
sound = replace_once(
    sound,
    old_destinations,
    new_destinations,
    'collapse Sound destinations to Sleep only',
)

sound_path.write_text(sound, encoding='utf-8')


test_path = Path('test/five_primary_destinations_test.dart')
test = test_path.read_text(encoding='utf-8')
old_assertion = "      expect(find.byKey(const Key('sound-open-meditate')), findsOneWidget);\n"
new_assertion = (
    "      expect(find.byKey(const Key('sound-open-meditate')), findsNothing);\n"
    "      expect(find.byKey(const Key('sound-open-sleep')), findsOneWidget);\n"
)
count = test.count(old_assertion)
if count != 2:
    raise SystemExit(
        f'update Sound destination expectations: expected exactly two matches, found {count}'
    )
test = test.replace(old_assertion, new_assertion)
test_path.write_text(test, encoding='utf-8')

print('Sound no longer discovers parked Meditate; direct Meditate route remains untouched.')
