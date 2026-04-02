import 'package:flutter/material.dart';
import 'package:manaskedar/models/media_item.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/cache_manager.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../widgets/comment_sheet.dart';
import '../controllers/main_screen_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/interaction_controller.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  _ShortsScreenState createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final MainScreenController _mainController = Get.find<MainScreenController>();
  final MainController _dataController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(() => PageView.builder(
            controller: _dataController.shortsPageController,
            scrollDirection: Axis.vertical,
            itemCount: _dataController.filteredShorts.length,
            onPageChanged: (idx) => _dataController.currentShortIndex.value = idx,
            itemBuilder: (context, index) {
              final short = _dataController.filteredShorts[index];
              return Obx(() {
                final bool isActiveTab = _mainController.selectedIndex.value == 2;
                final bool isCurrentPage = _dataController.currentShortIndex.value == index;
                return ShortVideoItem(
                   item: short, 
                   isActive: isActiveTab && isCurrentPage
                );
              });
            },
          )),

            // 🔥 CATEGORY BAR (PREMIUM)
            // Positioned(
            //   top: 50,
            //   left: 0,
            //   right: 0,
            //   child: SizedBox(
            //     height: 40,
            //     child: Obx(() => ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       padding: const EdgeInsets.symmetric(horizontal: 15),
            //       itemCount: _dataController.categoriesList.length,
            //       itemBuilder: (context, i) {
            //         final cat = _dataController.categoriesList[i];
            //         final bool isSel = _dataController.selectedShortsCategory.value == cat;
            //         return GestureDetector(
            //           onTap: () {
            //             _dataController.selectedShortsCategory.value = cat;
            //             _dataController.shortsPageController.jumpToPage(0);
            //             _dataController.currentShortIndex.value = 0;
            //           },
            //           child: Container(
            //             margin: const EdgeInsets.only(right: 10),
            //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            //             decoration: BoxDecoration(
            //               color: isSel ? AppTheme.primaryColor : Colors.black.withOpacity(0.4),
            //               borderRadius: BorderRadius.circular(20),
            //               border: Border.all(color: isSel ? Colors.transparent : Colors.white24),
            //             ),
            //             child: Center(
            //               child: Text(
            //                 cat.toUpperCase(),
            //                 style: TextStyle(
            //                   color: isSel ? Colors.white : Colors.white70,
            //                   fontSize: 11,
            //                   fontWeight: FontWeight.w900,
            //                   letterSpacing: 1.0,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         );
            //       },
            //     )),
            //   ),
            // ),
          ],
        ),
    );
  }
}

class ShortVideoItem extends StatefulWidget {
  final MediaItem item;
  final bool isActive;
  const ShortVideoItem({super.key, required this.item, required this.isActive});

