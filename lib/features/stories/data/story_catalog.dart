import '../domain/relief_story.dart';

abstract final class StoryCatalog {
  static const all = <ReliefStory>[
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
        ),
        ReliefStoryChapter(
          id: 'ts01-ch02',
          title: 'The Man Who Was Running Out of Time',
        ),
        ReliefStoryChapter(
          id: 'ts01-ch03',
          title: 'Four Things They Were Never Supposed to Have',
        ),
        ReliefStoryChapter(
          id: 'ts01-ch04',
          title: 'Saturday',
        ),
        ReliefStoryChapter(
          id: 'ts01-ch05',
          title: 'Act Like the Uniform',
        ),
        ReliefStoryChapter(
          id: 'ts01-ch06',
          title: 'What They Carried Out',
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
        ),
        ReliefStoryChapter(
          id: 'ts02-ch02',
          title: 'The Woman Who Went Back',
        ),
        ReliefStoryChapter(
          id: 'ts02-ch03',
          title: 'The Blood on the Handkerchief',
        ),
        ReliefStoryChapter(
          id: 'ts02-ch04',
          title: 'Dropped Into France',
        ),
        ReliefStoryChapter(
          id: 'ts02-ch05',
          title: 'Make Them Afraid of Tomorrow',
        ),
        ReliefStoryChapter(
          id: 'ts02-ch06',
          title: 'A Life Larger Than Its Ending',
        ),
      ],
      rightsStatus: 'NOT YET CLEARED FOR COMMERCIAL RELEASE',
      scriptVersion: '2.0',
      audioVersion: 'pending',
    ),
  ];

  static ReliefStory? getById(String id) {
    for (final story in all) {
      if (story.id == id) return story;
    }
    return null;
  }
}
