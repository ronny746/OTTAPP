import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manaskedar/utils/app_theme.dart';
import '../controllers/global_audio_controller.dart';


class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<GlobalAudioController>();

    return Obx(() {
      if (audioController.currentItem.value == null || !audioController.isMiniPlayerVisible.value || audioController.isMainPlayerOpen.value) {
        return const SizedBox.shrink();
      }

      final item = audioController.currentItem.value!;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
              ),
              child: Stack(
                children: [
                   // 📊 MINI PROGRESS LINE
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: StreamBuilder<Duration>(
                      stream: audioController.audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final pos = snapshot.data ?? Duration.zero;
                        final duration = audioController.audioPlayer.duration ?? Duration.zero;
                        double progress = 0;
                        if (duration.inMilliseconds > 0) {
                           progress = pos.inMilliseconds / duration.inMilliseconds;
                        }
                        return LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 2,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        );
                      }
                    ),
                  ),

                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Hero(
                          tag: 'player_${item.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "NOW PLAYING",
                              style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          audioController.isPlaying.value ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () => audioController.togglePlay(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 24),
                        onPressed: () {
                          audioController.isMiniPlayerVisible.value = false;
                          audioController.audioPlayer.stop();
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
