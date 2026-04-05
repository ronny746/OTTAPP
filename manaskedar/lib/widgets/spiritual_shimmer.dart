import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_theme.dart';

class SpiritualShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SpiritualShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: AppTheme.primaryColor.withOpacity(0.12),
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  // --- PRESETS ---

  static Widget banner() {
    return const SpiritualShimmer(width: double.infinity, height: 180, borderRadius: 25);
  }

  static Widget appHeader() {
    return const SpiritualShimmer(width: double.infinity, height: 320, borderRadius: 0);
  }

  static Widget sectionHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpiritualShimmer(width: 150, height: 24, borderRadius: 4),
        SizedBox(height: 8),
        SpiritualShimmer(width: 40, height: 2, borderRadius: 0),
      ],
    );
  }

  static Widget mediaCard() {
    return const SpiritualShimmer(width: 130, height: 180, borderRadius: 16);
  }

  static Widget listTile() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 25),
      child: SpiritualShimmer(width: double.infinity, height: 100, borderRadius: 20),
    );
  }

  static Widget horizontalList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: sectionHeader(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: mediaCard(),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
