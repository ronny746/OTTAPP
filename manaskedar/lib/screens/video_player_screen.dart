import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).catchError((_) {});
    
    _initPlayer();
  }

  void _initPlayer() {
    if (widget.item.videoUrl.isEmpty || !Uri.parse(widget.item.videoUrl).hasAuthority) {
      print("❌ INVALID VIDEO URL: ${widget.item.videoUrl}");
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar(
          "PLAYBACK_ERROR".tr, 
          "INVALID_VIDEO_URL_MESSAGE".tr,
          backgroundColor: AppTheme.backgroundColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _handleBack();
      });
      return;
    }

    _player = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.item.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
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
    // Forcibly reset to portrait to ensure home screen remains vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).catchError((_) {});
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _handleBack() {
    _isNavigatingBack = true;
    if (_player.isInitialized) {
      _player.controller.pause();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]).catchError((_) {});
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _seekToRelatively(Duration offset) async {
    final current = _player.controller.value.position;
    final target = current + offset;
    final max = _player.controller.value.duration;
    
    // Clamp target
    final finalPos = target < Duration.zero ? Duration.zero : (target > max ? max : target);
    await _seekToAbsolute(finalPos);
  }

  Future<void> _seekToAbsolute(Duration position) async {
    if (!_player.isInitialized) return;
    final bool wasPlaying = _player.controller.value.isPlaying;
    
    await _player.controller.pause();
    await _player.controller.seekTo(position);
    if (wasPlaying) {
      await _player.controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 📽️ VIDEO SURFACE
              if (_player.isInitialized)
                SizedBox.expand(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _player.controller.value.size.width,
                        height: _player.controller.value.size.height,
                        child: VideoPlayer(_player.controller),
                      ),
                    ),
                  ),
                )
              else
                // 🚀 SPIRITUAL LOADER
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2),
                      const SizedBox(height: 20),
                      Text("ESTABLISHING_DIVINE_CONNECTION".tr, style: GoogleFonts.cinzel(color: AppTheme.primaryColor.withOpacity(0.5), fontSize: 12, letterSpacing: 1.5)),
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
                          widget.item.title.toUpperCase(),
                          style: GoogleFonts.cinzel(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
                      const Icon(Icons.cast_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 20),
                      const Icon(Icons.settings_input_component_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),

                // ⏯️ CENTER CONTROLS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 45),
                      onPressed: () => _seekToRelatively(const Duration(seconds: -10)),
                    ),
                    const SizedBox(width: 80),
                    GestureDetector(
                      onTap: () {
                         setState(() {
                            _player.controller.value.isPlaying ? _player.controller.pause() : _player.controller.play();
                         });
                      },
                      child: Container(
                         padding: const EdgeInsets.all(15),
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                         ),
                        child: Icon(
                          _player.controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: AppTheme.primaryColor,
                          size: 60,
                        ),
                      ),
                    ),
                    const SizedBox(width: 80),
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 45),
                      onPressed: () => _seekToRelatively(const Duration(seconds: 10)),
                    ),
                  ],
                ),

                // 📊 BOTTOM PROGRESS BAR
                Positioned(
                  bottom: 25,
                  left: 50,
                  right: 50,
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
                                  inactiveTrackColor: Colors.white10,
                                  thumbColor: AppTheme.primaryColor,
                                  overlayColor: AppTheme.primaryColor.withOpacity(0.1),
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                ),
                                child: Slider(
                                  value: value.position.inSeconds.toDouble().clamp(0.0, value.duration.inSeconds.toDouble() + 0.1),
                                  min: 0.0,
                                  max: value.duration.inSeconds.toDouble(),
                                  onChanged: (val) {
                                    _seekToAbsolute(Duration(seconds: val.toInt()));
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
                                      style: GoogleFonts.lato(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                                    Text(
                                      _formatDuration(value.duration),
                                      style: GoogleFonts.lato(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
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
