// FILE: lib/features/relief/data/audio_catalog.dart
class AudioTrack {
  final String id;
  final String title;
  final String assetPath;

  const AudioTrack({required this.id, required this.title, required this.assetPath});
}

class AudioCatalog {
  static const tracks = <AudioTrack>[
    AudioTrack(id: 'relief01', title: 'Relief Audio 01', assetPath: 'audio/relief_01.mp3'),
    AudioTrack(id: 'relief02', title: 'Relief Audio 02', assetPath: 'audio/relief_02.mp3'),
  ];
}