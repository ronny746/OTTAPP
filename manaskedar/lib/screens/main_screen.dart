import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manaskedar/utils/app_theme.dart';
import '../controllers/main_screen_controller.dart';
import '../controllers/global_audio_controller.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'videos_screen.dart';
import 'shorts_screen.dart';
import 'audiobooks_screen.dart';
import 'my_account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final List<Widget> _tabs;
  final controller = Get.put(MainScreenController());

  @override
  void initState() {
    super.initState();
    Get.put(GlobalAudioController());
    _tabs = [
      _TabNavigator(index: 0, child: HomeScreen()),
      _TabNavigator(index: 1, child: VideosScreen()),
      _TabNavigator(index: 2, child: const ShortsScreen()),
      _TabNavigator(index: 3, child: const AudiobooksScreen()),
      _TabNavigator(index: 4, child: const MyAccountScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final navigatorState = Get.nestedKey(controller.selectedIndex.value)?.currentState;
        if (navigatorState != null && navigatorState.canPop()) {
          navigatorState.pop();
          return;
        }

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
        if (shouldExit == true) SystemNavigator.pop();
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
                children: _tabs,
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
          () => Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              border: Border(top: BorderSide(color: AppTheme.primaryColor.withOpacity(0.15), width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.onItemTapped,
              elevation: 0,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Colors.white24,
              selectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
              unselectedLabelStyle: GoogleFonts.lato(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.bold),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.filter_vintage_outlined, size: 22), 
                  activeIcon: Icon(Icons.filter_vintage, color: AppTheme.primaryColor, size: 26), 
                  label: "MANDALA".tr
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.visibility_outlined, size: 22), 
                  activeIcon: Icon(Icons.visibility, color: AppTheme.primaryColor, size: 26), 
                  label: "DRISHTI".tr
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bolt_outlined, size: 22), 
                  activeIcon: Icon(Icons.bolt, color: AppTheme.primaryColor, size: 26), 
                  label: "ANSH".tr
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.headphones_outlined, size: 22), 
                  activeIcon: Icon(Icons.headphones, color: AppTheme.primaryColor, size: 26), 
                  label: "NADA".tr
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.self_improvement_outlined, size: 22), 
                  activeIcon: Icon(Icons.self_improvement, color: AppTheme.primaryColor, size: 26), 
                  label: "SADHAKA".tr
                ),
              ],
            ),
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
