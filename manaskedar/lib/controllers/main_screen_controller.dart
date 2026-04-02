import 'package:get/get.dart';
import 'global_audio_controller.dart';

class MainScreenController extends GetxController {
  var selectedIndex = 0.obs;

  void onItemTapped(int index) {
    if (selectedIndex.value == index) {
      // If already on the tab, pop everything to the root
      final state = Get.nestedKey(index)?.currentState;
      if (state != null && state.canPop()) {
        state.popUntil((route) => route.isFirst);
      }
    } else {
      // If switching tabs, also reset the target tab to root
      final state = Get.nestedKey(index)?.currentState;
      if (state != null && state.canPop()) {
        state.popUntil((route) => route.isFirst);
      }
      selectedIndex.value = index;
    }

    // Handle Shorts logic
    if (Get.isRegistered<GlobalAudioController>()) {
      final audioController = Get.find<GlobalAudioController>();
      if (index == 2) {
        audioController.audioPlayer.pause();
        audioController.isMiniPlayerVisible.value = false;
      } else {
        if (audioController.currentItem.value != null) {
          audioController.isMiniPlayerVisible.value = true;
        }
      }
    }
  }
}
