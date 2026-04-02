import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manaskedar/models/media_item.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:get/get.dart';
import '../controllers/interaction_controller.dart';
import '../utils/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MediaItem item;
  const VideoPlayerScreen({super.key, required this.item});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late CachedVideoPlayerPlus _player;
  bool _showControls = true;
  bool _isNavigatingBack = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).catchError((_) {});
    
    _player = CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.item.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          if (widget.item.lastPosition > 0) {
            _player.controller.seekTo(Duration(seconds: widget.item.lastPosition));
          }
          _player.controller.play();
          _hideControlsAfterDelay();
          _startProgressSync();
        }
      });
  }

  void _startProgressSync() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted || _isNavigatingBack) return false;
      if (_player.isInitialized && _player.controller.value.isPlaying) {
        final pos = _player.controller.value.position.inSeconds;
        Get.find<InteractionController>().updatePosition(widget.item.id, pos);
      }
      return true;
    });
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _player.isInitialized && _player.controller.value.isPlaying && !_isNavigatingBack) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (_isNavigatingBack) return;
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _hideControlsAfterDelay();
    });
  }

  @override
  void dispose() {
    if (_player.isInitialized) {
      _player.controller.dispose();
    }
    super.dispose();
  }

  void _handleBack() {
    _isNavigatingBack = true;
    if (_player.isInitialized) {
      _player.controller.pause();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).catchError((_) {});
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 📽️ VIDEO SURFACE
              if (_player.isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: _player.controller.value.aspectRatio,
                    child: VideoPlayer(_player.controller),
                  ),
                )
              else
                // 🚀 SINGLE PREMIUM LOADER
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.red, strokeWidth: 3),
                      SizedBox(height: 15),
                      Text("ESTABLISHING SECURE CONNECTION...", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.2)),
                    ],
                  ),
                ),

              // 🎮 UI CONTROLS LAYER
              if (_showControls && _player.isInitialized) ...[
                // Subtle Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent, Colors.transparent, Colors.black87],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),

                // 🔙 TOP BAR
                Positioned(
                  top: 25,
                  left: 30,
                  right: 30,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                        onPressed: _handleBack,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.cast, color: Colors.white, size: 20),
                      const SizedBox(width: 20),
                      const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                    ],
                  ),
                ),

                // ⏯️ CENTER CONTROLS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 45),
                      onPressed: () {
                        final current = _player.controller.value.position;
                        _player.controller.seekTo(current - const Duration(seconds: 10));
                      },
                    ),
                    const SizedBox(width: 50),
                    IconButton(
                      icon: Icon(
                        _player.controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 65,
                      ),
                      onPressed: () {
                        setState(() {
                          _player.controller.value.isPlaying ? _player.controller.pause() : _player.controller.play();
                        });
                      },
                    ),
                    const SizedBox(width: 50),
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 45),
                      onPressed: () {
                        final current = _player.controller.value.position;
                        _player.controller.seekTo(current + const Duration(seconds: 10));
                      },
                    ),
                  ],
                ),

                // 📊 BOTTOM PROGRESS BAR
                Positioned(
                  bottom: 25,
                  left: 40,
                  right: 40,
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: _player.controller,
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.primaryColor,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: AppTheme.primaryColor,
                                  overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                ),
                                child: Slider(
                                  value: value.position.inSeconds.toDouble().clamp(0.0, value.duration.inSeconds.toDouble() + 0.1),
                                  min: 0.0,
                                  max: value.duration.inSeconds.toDouble(),
                                  onChanged: (val) {
                                    _player.controller.seekTo(Duration(seconds: val.toInt()));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(value.position),
                                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "-${_formatDuration(value.duration - value.position)}",
                                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