  @override
  _ShortVideoItemState createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends State<ShortVideoItem> {
  late CachedVideoPlayerPlus _player;
  bool _initialized = false;
  bool _showIcon = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _player =
        CachedVideoPlayerPlus.networkUrl(
            Uri.parse(widget.item.videoUrl),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _initialized = true;
                if (widget.isActive) _player.controller.play();
                _player.controller.setLooping(true);
              });
            }
          });
  }

  @override
  void didUpdateWidget(ShortVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 🔄 RE-INITIALIZE IF ITEM CHANGES (VITAL FOR SCROLLING)
    if (widget.item.videoUrl != oldWidget.item.videoUrl) {
      if (_initialized) {
        _player.controller.pause();
        _player.dispose();
        setState(() => _initialized = false);
      }
      _initController();
    } 
    // ⏯️ TOGGLE PLAY/PAUSE BASED ON FOCUS
    else if (widget.isActive != oldWidget.isActive && _initialized) {
      if (widget.isActive) {
        _player.controller.play();
      } else {
        _player.controller.pause();
      }
    }
  }

  @override
  void dispose() {
    if (_initialized) _player.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized) return;
    setState(() {
      if (_player.controller.value.isPlaying) {
        _player.controller.pause();
        _showIcon = true; // Stay visible now that it's paused
      } else {
        _player.controller.play();
        _showIcon = true;
        // Hide after delay since it's now playing
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && _player.controller.value.isPlaying) {
            setState(() => _showIcon = false);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 🎥 Background Layer (Thumbnail -> Video)
          Positioned.fill(
            child: GestureDetector(
              onDoubleTap: () async {
                final ctrl = Get.put(InteractionController());
                await ctrl.toggleLike(widget.item);
                setState(() {});
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 🖼️ Thumbnail always there as fallback
                  CachedNetworkImage(
                    imageUrl: widget.item.imageUrl,
                    cacheManager: CustomCacheManager.instance,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.black,
                      child: const Center(child: CircularProgressIndicator(color: Colors.red, strokeWidth: 1.5)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image_rounded, color: Colors.white24, size: 40),
                    ),
                  ),
                  // 🎬 Video takes over when ready
                  if (_initialized)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _player.controller.value.size.width,
                        height: _player.controller.value.size.height,
                        child: VideoPlayer(_player.controller),
                      ),
                    ),
                  // 🚀 Subtle loader ONLY for video surface
                  if (!_initialized)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 🎮 Play/Pause Center Indication
          if (_showIcon ||
              (_initialized && !_player.controller.value.isPlaying))
            Center(
              child: Opacity(
                opacity: 0.6,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 40,
                  child: Icon(
                    (_initialized && _player.controller.value.isPlaying)
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          // 🌘 Gradient Overlay for Readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 📝 Detail Layer (Pinned - Always Visible)
          Positioned(
            bottom: 30,
            left: 20,
            right: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Flexible(
                      child: Text(
                        "@manaskedar_official",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  widget.item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.white, size: 18),
                    SizedBox(width: 5),
                    Text(
                      "Manaskedar - Original Sound",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ⚡ Action Layer (Pinned)
          Positioned(
            bottom: 30,
            right: 20,
            child: GetBuilder<InteractionController>(
              init: InteractionController(),
              builder: (interactionCtrl) {
                return Column(
                  children: [
                    _shortsAction(
                      Icons.favorite,
                      widget.item.formattedLikes,
                      () async {
                        await interactionCtrl.toggleLike(widget.item);
                        setState(() {});
                      },
                      color: widget.item.isLikedByMe
                          ? Colors.red
                          : Colors.white,
                    ),
                    _shortsAction(
                      Icons.comment,
                      widget.item.formattedComments,
                      () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CommentSheet(item: widget.item),
                        ).then(
                          (_) => setState(() {}),
                        ); // refresh counts when closed
                      },
                    ),
                    _shortsAction(
                      Icons.share,
                      widget.item.formattedShares,
                      () async {
                        await interactionCtrl.incrementShare(widget.item);
                        setState(() {});
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          
          // 📊 ULTRA-THIN PROGRESS LINE
          // 📊 ADVANCED DOTTED PROGRESS (PREMIUM STYLE)
          if (_initialized)
            Positioned(
              bottom: 4,
              left: 15,
              right: 15,
              child: ValueListenableBuilder(
                valueListenable: _player.controller,
                builder: (context, VideoPlayerValue value, child) {
                  final double progress = value.duration.inMilliseconds > 0 
                      ? value.position.inMilliseconds / value.duration.inMilliseconds 
                      : 0.0;
                  return CustomPaint(
                    size: const Size(double.infinity, 3),
                    painter: DottedProgressPainter(progress: progress),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _shortsAction(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedProgressPainter extends CustomPainter {
  final double progress;
  DottedProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    final double dotSpacing = 8.0;
    final int dotsCount = (size.width / dotSpacing).floor();
    if (dotsCount <= 0) return;
    final double actualSpacing = size.width / dotsCount;

    final Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    for (int i = 0; i <= dotsCount; i++) {
        final double dotX = i * actualSpacing;
        final double relativePos = i / dotsCount;
        
        paint.color = relativePos <= progress ? AppTheme.primaryColor : Colors.white24;
        canvas.drawCircle(Offset(dotX, size.height / 2), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DottedProgressPainter oldDelegate) => oldDelegate.progress != progress;
}
