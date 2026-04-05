import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manaskedar/models/media_item.dart';
import '../utils/cache_manager.dart';
import '../utils/app_theme.dart';
import '../controllers/global_audio_controller.dart';
import '../controllers/download_controller.dart';
import '../controllers/main_controller.dart';

import '../widgets/spiritual_background.dart';
import '../widgets/spiritual_shimmer.dart';

class AudiobooksScreen extends StatelessWidget {
  const AudiobooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<GlobalAudioController>();
    final dataController = Get.find<MainController>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SpiritualBackground(
        child: Obx(() {
                 if (dataController.isLoading.value) {
                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SpiritualShimmer.appHeader(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            child: Column(
                              children: List.generate(5, (index) => SpiritualShimmer.listTile()),
                            ),
                          ),
                        ],
                      ),
                    );
                 }
                 return SingleChildScrollView(
                   physics: const BouncingScrollPhysics(),
                   child: Column(
                    children: [
                      _buildAppBar(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                               children: [
                                 Container(width: 4, height: 24, color: AppTheme.primaryColor),
                                 const SizedBox(width: 12),
                                 Text(
                                   "TRENDING_AUDIOBOOKS".tr, 
                                   style: GoogleFonts.cinzel(color: AppTheme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                                 ),
                               ],
                             ),
                             const SizedBox(height: 30),
                             ListView.builder(
                                itemCount: dataController.audiobooks.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final item = dataController.audiobooks[index];
                                  return _buildAudioItem(context, item, audioController);
                                },
                             ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                   ),
                 );
              }),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
           // Abstract Cosmic Pattern or Saffron Glow
           Positioned(
             top: -50,
             child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.04),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.08), blurRadius: 100, spreadRadius: 50),
                  ],
                ),
             ),
           ),
           Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.05), blurRadius: 20, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.headset_rounded, size: 50, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 25),
              Text(
                "AUDIO_COLLECTION".tr, 
                style: GoogleFonts.cinzel(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2.5)
              ),
              const SizedBox(height: 10),
              Text(
                "LISTEN_TO_DIVINE_WISDOM".tr, 
                style: GoogleFonts.lato(color: Colors.white38, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioItem(BuildContext context, MediaItem item, GlobalAudioController audioController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl, 
              width: 80, 
              height: 80, 
              fit: BoxFit.cover,
              cacheManager: CustomCacheManager.instance,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.toUpperCase(), 
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "DIVINE_NARRATION".tr, 
                  style: GoogleFonts.lato(color: AppTheme.primaryColor.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white24, size: 24),
            onPressed: () {
              final downloadController = Get.put(DownloadController());
              downloadController.startDownload(item);
            },
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => audioController.playNew(item),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
