import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioCatalogProvider = Provider<AudioCatalog>((ref) {
  return const AudioCatalog();
});

class ReliefSession {
  final String id;
  final String title;
  final int durationSeconds;
  final List<String> instructions;
  final bool isPremiumOnly;
  final bool isEmergency;

  const ReliefSession({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.instructions,
    this.isPremiumOnly = false,
    this.isEmergency = false,
  });
}

class AudioCatalog {
  const AudioCatalog();

  static const emergencySessionId = 'emergency-grounding';

  List<ReliefSession> getSessions() => const [
    ReliefSession(
      id: emergencySessionId,
      title: 'Emergency Grounding',
      durationSeconds: 120,
      isEmergency: true,
      instructions: [
        'Place both feet on the floor and notice the support beneath you.',
        'Look around and name five things you can see.',
        'Notice four things you can physically feel around you.',
        'Listen for three sounds without trying to change them.',
        'Continue at your own pace. You can stop at any time.',
      ],
    ),
    ReliefSession(
      id: '60s-grounding',
      title: '60s Grounding',
      durationSeconds: 60,
      instructions: [
        'Sit comfortably and place your feet on the ground.',
        'Take a deep breath in through your nose and exhale slowly.',
        'Notice the sensations in your body and the contact with the chair.',
        'Let thoughts come and go without judgement.',
      ],
    ),
    ReliefSession(
      id: '90s-calm-down',
      title: '90s Calm Down',
      durationSeconds: 90,
      instructions: [
        'Close your eyes if you feel comfortable.',
        'Breathe deeply, counting slowly to four on each inhale and exhale.',
        'Relax your shoulders and unclench your jaw.',
        'Imagine a peaceful place and allow your body to soften.',
      ],
    ),
    ReliefSession(
      id: '3min-breath',
      title: '3 min Deep Reset',
      durationSeconds: 180,
      isPremiumOnly: true,
      instructions: [
        'Inhale through your nose for 4 seconds.',
        'Hold your breath for 4 seconds.',
        'Exhale slowly through your mouth for 4 seconds.',
        'Pause for 4 seconds, then repeat.',
      ],
    ),
    ReliefSession(
      id: '5min-focus',
      title: '5 min Focus Anchor',
      durationSeconds: 300,
      isPremiumOnly: true,
      instructions: [
        'Name five things you can see around you.',
        'Name four things you can touch.',
        'Name three things you can hear.',
        'Name two things you can smell.',
        'Name one thing you can taste.',
      ],
    ),
  ];

  List<ReliefSession> getRegularSessions() {
    return getSessions().where((session) => !session.isEmergency).toList();
  }

  ReliefSession? getById(String id) {
    for (final session in getSessions()) {
      if (session.id == id) return session;
    }
    return null;
  }
}
