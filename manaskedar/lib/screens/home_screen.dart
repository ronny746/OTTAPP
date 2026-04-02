import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../utils/cache_manager.dart';
import '../controllers/main_controller.dart';
import '../controllers/interaction_controller.dart';
import '../models/media_item.dart';
import 'details_screen.dart';
import 'video_player_screen.dart';
import 'audio_player_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final MainController controller = Get.put(MainController());
  final InteractionController interactionCtrl = Get.put(InteractionController());

  @override
  Widget build(BuildContext context) {
    interactionCtrl.fetchWatchHistory(); // Fetch fresh history on build

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.banners.isNotEmpty) _buildBannerSlider(context, controller.banners),
            const SizedBox(height: 20),
            
            // --- CONTINUE WATCHING ---
            Obx(() => interactionCtrl.watchHistory.isNotEmpty 
              ? _buildHorizontalList(context, "continue_watching".tr, interactionCtrl.watchHistory, isHistory: true)
              : const SizedBox.shrink()
            ),

            if (controller.popularVideos.isNotEmpty) _buildHorizontalList(context, "popular_videos".tr, controller.popularVideos),
            
            // Reusing popularVideos for recommended/trending for now till backend is updated
            if (controller.popularVideos.isNotEmpty) _buildHorizontalList(context, "recommended".tr, controller.popularVideos.reversed.toList()),
            
            if (controller.audiobooks.isNotEmpty) _buildHorizontalList(context, "audiobooks".tr, controller.audiobooks),
            
            if (controller.popularVideos.isNotEmpty) _buildHorizontalList(context, "trending_now".tr, controller.popularVideos),
            
            if (controller.shows.isNotEmpty) _buildHorizontalList(context, "shows".tr, controller.shows),
            const SizedBox(height: 100),
          ],
        ),
      );
    });
  }

  Widget _buildBannerSlider(BuildContext context, List<MediaItem> items) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 500,
        viewportFraction: 1,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 8),
      ),
      items: items.map((item) {
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailsScreen(item: item)));
            interactionCtrl.fetchWatchHistory();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                cacheManager: CustomCacheManager.instance,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[900]),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                      Colors.black,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      item.title.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "manaskedar_original".tr,
                      style: const TextStyle(color: Colors.white60, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🔥 PREMIUM PLAY BUTTON (BANNER)
                        GestureDetector(
                          onTap: () async {
                             await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailsScreen(item: item)));
                             interactionCtrl.fetchWatchHistory();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                              ],
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white, Color(0xFFE0E0E0)],
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
                                const SizedBox(width: 8),
                                Text("play".tr.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // ℹ️ PREMIUM INFO BUTTON (BANNER)
                        GestureDetector(
                          onTap: () async {
                             await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailsScreen(item: item)));
                             interactionCtrl.fetchWatchHistory();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text("info".tr.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalList(BuildContext context, String title, List<MediaItem> items, {bool isHistory = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          height: isHistory ? 140 : 180, // slightly smaller height for history thumbnails
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (ctx, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () async {
                  if (item.type == 'short') {
                     controller.playShort(item);
                  } else if (isHistory) {
                    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: item)));
                  } else if (item.type == 'audio') {
                    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => AudioPlayerScreen(item: item)));
                  } else {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailsScreen(item: item)));
                  }
                  // Refresh history when returning from any player or details screen
                  interactionCtrl.fetchWatchHistory();
                },
                child: Container(
                  width: isHistory ? 160 : 125, // wider thumbnails for history
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          cacheManager: CustomCacheManager.instance,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[900]),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      if (isHistory) ...[
                        const Positioned.fill(
                          child: Icon(Icons.play_circle_filled, color: Colors.white70, size: 40),
                        ),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              // Mocking 40% progress if not available, since we don't have total seconds in the model yet, 
                              // but we'll show progress bar to indicate it's "Continue"
                              widthFactor: 0.4, 
                              child: Container(color: AppTheme.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
