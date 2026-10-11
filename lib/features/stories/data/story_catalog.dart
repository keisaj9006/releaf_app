import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/relief_story.dart';

const _ownerPreviewAudioBundled = bool.fromEnvironment(
  'RELIEF_STORIES_AUDIO_BUNDLED',
  defaultValue: false,
);

final storyByIdProvider = Provider.family<ReliefStory?, String>((ref, id) {
  return StoryCatalog.getById(id);
});

abstract final class StoryCatalog {
  static const ownerPreview = <ReliefStory>[
    ReliefStory(
      id: 'TS01_BEYOND_THE_GATE',
      title: 'Beyond the Gate',
      subtitle:
          'The True Story of Four Prisoners and an Impossible Plan at Auschwitz',
      series: 'True Stories of Courage',
      category: StoryCategory.trueStoriesOfCourage,
      description:
          'Four prisoners find a sequence of openings inside a system designed to make escape impossible.',
      estimatedDuration: Duration(seconds: 1971),
      audioAssetPath: _ownerPreviewAudioBundled
          ? 'audio/stories/ST_TS01_BEYOND_THE_GATE_v01_128k.m4a'
          : null,
      artworkAssetPath: 'assets/art/relief/sleep_stories.webp',
      contentWarning:
          'This true story discusses imprisonment at Auschwitz and escape during the Second World War. It contains no graphic descriptions.',
      labels: <String>['TRUE STORY', 'WORLD WAR II', 'NON-GRAPHIC'],
      isPremium: false,
      chapters: <ReliefStoryChapter>[],
      rightsStatus: 'OWNER PREVIEW — RELEASE REVIEW PENDING',
      scriptVersion: '2.0',
      audioVersion: 'owner-preview app delivery v1 (128 kb/s AAC)',
    ),
    ReliefStory(
      id: 'TS02_KRYSTYNA_SKARBEK',
      title: 'The Woman Who Crossed Every Border',
      subtitle:
          'The True Story of Krystyna Skarbek and the Impossible Choices She Refused to Accept',
      series: 'True Stories of Courage',
      category: StoryCategory.trueStoriesOfCourage,
      description:
          'A Polish intelligence agent repeatedly looks for movement inside situations that appear completely closed.',
      estimatedDuration: Duration(seconds: 2198),
      audioAssetPath: _ownerPreviewAudioBundled
          ? 'audio/stories/ST_TS02_KRYSTYNA_SKARBEK_v01_128k.m4a'
          : null,
      artworkAssetPath: 'assets/art/relief/sleep_stories.webp',
      contentWarning:
          'This true story discusses wartime imprisonment, Gestapo arrest, stalking and a post-war murder. It contains no graphic descriptions.',
      labels: <String>['TRUE STORY', 'WORLD WAR II', 'NON-GRAPHIC'],
      isPremium: false,
      chapters: <ReliefStoryChapter>[],
      rightsStatus: 'OWNER PREVIEW — RELEASE REVIEW PENDING',
      scriptVersion: '2.0',
      audioVersion: 'owner-preview app delivery v1 (128 kb/s AAC)',
    ),
    ReliefStory(
      id: 'ST_L05_COMPUTER',
      title: 'Computer',
      subtitle: 'A quiet reflection on memory, technology and connection',
      series: 'Modern Reflections',
      category: StoryCategory.meaningStories,
      description:
          'A contemplative long-form story about what technology can preserve, what it cannot replace and the traces people leave behind.',
      estimatedDuration: Duration(seconds: 1245),
      audioAssetPath: _ownerPreviewAudioBundled
          ? 'audio/stories/ST_L05_COMPUTER_v01_128k.m4a'
          : null,
      artworkAssetPath: 'assets/art/relief/sleep_stories.webp',
      contentWarning: '',
      labels: <String>['REFLECTIVE', 'MODERN STORY', 'NON-GRAPHIC'],
      isPremium: false,
      chapters: <ReliefStoryChapter>[],
      rightsStatus: 'OWNER PREVIEW — RELEASE REVIEW PENDING',
      scriptVersion: '1.0',
      audioVersion: 'owner-preview app delivery v1 (128 kb/s AAC)',
    ),
  ];

  static const sleepStories = <ReliefStory>[
    ReliefStory(
      id: 'ST-DC-004',
      title: 'The Princess and the Pea — A Rainy Night at the Palace',
      subtitle: 'A Dream Classics story currently in audio production.',
      series: 'Dream Classics',
      category: null,
      description:
          'A rain-soaked return to the palace, prepared as a long-form bedtime story.',
      estimatedDuration: null,
      audioAssetPath: null,
      artworkAssetPath: 'assets/art/relief/sleep_stories.webp',
      contentWarning: '',
      labels: <String>['DREAM CLASSICS'],
      isPremium: null,
      chapters: <ReliefStoryChapter>[],
      rightsStatus: 'PRODUCTION ASSETS PENDING',
      scriptVersion: 'pending',
      audioVersion: 'pending',
      sleepCollection: SleepStoryCollection.dreamClassics,
      narrator: 'Theo Silk',
    ),
  ];

  static const all = <ReliefStory>[...ownerPreview, ...sleepStories];

  static ReliefStory? getById(String id) {
    for (final story in all) {
      if (story.id == id) return story;
    }
    return null;
  }
}
