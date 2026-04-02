import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../utils/app_theme.dart';
import '../utils/cache_manager.dart';
import 'details_screen.dart';
import 'video_player_screen.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isHistory ? Icons.history : Icons.favorite_border, size: 80, color: Colors.white24),
                  const SizedBox(height: 20),
                  Text(
                    "No items found in $title",
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
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
                            if (isHistory)
                              const Positioned.fill(
                                child: Icon(Icons.play_circle_filled, color: Colors.white70, size: 40),
                              ),
                             if (isHistory)
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
                                    widthFactor: 0.4, 
                                    child: Container(color: AppTheme.primaryColor),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        item.type.toUpperCase(),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
