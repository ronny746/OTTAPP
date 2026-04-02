import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/download_controller.dart';
import '../controllers/global_audio_controller.dart';

import 'video_player_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadController = Get.put(DownloadController());
    final audioController = Get.put(GlobalAudioController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("OFFLINE LIBRARY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (downloadController.downloadedItems.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: downloadController.downloadedItems.length,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          itemBuilder: (context, index) {
            final download = downloadController.downloadedItems[index];
            return _buildDownloadItem(context, download, downloadController, audioController);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download_for_offline_outlined, color: Colors.white24, size: 100),
          const SizedBox(height: 20),
          const Text("No downloads yet", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Content you download will appear here.", style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(BuildContext context, DownloadItem download, DownloadController controller, GlobalAudioController audioController) {
    return GestureDetector(
      onTap: () {
        if (download.status.value == DownloadStatus.completed) {
          if (download.item.type == 'video') {
             Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: download.item)),
              );
          } else if (download.item.type == 'audio') {
            audioController.playNew(download.item);
          }
        } else {
          Get.snackbar("Downloading", "Please wait until the download is complete.", 
            snackPosition: SnackPosition.BOTTOM, 
            backgroundColor: Colors.red.withOpacity(0.8), 
            colorText: Colors.white
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(imageUrl: download.item.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: Icon(
                      download.item.type == 'video' ? Icons.play_arrow : Icons.headset, 
                      color: Colors.white, 
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(download.item.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (download.status.value == DownloadStatus.downloading) {
                      return Column(
                        children: [
                          LinearProgressIndicator(
                            value: download.progress.value,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                          const SizedBox(height: 5),
                          Text("${(download.progress.value * 100).toInt()}% downloaded", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      );
                    } else if (download.status.value == DownloadStatus.completed) {
                      return const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text("Available Offline", style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      );
                    } else {
                      return const Text("Waiting for connection...", style: TextStyle(color: Colors.white30, fontSize: 12));
                    }
                  }),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white30),
              onPressed: () => controller.removeDownload(download.item.id),
            ),
          ],
        ),
      ),
    );
  }
}
