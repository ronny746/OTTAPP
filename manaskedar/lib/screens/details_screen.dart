import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manaskedar/models/media_item.dart';
import 'package:manaskedar/utils/app_theme.dart';
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
                    widget.item.title.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 5),
                      Text(widget.item.rating, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 15),
                      Text(widget.item.year, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(widget.item.type.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: 15),
                      Text(widget.item.duration, style: const TextStyle(color: Colors.white60, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.item.description,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 25),
                    GestureDetector(
                      onTap: () {
                         if (_initialized) _trailerPlayer.controller.pause();
                          
                          late MediaItem playMedia;
                          if (widget.item.type == 'show' && widget.item.episodes.isNotEmpty) {
                             final ep = widget.item.episodes.first;
                             playMedia = MediaItem(
                               id: "${widget.item.id}_0",
                               title: "${widget.item.title} - ${ep.title}",
                               imageUrl: ep.imageUrl ?? widget.item.imageUrl,
                               videoUrl: ep.videoUrl,
                               type: 'video', 
                               description: ep.description ?? widget.item.description,
                             );
                          } else {
                             playMedia = widget.item;
                          }

                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: playMedia)),
                          );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0xFFE0E0E0)],
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, color: Colors.black, size: 32),
                            SizedBox(width: 8),
                            Text(
                              "PLAY", 
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GetBuilder<InteractionController>(
                          init: Get.find<InteractionController>(),
                          builder: (ctrl) => _actionButton(
                            widget.item.isFavorite ? Icons.check_circle : Icons.add_circle_outline,
                            "My List",
                            () => ctrl.toggleFavorite(widget.item),
                            color: widget.item.isFavorite ? Colors.red : Colors.white,
                          ),
                        ),
                        _actionButton(Icons.share_outlined, "Share", () {
                           Get.find<InteractionController>().incrementShare(widget.item);
                        }),
                        _actionButton(Icons.thumb_up_alt_outlined, "Rate", () {}),
                      ],
                    ),
                  const SizedBox(height: 35),
                  
                  // --- CAST SECTION (PREMIUM) ---
                  const Text("Top Cast", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, i) => Container(
                        width: 85,
                        margin: const EdgeInsets.only(right: 15),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white10,
                              backgroundImage: const NetworkImage("https://www.w3schools.com/howto/img_avatar.png"),
                            ),
                            const SizedBox(height: 8),
                            const Text("Actor Name", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                // --- EPISODES SECTION ---
                if (widget.item.episodes.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "EPISODES", 
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                      ),
                      Text(
                        "${widget.item.episodes.length} EPISODES",
                        style: const TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.item.episodes.length,
                    itemBuilder: (context, index) {
                      final ep = widget.item.episodes[index];
                      return GestureDetector(
                        onTap: () {
                          if (_initialized) _trailerPlayer.controller.pause();
                          final epMedia = MediaItem(
                            id: "${widget.item.id}_$index", 
                            title: ep.title,
                            imageUrl: ep.imageUrl ?? widget.item.imageUrl,
                            videoUrl: ep.videoUrl,
                            type: 'video',
                            description: ep.description ?? widget.item.description,
                          );
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: epMedia)),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              // 🎥 EPISODE PREVIEW (NETFLIX STYLE)
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: ep.imageUrl ?? widget.item.imageUrl,
                                      width: 140,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    width: 140,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.play_circle_filled_rounded, color: Colors.white.withOpacity(0.8), size: 40),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    left: 8,
                                    child: Text(
                                      "EP ${index + 1}",
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ep.title,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      ep.duration,
                                      style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      ep.description ?? widget.item.description,
                                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, height: 1.3),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

Widget _actionButton(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
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

