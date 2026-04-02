import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/main_screen_controller.dart';
import '../controllers/global_audio_controller.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'videos_screen.dart';
import 'shorts_screen.dart';
import 'audiobooks_screen.dart';
import 'my_account_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GlobalAudioController());
    final controller = Get.put(MainScreenController());

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // 1. First try to pop nested routes
        final navigatorState = Get.nestedKey(controller.selectedIndex.value)?.currentState;
        if (navigatorState != null && navigatorState.canPop()) {
          navigatorState.pop();
          return;
        }

        // 2. If no nested routes, show Exit Confirmation Dialog
        final shouldExit = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Exit App?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: const Text("Are you sure you want to close Manaskedar?", style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text("NO", style: TextStyle(color: Colors.white54))),
              TextButton(onPressed: () => Get.back(result: true), child: const Text("YES, EXIT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0, 
        ),
        body: Stack(
          children: [
            Obx(() => IndexedStack(
              index: controller.selectedIndex.value,
              children: [
                _TabNavigator(index: 0, child:  HomeScreen()),
                _TabNavigator(index: 1, child:  VideosScreen()),
                _TabNavigator(index: 2, child: const ShortsScreen()),
                _TabNavigator(index: 3, child: const AudiobooksScreen()),
                _TabNavigator(index: 4, child: const MyAccountScreen()),
              ],
            )),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(),
            ),
          ],
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: (index) {
              controller.onItemTapped(index);
            },
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: "home".tr),
              BottomNavigationBarItem(icon: const Icon(Icons.video_collection_outlined), activeIcon: const Icon(Icons.video_collection), label: "videos".tr),
              BottomNavigationBarItem(icon: const Icon(Icons.flash_on_outlined), activeIcon: const Icon(Icons.flash_on), label: "shorts".tr),
              BottomNavigationBarItem(icon: const Icon(Icons.headset_outlined), activeIcon: const Icon(Icons.headset), label: "audios".tr),
              BottomNavigationBarItem(icon: const Icon(Icons.account_circle_outlined), activeIcon: const Icon(Icons.account_circle), label: "account".tr),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  final int index;
  final Widget child;
  const _TabNavigator({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(index),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => child,
      ),
    );
  }
}
