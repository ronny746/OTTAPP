import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../controllers/main_controller.dart';
import '../controllers/interaction_controller.dart';
import '../models/media_item.dart';
import 'details_screen.dart';
import 'video_player_screen.dart';
import 'audio_player_screen.dart';
import '../widgets/spiritual_background.dart';
import '../widgets/spiritual_shimmer.dart';
import '../controllers/main_screen_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final MainController controller = Get.put(MainController());
  final InteractionController interactionCtrl = Get.put(InteractionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SpiritualBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                   const SizedBox(height: 50),
                   _buildTopHeader(),
                   const SizedBox(height: 40),
                   // Hero Shimmer
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     child: SpiritualShimmer.banner(),
                   ),
                   const SizedBox(height: 40),
                   // Multiple Sections Shimmer
                   SpiritualShimmer.horizontalList(),
                   SpiritualShimmer.horizontalList(),
                   SpiritualShimmer.horizontalList(),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 50),
                
                // ── BRAND HEADER ──────────────────────────────────────────
                _buildTopHeader(),

                const SizedBox(height: 20),

                // ── HERO SECTION ──────────────────────────────────────────
                _buildHeroSection(context),

                const SizedBox(height: 28),

                // ── DYNAMIC CONTENT SECTIONS ─────────────────────────────
                Obx(() => Column(
                  children: controller.homeSections.map((section) {
                    return _buildGridSection(
                      context,
                      section.title,
                      section.subtitle,
                      section.items,
                    );
                  }).toList(),
                )),

                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── BRAND HEADER (LOGO & NAME - COMPACT) ───────────────────────────────────
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Elegant Circular Logo
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Image.asset(
              "assets/images/logo.png",
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.flash_on, color: AppTheme.primaryColor, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          // Divine Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "MANASKEDAR",
                style: GoogleFonts.cinzel(
                  color: AppTheme.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              Text(
                "THE DIVINE UNIVERSE",
                style: GoogleFonts.cinzel(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── HERO SECTION ────────────────────────────────────────────────────────────
  Widget _buildHeroSection(BuildContext context) {
    final banners = controller.banners;

    if (banners.length > 1) {
      return Obx(() {
        final currentItem = banners[controller.currentBannerIndex.value];
        return Column(
          children: [
            CarouselSlider(
              items: banners.map((item) {
                return GestureDetector(
                  onTap: () => Get.to(() => DetailsScreen(item: item), id: Get.find<MainScreenController>().selectedIndex.value),
                  child: _buildBannerCard(item),
                );
              }).toList(),
              options: CarouselOptions(
                aspectRatio: 2.2,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.92,
                autoPlayCurve: Curves.easeInOutQuart,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, _) =>
                    controller.currentBannerIndex.value = index,
              ),
            ),
            const SizedBox(height: 16),
            _buildDotIndicators(banners.length, controller.currentBannerIndex.value),
            const SizedBox(height: 20),
            _buildHeroInfo(context, currentItem),
          ],
        );
      });
    }

    if (banners.length == 1) {
      final item = banners.first;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => Get.to(() => DetailsScreen(item: item), id: Get.find<MainScreenController>().selectedIndex.value),
              child: _buildBannerCard(item),
            ),
          ),
          const SizedBox(height: 20),
          _buildHeroInfo(context, item),
        ],
      );
    }

    return _buildFallbackHero(context);
  }

  Widget _buildBannerCard(MediaItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 2.2,
          child: CachedNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (_, __) => Container(color: Colors.white10),
            errorWidget: (_, __, ___) => Container(color: Colors.white10),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroInfo(BuildContext context, MediaItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            item.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.25,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.category?.toUpperCase() ?? "DIVINE REALM",
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pillButton(
                label: "Play",
                icon: Icons.play_arrow_rounded,
                isPrimary: true,
                onTap: () => Get.to(() => VideoPlayerScreen(item: item)),
              ),
              const SizedBox(width: 14),
              _pillButton(
                label: "Info",
                icon: Icons.info_outline_rounded,
                isPrimary: false,
                onTap: () => Get.to(() => DetailsScreen(item: item), id: Get.find<MainScreenController>().selectedIndex.value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            "THE DIVINE OTT\nAWAKEN YOUR SOUL",
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pillButton(
                label: "Play",
                icon: Icons.play_arrow_rounded,
                isPrimary: true,
                onTap: () {},
              ),
              const SizedBox(width: 14),
              _pillButton(
                label: "Info",
                icon: Icons.info_outline_rounded,
                isPrimary: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators(int count, int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _pillButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 9),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary ? null : Border.all(color: Colors.white30, width: 1.2),
          boxShadow: isPrimary ? [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isPrimary ? Colors.black : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                color: isPrimary ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSection(
    BuildContext context,
    String title,
    String subtitle,
    List<MediaItem> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      title.tr,
                      style: GoogleFonts.lato(
                        color: const Color(0xFFF7BD31),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      subtitle.tr,
                      style: GoogleFonts.lato(
                        color: Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(width: 40, height: 2, color: AppTheme.accentColor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AspectRatio(
                  aspectRatio: 0.72,
                  child: _buildContentCard(context, item, isContinue: title.contains('watching')),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context, MediaItem item, {bool isContinue = false}) {
    return GestureDetector(
      onTap: () {
        // 🎞️ SHORTS: Always jump to Shorts Tab
        if (item.type == 'short' || item.type == 'shorts') {
          controller.playShort(item);
          return;
        }

        // 🔄 CONTINUE WATCHING: Instant Playback
        if (isContinue) {
          if (item.type == 'audio') {
            Get.to(() => AudioPlayerScreen(item: item));
          } else {
            Get.to(() => VideoPlayerScreen(item: item));
          }
          return;
        }

        // 📖 DEFAULT: Detailed Divine Knowledge
        Get.to(
          () => DetailsScreen(item: item), 
          id: Get.find<MainScreenController>().selectedIndex.value,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.white10),
                errorWidget: (_, __, ___) => Container(color: Colors.white10),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 8,
                right: 8,
                child: Text(
                  item.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}