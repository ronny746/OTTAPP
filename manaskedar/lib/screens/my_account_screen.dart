import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../controllers/interaction_controller.dart';
import 'downloads_screen.dart';
import 'edit_profile_screen.dart';
import 'media_grid_screen.dart';

import '../widgets/spiritual_background.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final interactionCtrl = Get.put(InteractionController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SpiritualBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 110),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.05), blurRadius: 25, spreadRadius: 5),
                        ],
                      ),
                      child: Obx(() => CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white.withOpacity(0.04),
                        backgroundImage: authController.userImageUrl.value.isNotEmpty
                            ? NetworkImage(authController.userImageUrl.value)
                            : null,
                        child: authController.userImageUrl.value.isEmpty
                            ? const Icon(Icons.person_rounded, size: 85, color: Colors.white10)
                            : null,
                      )),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => Get.to(() => const EditProfileScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.edit_rounded, size: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Obx(() => Text(
                authController.userName.value.toUpperCase(),
                style: GoogleFonts.cinzel(color: AppTheme.primaryColor, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2.5)
              )),
              const SizedBox(height: 6),
              Obx(() => Text(
                authController.userPhone.value,
                style: GoogleFonts.lato(color: Colors.white38, fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.bold)
              )),
              Obx(() {
                 if (authController.userCity.value.isNotEmpty) {
                   return Padding(
                     padding: const EdgeInsets.only(top: 10),
                     child: Text(
                        authController.userCity.value.toUpperCase(), 
                        style: GoogleFonts.lato(color: AppTheme.accentColor.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3.0)
                      ),
                   );
                 }
                 return const SizedBox();
              }),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     const Icon(Icons.star_rounded, color: Colors.black, size: 24),
                     const SizedBox(width: 12),
                     Text(
                        "gold_member".tr, 
                        style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2.0)
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 60),

              _buildSection(context, "library".tr, [
                _buildAccountTile(context, Icons.download_done_rounded, "downloads".tr, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsScreen()))),
                _buildAccountTile(context, Icons.favorite_rounded, "my_favorites".tr, onTap: () async {
                   await interactionCtrl.fetchFavorites();
                   Get.to(() => MediaGridScreen(title: "my_favorites".tr, items: interactionCtrl.watchFavorites));
                }),
                _buildAccountTile(context, Icons.history_rounded, "recently_watched".tr, onTap: () async {
                   await interactionCtrl.fetchWatchHistory();
                   Get.to(() => MediaGridScreen(title: "recently_watched".tr, items: interactionCtrl.watchHistory, isHistory: true));
                }),
              ]),

              const SizedBox(height: 40),

              _buildSection(context, "account_settings".tr, [
                _buildAccountTile(context, Icons.translate_rounded, "change_language".tr, onTap: () => _showLanguageDialog(context, authController)),
                _buildAccountTile(context, Icons.subscriptions_rounded, "subplan".tr, iconColor: AppTheme.primaryColor),
                _buildAccountTile(context, Icons.notifications_active_rounded, "notification_settings".tr),
              ]),

              const SizedBox(height: 40),

              _buildSection(context, "legal_support".tr, [
                _buildAccountTile(context, Icons.gavel_rounded, "terms_conditions".tr),
                _buildAccountTile(context, Icons.security_rounded, "privacy_policy".tr),
                _buildAccountTile(context, Icons.logout_rounded, "logout".tr, iconColor: AppTheme.accentColor, textColor: AppTheme.accentColor, onTap: () => authController.logout()),
              ]),

              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Row(
            children: [
              Container(width: 4, height: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 15),
              Text(
                title.toUpperCase(), 
                style: GoogleFonts.cinzel(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2.0)
              ),
            ],
          ),
        ),
        Column(children: children),
      ],
    );
  }

  Widget _buildAccountTile(BuildContext context, IconData icon, String title, {Color? iconColor, Color? textColor, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white54, size: 24),
      title: Text(
        title, 
        style: GoogleFonts.lato(color: textColor ?? Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)
      ),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 22, color: Colors.white12),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
      visualDensity: VisualDensity.compact,
    );
  }

  void _showLanguageDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), 
          side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.15), width: 1)
        ),
        title: Text(
          "change_language".tr, 
          style: GoogleFonts.cinzel(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.5)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("English", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.primaryColor),
              onTap: () async {
                await authController.setLanguage('en', 'US');
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              title: Text("हिंदी", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.primaryColor),
              onTap: () async {
                await authController.setLanguage('hi', 'IN');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
