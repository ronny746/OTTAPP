import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manaskedar/controllers/main_controller.dart';
import 'package:manaskedar/models/media_item.dart';
import 'package:manaskedar/utils/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:get/get.dart';
import '../utils/cache_manager.dart';
import '../controllers/interaction_controller.dart';
import 'video_player_screen.dart';

import '../widgets/spiritual_background.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _trailerPlayer =
        CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.item.videoUrl))
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
      backgroundColor: AppTheme.backgroundColor,
      body: SpiritualBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              backgroundColor: AppTheme.backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double top = constraints.biggest.height;
                  final bool isCollapsed =
                      top <=
                      kToolbarHeight + MediaQuery.of(context).padding.top + 20;

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: EdgeInsets.only(
                      left: isCollapsed ? 0 : 24,
                      right: isCollapsed ? 0 : 80,
                      bottom: isCollapsed ? 16 : 28,
                    ),
                    title: Text(
                      widget.item.title.toUpperCase(),
                      textAlign: isCollapsed
                          ? TextAlign.center
                          : TextAlign.left,
                      style: GoogleFonts.cinzel(
                        color: isCollapsed
                            ? AppTheme.primaryColor
                            : Colors.white,
                        fontSize: isCollapsed ? 15 : 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: isCollapsed ? 1.5 : 2.0,
                        shadows: isCollapsed
                            ? []
                            : [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 10,
                                ),
                              ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _initialized
                            ? AspectRatio(
                                aspectRatio:
                                    _trailerPlayer.controller.value.aspectRatio,
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
                                AppTheme.backgroundColor.withOpacity(0.4),
                                AppTheme.backgroundColor,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 25,
                          right: 25,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMuted = !_isMuted;
                                _trailerPlayer.controller.setVolume(
                                  _isMuted ? 0.0 : 1.0,
                                );
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Icon(
                                _isMuted
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.item.rating,
                          style: GoogleFonts.lato(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          widget.item.year,
                          style: GoogleFonts.lato(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.item.type.toUpperCase(),
                            style: GoogleFonts.lato(
                              color: AppTheme.primaryColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          widget.item.duration,
                          style: GoogleFonts.lato(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // --- PLAY BUTTON (PILL SHAPE) ---
                    GestureDetector(
                      onTap: () {
                        if (_initialized) _trailerPlayer.controller.pause();

                        late MediaItem playMedia;
                        if (widget.item.type == 'show' &&
                            widget.item.episodes.isNotEmpty) {
                          final ep = widget.item.episodes.first;
                          playMedia = MediaItem(
                            id: "${widget.item.id}_0",
                            title: "${widget.item.title} - ${ep.title}",
                            imageUrl: ep.imageUrl ?? widget.item.imageUrl,
                            videoUrl: ep.videoUrl,
                            type: 'video',
                            description:
                                ep.description ?? widget.item.description,
                          );
                        } else {
                          playMedia = widget.item;
                        }

                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(item: playMedia),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "PLAY",
                              style: GoogleFonts.lato(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 3.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GetBuilder<InteractionController>(
                          builder: (ctrl) => _actionButton(
                            widget.item.isFavorite
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline_rounded,
                            "My List",
                            () => ctrl.toggleFavorite(widget.item),
                            color: widget.item.isFavorite
                                ? AppTheme.primaryColor
                                : Colors.white60,
                          ),
                        ),
                        _actionButton(Icons.share_rounded, "Share", () {
                          Get.find<InteractionController>().incrementShare(
                            widget.item,
                          );
                        }, color: Colors.white60),
                        _actionButton(
                          Icons.thumb_up_rounded,
                          "Rate",
                          () {},
                          color: Colors.white60,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Text(
                      widget.item.description,
                      style: GoogleFonts.lato(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 15,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // --- EPISODES SECTION ---
                    if (widget.item.episodes.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "EPISODES",
                            style: GoogleFonts.cinzel(
                              color: AppTheme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            "${widget.item.episodes.length} EPISODES",
                            style: GoogleFonts.lato(
                              color: Colors.white24,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.item.episodes.length,
                        itemBuilder: (context, index) {
                          final ep = widget.item.episodes[index];
                          return GestureDetector(
                            onTap: () {
                              if (_initialized)
                                _trailerPlayer.controller.pause();
                              final epMedia = MediaItem(
                                id: "${widget.item.id}_$index",
                                title: ep.title,
                                imageUrl: ep.imageUrl ?? widget.item.imageUrl,
                                videoUrl: ep.videoUrl,
                                type: 'video',
                                description:
                                    ep.description ?? widget.item.description,
                              );
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VideoPlayerScreen(item: epMedia),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 25),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(
                                    0.08,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              ep.imageUrl ??
                                              widget.item.imageUrl,
                                          width: 140,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: AppTheme.primaryColor,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ep.title,
                                          style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          ep.duration,
                                          style: GoogleFonts.lato(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          ep.description ??
                                              widget.item.description,
                                          style: GoogleFonts.lato(
                                            color: Colors.white30,
                                            fontSize: 11,
                                            height: 1.4,
                                          ),
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
                      const SizedBox(height: 40),
                    ],

                    // --- MORE LIKE THIS SECTION ---
                    Text(
                      "MORE LIKE THIS",
                      style: GoogleFonts.cinzel(
                        color: AppTheme.primaryColor.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 180,
                      child: GetX<MainController>(
                        builder: (ctrl) {
                          final recommended = ctrl.popularVideos
                              .where((e) => e.id != widget.item.id)
                              .toList();
                          if (recommended.isEmpty) return const SizedBox();
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recommended.length,
                            itemBuilder: (context, idx) {
                              final rItem = recommended[idx];
                              return GestureDetector(
                                onTap: () {
                                  if (_initialized)
                                    _trailerPlayer.controller.pause();
                                  Get.to(
                                    () => DetailsScreen(item: rItem),
                                    preventDuplicates: false,
                                  );
                                },
                                child: Container(
                                  width: 130,
                                  margin: const EdgeInsets.only(right: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(rItem.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.bottomCenter,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      rItem.title,
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _actionButton(
  IconData icon,
  String label,
  VoidCallback onTap, {
  Color color = Colors.white,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.lato(
            color: color == Colors.white ? Colors.white60 : color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
