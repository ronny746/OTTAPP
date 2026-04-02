import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/global_audio_controller.dart';
import '../screens/audio_player_screen.dart';


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

      return GestureDetector(
        onTap: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => AudioPlayerScreen(item: item))),
        child: Container(
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.95),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Manaskedar Original",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => audioController.togglePlay(),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 24),
                onPressed: () {
                  audioController.isMiniPlayerVisible.value = false;
                  audioController.audioPlayer.stop();
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
