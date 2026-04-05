import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../models/media_item.dart';
import '../utils/app_theme.dart';
import '../utils/cache_manager.dart';
import 'details_screen.dart';
import 'video_player_screen.dart';

import '../widgets/spiritual_background.dart';

class MediaGridScreen extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final bool isHistory;

  const MediaGridScreen({
    super.key,
    required this.title,
    required this.items,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title.toUpperCase().tr, 
          style: GoogleFonts.cinzel(
            color: AppTheme.primaryColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 18, 
            letterSpacing: 2
          )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SpiritualBackground(
        child: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isHistory ? Icons.history_toggle_off_rounded : Icons.favorite_border_rounded, size: 90, color: AppTheme.primaryColor.withOpacity(0.08)),
                    const SizedBox(height: 25),
                    Text(
                      "NO_ITEMS_FOUND".tr + " $title",
                      style: GoogleFonts.lato(color: Colors.white30, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      if (isHistory) {
                         Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: item)),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DetailsScreen(item: item)),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.12), width: 1),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.04), blurRadius: 10),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              cacheManager: CustomCacheManager.instance,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.black26),
                              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white10),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.2),
                                      Colors.black.withOpacity(0.6),
                                      Colors.black.withOpacity(0.9),
                                    ],
                                  ),
                                ),
                            ),
                            if (isHistory)
                              const Center(
                                child: Icon(Icons.play_circle_filled_rounded, color: Colors.white70, size: 35),
                              ),
                            Positioned(
                              bottom: 10,
                              left: 8,
                              right: 8,
                              child: Text(
                                item.title.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                              ),
                            ),
                             if (isHistory)
                              Positioned(
                                bottom: 0, left: 0, right: 0,
                                child: Container(
                                  height: 2,
                                  decoration: const BoxDecoration(color: Colors.white12),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.4, 
                                    child: Container(color: AppTheme.primaryColor),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
