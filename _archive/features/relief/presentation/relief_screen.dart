// FILE: lib/features/relief/presentation/relief_screen.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../data/audio_catalog.dart';
import 'breathing_widget.dart';

class ReliefScreen extends ConsumerStatefulWidget {
  const ReliefScreen({super.key});

  @override
  ConsumerState<ReliefScreen> createState() => _ReliefScreenState();
}

class _ReliefScreenState extends ConsumerState<ReliefScreen> {
  String? playingTrackId;
  PlayerState playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    final player = ref.read(audioPlayerProvider);

    player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => playerState = s);
    });
  }

  Future<void> _toggleTrack(AudioTrack track) async {
    final player = ref.read(audioPlayerProvider);

    if (playingTrackId == track.id && playerState == PlayerState.playing) {
      await player.pause();
      return;
    }

    setState(() => playingTrackId = track.id);
    await player.stop();
    await player.play(AssetSource(track.assetPath));
  }

  Future<void> _stop() async {
    final player = ref.read(audioPlayerProvider);
    await player.stop();
    setState(() => playingTrackId = null);
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = playerState == PlayerState.playing;

    return Scaffold(
      appBar: AppBar(title: const Text('Relief')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: SizedBox(
                height: 280,
                child: BreathingWidget(
                  totalSeconds: 60,
                  onFinished: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nice. Want a quick game next?')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isPlaying ? _stop : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop audio'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  const Text('Short audios (assets)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...AudioCatalog.tracks.map((t) {
                    final selected = t.id == playingTrackId;
                    return Card(
                      child: ListTile(
                        title: Text(t.title),
                        leading: Icon(selected && isPlaying ? Icons.pause_circle : Icons.play_circle),
                        onTap: () => _toggleTrack(t),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}