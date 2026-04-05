import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manaskedar/models/media_item.dart';

import '../utils/app_theme.dart';
import '../controllers/global_audio_controller.dart';

import '../widgets/spiritual_background.dart';

class AudioPlayerScreen extends StatefulWidget {
  final MediaItem item;
  const AudioPlayerScreen({super.key, required this.item});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final audioController = Get.find<GlobalAudioController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioController.isMainPlayerOpen.value = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioController.isMainPlayerOpen.value = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _audioPlayer = audioController.audioPlayer;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SpiritualBackground(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 40), 
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "PLAYING_AUDIOBOOK".tr, 
                    style: GoogleFonts.cinzel(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 3.0)
                  ),
                  IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22), onPressed: () {}),
                ],
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.15), blurRadius: 60, spreadRadius: 5),
                    BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 40, spreadRadius: 2),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.item.imageUrl,
                      height: 330,
                      width: 330,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title.toUpperCase(), 
                          style: GoogleFonts.cinzel(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "MANASKEDAR_ORIGINAL".tr, 
                          style: GoogleFonts.lato(color: AppTheme.primaryColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.favorite_rounded, color: AppTheme.primaryColor, size: 30), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 40),
              StreamBuilder<Duration?>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = _audioPlayer.duration ?? Duration.zero;
                  return ProgressBar(
                    progress: position,
                    buffered: _audioPlayer.bufferedPosition,
                    total: total,
                    onSeek: (duration) => _audioPlayer.seek(duration),
                    baseBarColor: Colors.white.withOpacity(0.06),
                    progressBarColor: AppTheme.primaryColor,
                    bufferedBarColor: Colors.white.withOpacity(0.12),
                    thumbColor: AppTheme.primaryColor,
                    barHeight: 4,
                    thumbRadius: 6,
                    timeLabelTextStyle: GoogleFonts.lato(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                    timeLabelPadding: 12,
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.shuffle_rounded, color: Colors.white24, size: 24), onPressed: () {}),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 44), onPressed: () {}),
                      const SizedBox(width: 8),
                      Obx(() {
                        return GestureDetector(
                          onTap: () => audioController.togglePlay(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              audioController.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 44), onPressed: () {}),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.repeat_rounded, color: Colors.white24, size: 24), onPressed: () {}),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
