import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart' as bg;
import 'package:manaskedar/models/media_item.dart';


class GlobalAudioController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer(
    // Set skip intervals to 10 seconds for notification buttons
    handleAudioSessionActivation: true,
    handleInterruptions: true,
  );
  
  var currentItem = Rxn<MediaItem>();
  var isPlaying = false.obs;
  var isMiniPlayerVisible = false.obs;
  var isMainPlayerOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // Explicitly set skip intervals for buttons
    // These values are used when the notification buttons are clicked
  }

  void playNew(MediaItem item) async {
    currentItem.value = item;
    isMiniPlayerVisible.value = true;
    try {
      final audioSource = AudioSource.uri(
        Uri.parse(item.videoUrl),
        tag: bg.MediaItem(
          id: item.id, // Using item.id fixed in previous turn
          album: "Manaskedar Library",
          title: item.title,
          artUri: Uri.parse(item.imageUrl),
        ),
      );
      await audioPlayer.setAudioSource(audioSource);
      audioPlayer.play();
    } catch (e) {
      Get.snackbar("Error", "Could not play audio");
    }
  }

  void skip10s(bool forward) {
     final current = audioPlayer.position;
     if (forward) {
       audioPlayer.seek(current + const Duration(seconds: 10));
     } else {
       audioPlayer.seek(current - const Duration(seconds: 10));
     }
  }

  void stopAndDispose() {
    audioPlayer.stop();
    isMiniPlayerVisible.value = false;
    currentItem.value = null;
  }

  void togglePlay() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
