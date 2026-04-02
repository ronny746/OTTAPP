import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:manaskedar/models/media_item.dart';
import '../utils/cache_manager.dart';

import '../controllers/global_audio_controller.dart';
import '../controllers/download_controller.dart';
import '../controllers/main_controller.dart';

class AudiobooksScreen extends StatelessWidget {
  const AudiobooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<GlobalAudioController>();
    final dataController = Get.find<MainController>();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("TRENDING AUDIOBOOKS", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 20),
                   Obx(() {
                     if (dataController.audiobooks.isEmpty) {
                       return const Center(child: CircularProgressIndicator(color: Colors.red));
                     }
                     return ListView.builder(
                      itemCount: dataController.audiobooks.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final item = dataController.audiobooks[index];
                        return _buildAudioItem(context, item, audioController);
                      },
                     );
                   }),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 250, // Reduced height for a cleaner look
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red,
            Colors.black,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.headset, size: 60, color: Colors.white),
          const SizedBox(height: 15),
          const Text("Audiobook Collection", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAudioItem(BuildContext context, MediaItem item, GlobalAudioController audioController) {
    return GestureDetector(
      onTap: () {
        audioController.playNew(item);
        // Only trigger playback, don't navigate (User will use MiniPlayer to expand)
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl, 
                width: 80, 
                height: 80, 
                fit: BoxFit.cover,
                cacheManager: CustomCacheManager.instance,
                placeholder: (context, url) => Container(color: Colors.grey[900]),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Narrated by AI", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white60, size: 28),
              onPressed: () {
                final downloadController = Get.put(DownloadController());
                downloadController.startDownload(item);
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
              onPressed: () {
                audioController.playNew(item);
              },
            ),
          ],
        ),
      ),
    );
  }
}
