import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/relief_story.dart';

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
      estimatedDuration: Duration(minutes: 28),
      audioAssetPath: null,
      artworkAssetPath: null,
      contentWarning:
          'This true story discusses imprisonment at Auschwitz and escape during the Second World War. It contains no graphic descriptions.',
      labels: <String>['TRUE STORY', 'WORLD WAR II', 'NON-GRAPHIC'],
      isPremium: false,
      chapters: <ReliefStoryChapter>[
        ReliefStoryChapter(
          id: 'ts01-ch01',
          title: 'The Barrier',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts01-ch02',
          title: 'The Man Who Was Running Out of Time',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts01-ch03',
          title: 'Four Things They Were Never Supposed to Have',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts01-ch04',
          title: 'Saturday',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts01-ch05',
          title: 'Act Like the Uniform',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts01-ch06',
          title: 'What They Carried Out',
          start: Duration.zero,
        ),
      ],
      rightsStatus: 'NOT YET CLEARED FOR COMMERCIAL RELEASE',
      scriptVersion: '2.0',
      audioVersion: 'pending',
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
      estimatedDuration: Duration(minutes: 28),
      audioAssetPath: null,
      artworkAssetPath: null,
      contentWarning:
          'This true story discusses wartime imprisonment, Gestapo arrest, stalking and a post-war murder. It contains no graphic descriptions.',
      labels: <String>['TRUE STORY', 'WORLD WAR II', 'NON-GRAPHIC'],
      isPremium: false,
      chapters: <ReliefStoryChapter>[
        ReliefStoryChapter(
          id: 'ts02-ch01',
          title: 'Three Men Were Waiting to Die',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts02-ch02',
          title: 'The Woman Who Went Back',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts02-ch03',
          title: 'The Blood on the Handkerchief',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts02-ch04',
          title: 'Dropped Into France',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts02-ch05',
          title: 'Make Them Afraid of Tomorrow',
          start: Duration.zero,
        ),
        ReliefStoryChapter(
          id: 'ts02-ch06',
          title: 'A Life Larger Than Its Ending',
          start: Duration.zero,
        ),
      ],
      rightsStatus: 'NOT YET CLEARED FOR COMMERCIAL RELEASE',
      scriptVersion: '2.0',
      audioVersion: 'pending',
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
      artworkAssetPath: null,
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
