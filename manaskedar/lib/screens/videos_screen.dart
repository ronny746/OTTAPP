import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../models/media_item.dart';
import '../utils/cache_manager.dart';
import 'details_screen.dart';

class VideosScreen extends StatelessWidget {
  VideosScreen({super.key});

  final MainController controller = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = controller.popularVideos[index];
                  return _buildVideoCard(context, item);
                },
                childCount: controller.popularVideos.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      )),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 250,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: const Text(
          "EXPLORE VIDEOS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: controller.popularVideos.isNotEmpty ? controller.popularVideos[0].imageUrl : "https://placehold.co/600x400/png",
              cacheManager: CustomCacheManager.instance,
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, MediaItem item) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailsScreen(item: item))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.imageUrl, 
                    cacheManager: CustomCacheManager.instance,
                    fit: BoxFit.cover
                  ),
                  const Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      radius: 25,
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(item.duration, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
