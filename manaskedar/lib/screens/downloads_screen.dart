import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/download_controller.dart';
import '../controllers/global_audio_controller.dart';
import '../utils/app_theme.dart';
import 'video_player_screen.dart';

import '../widgets/spiritual_background.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadController = Get.put(DownloadController());
    final audioController = Get.put(GlobalAudioController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "OFFLINE_LIBRARY".tr, 
          style: GoogleFonts.cinzel(
            color: AppTheme.primaryColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 18, 
            letterSpacing: 2.0
          )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), 
          onPressed: () => Navigator.pop(context)
        ),
        centerTitle: true,
      ),
      body: SpiritualBackground(
        child: Obx(() {
          if (downloadController.downloadedItems.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: downloadController.downloadedItems.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            itemBuilder: (context, index) {
              final download = downloadController.downloadedItems[index];
              return _buildDownloadItem(context, download, downloadController, audioController);
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_download_outlined, color: AppTheme.primaryColor.withOpacity(0.08), size: 120),
          const SizedBox(height: 35),
          Text(
            "NO_DOWNLOADS_YET".tr, 
            style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)
          ),
          const SizedBox(height: 12),
          Text(
            "DOWNLOAD_CONTENT_MESSAGE".tr, 
            style: GoogleFonts.lato(color: Colors.white30, fontSize: 13, fontWeight: FontWeight.bold)
          ),
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
          Get.snackbar("DOWNLOADING".tr, "PLEASE_WAIT_MESSAGE".tr, 
            snackPosition: SnackPosition.BOTTOM, 
            backgroundColor: AppTheme.backgroundColor, 
            colorText: Colors.white
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.12), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black38, blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(imageUrl: download.item.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    download.item.title.toUpperCase(), 
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (download.status.value == DownloadStatus.downloading) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: download.progress.value,
                              backgroundColor: Colors.white10,
                              minHeight: 4,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("${(download.progress.value * 100).toInt()}% " + "DOWNLOADED".tr, style: GoogleFonts.lato(color: AppTheme.primaryColor.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      );
                    } else if (download.status.value == DownloadStatus.completed) {
                      return Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 16),
                          const SizedBox(width: 8),
                          Text("AVAILABLE_OFFLINE".tr, style: GoogleFonts.lato(color: AppTheme.primaryColor.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      );
                    } else {
                      return Text("WAITING_MESSAGE".tr, style: GoogleFonts.lato(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold));
                    }
                  }),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24, size: 24),
              onPressed: () => controller.removeDownload(download.item.id),
            ),
          ],
        ),
      ),
    );
  }
}
