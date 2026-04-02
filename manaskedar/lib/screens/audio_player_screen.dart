import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:manaskedar/models/media_item.dart';

import '../utils/app_theme.dart';
import '../controllers/global_audio_controller.dart';

class AudioPlayerScreen extends StatefulWidget {
  final MediaItem item;
  const AudioPlayerScreen({super.key, required this.item});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final audioController = Get.find<GlobalAudioController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioController.isMainPlayerOpen.value = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioController.isMainPlayerOpen.value = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _audioPlayer = audioController.audioPlayer;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.withOpacity(0.3),
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 35), 
                  onPressed: () => Navigator.pop(context),
                ),
                const Text("PLAYING FROM AUDIOBOOK", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
              ],
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.item.imageUrl,
                height: 350,
                width: 350,
                fit: BoxFit.cover,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text("Manaskedar Original", style: TextStyle(color: Colors.white60, fontSize: 16)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white, size: 30), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 30),
            StreamBuilder<Duration?>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return ProgressBar(
                  progress: position,
                  buffered: _audioPlayer.bufferedPosition,
                  total: _audioPlayer.duration ?? Duration.zero,
                  onSeek: (duration) => _audioPlayer.seek(duration),
                  baseBarColor: Colors.white24,
                  progressBarColor: AppTheme.primaryColor,
                  bufferedBarColor: Colors.white10,
                  thumbColor: AppTheme.primaryColor,
                  barHeight: 4,
                  thumbRadius: 6,
                  timeLabelTextStyle: const TextStyle(color: Colors.white70),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(icon: const Icon(Icons.shuffle, color: Colors.white60), onPressed: () {}),
                IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 45), onPressed: () {}),
                Obx(() {
                  return IconButton(
                    icon: Icon(
                      audioController.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 85,
                    ),
                    onPressed: () => audioController.togglePlay(),
                  );
                }),
                IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 45), onPressed: () {}),
                IconButton(icon: const Icon(Icons.repeat, color: Colors.white60), onPressed: () {}),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
