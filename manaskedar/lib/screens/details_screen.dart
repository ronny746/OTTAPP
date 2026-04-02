import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manaskedar/models/media_item.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:get/get.dart';
import '../utils/cache_manager.dart';
import '../controllers/download_controller.dart';
import '../controllers/interaction_controller.dart';
import 'video_player_screen.dart';

class DetailsScreen extends StatefulWidget {
  final MediaItem item;
  const DetailsScreen({super.key, required this.item});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late CachedVideoPlayerPlus _trailerPlayer;
  bool _isMuted = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _trailerPlayer = CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.item.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _trailerPlayer.controller.setVolume(0.0);
          _trailerPlayer.controller.setLooping(true);
          _trailerPlayer.controller.play();
        });
      });
  }

  @override
  void dispose() {
    if (_initialized) _trailerPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _initialized
                      ? AspectRatio(
                          aspectRatio: _trailerPlayer.controller.value.aspectRatio,
                          child: VideoPlayer(_trailerPlayer.controller),
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.item.imageUrl,
                          cacheManager: CustomCacheManager.instance,
                          fit: BoxFit.cover,
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: IconButton(
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                          _trailerPlayer.controller.setVolume(_isMuted ? 0.0 : 1.0);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(widget.item.year, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("HD", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 15),
                      Text(widget.item.duration, style: const TextStyle(color: Colors.white60, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_initialized) _trailerPlayer.controller.pause();
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: widget.item)),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                        label: const Text("PLAY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final downloadController = Get.put(DownloadController());
                          downloadController.startDownload(widget.item);
                        },
                        icon: const Icon(Icons.download, color: Colors.white, size: 24),
                        label: const Text("DOWNLOAD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[900],
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                
                // --- EPISODES SECTION ---
                if (widget.item.episodes.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Episodes",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.item.episodes.length,
                    itemBuilder: (context, index) {
                      final ep = widget.item.episodes[index];
                      return ListTile(
                        onTap: () {
                          // Create a dummy MediaItem for the episode to play it in the same player
                          final epMedia = MediaItem(
                            id: "${widget.item.id}_${index}", 
                            title: ep.title,
                            imageUrl: ep.imageUrl ?? widget.item.imageUrl,
                            videoUrl: ep.videoUrl,
                            type: 'video',
                            description: ep.description ?? widget.item.description,
                          );
                          Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: epMedia)));
                        },
                        leading: Container(
                          width: 100,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(ep.imageUrl ?? widget.item.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: const Center(child: Icon(Icons.play_arrow, color: Colors.white)),
                        ),
                        title: Text(ep.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text(ep.duration, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        trailing: const Icon(Icons.download_outlined, color: Colors.white38),
                      );
                    },
                  ),
                ],
                
                const SizedBox(height: 30),
                  Text(
                    widget.item.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  GetBuilder<InteractionController>(
                    init: InteractionController(),
                    builder: (interactionCtrl) {
                      return Row(
                        children: [
                          _DetailAction(
                            widget.item.isFavorite ? Icons.check : Icons.add, 
                            "my_list".tr, 
                            () async {
                              await interactionCtrl.toggleFavorite(widget.item);
                              setState(() {});
                            },
                            color: widget.item.isFavorite ? Colors.red : Colors.white,
                          ),
                          const SizedBox(width: 40),
                          _DetailAction(
                            Icons.thumb_up_alt_outlined, 
                            widget.item.formattedLikes, 
                            () async {
                              await interactionCtrl.toggleLike(widget.item);
                              setState(() {}); // refresh local state
                            },
                            color: widget.item.isLikedByMe ? Colors.red : Colors.white,
                          ),
                          const SizedBox(width: 40),
                          _DetailAction(
                            Icons.share_outlined, 
                            "share".tr, 
                            () async {
                              await interactionCtrl.incrementShare(widget.item);
                              setState(() {});
                            },
                            color: widget.item.isSharedLocally ? Colors.red : Colors.white,
                          ),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  const _DetailAction(this.icon, this.label, this.onTap, {this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color == Colors.white ? Colors.grey : color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

