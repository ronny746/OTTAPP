import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../controllers/interaction_controller.dart';
import 'downloads_screen.dart';
import 'edit_profile_screen.dart';
import 'media_grid_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final interactionCtrl = Get.put(InteractionController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor, width: 3),
                    ),
                    child: Obx(() => CircleAvatar(
                      radius: 54,
                      backgroundColor: Colors.grey[900],
                      backgroundImage: authController.userImageUrl.value.isNotEmpty
                          ? NetworkImage(authController.userImageUrl.value)
                          : null,
                      child: authController.userImageUrl.value.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.white54)
                          : null,
                    )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Get.to(() => const EditProfileScreen()),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Obx(() => Text(
              authController.userName.value.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5)
            )),
            Obx(() => Text(
              authController.userPhone.value,
              style: const TextStyle(color: Colors.white70, fontSize: 16)
            )),
            Obx(() {
               if (authController.userCity.value.isNotEmpty) {
                 return Padding(
                   padding: const EdgeInsets.only(top: 5),
                   child: Text(authController.userCity.value, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                 );
               }
               return const SizedBox();
            }),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.star, color: Colors.black, size: 20),
                   SizedBox(width: 8),
                   Text("GOLD MEMBER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildSection(context, "library".tr, [
              _buildAccountTile(context, Icons.download_done, "downloads".tr, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsScreen()))),
              _buildAccountTile(context, Icons.favorite, "my_favorites".tr, onTap: () async {
                 await interactionCtrl.fetchFavorites();
                 Get.to(() => MediaGridScreen(title: "my_favorites".tr, items: interactionCtrl.watchFavorites));
              }),
              _buildAccountTile(context, Icons.history, "recently_watched".tr, onTap: () async {
                 await interactionCtrl.fetchWatchHistory();
                 Get.to(() => MediaGridScreen(title: "recently_watched".tr, items: interactionCtrl.watchHistory, isHistory: true));
              }),
            ]),

            const SizedBox(height: 30),

            _buildSection(context, "account_settings".tr, [
              _buildAccountTile(context, Icons.language, "change_language".tr, onTap: () => _showLanguageDialog(context, authController)),
              _buildAccountTile(context, Icons.subscriptions, "subplan".tr, iconColor: Colors.amber),
              _buildAccountTile(context, Icons.shopping_bag_outlined, "manage_subscriptions".tr),
              _buildAccountTile(context, Icons.notifications_outlined, "notification_settings".tr),
            ]),

            const SizedBox(height: 30),

            _buildSection(context, "legal_support".tr, [
              _buildAccountTile(context, Icons.description_outlined, "terms_conditions".tr),
              _buildAccountTile(context, Icons.privacy_tip_outlined, "privacy_policy".tr),
              _buildAccountTile(context, Icons.help_outline, "help_support".tr),
              _buildAccountTile(context, Icons.logout, "logout".tr, iconColor: Colors.red, textColor: Colors.red, onTap: () => authController.logout()),
            ]),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Text(title, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Column(children: children),
      ],
    );
  }

  Widget _buildAccountTile(BuildContext context, IconData icon, String title, {Color? iconColor, Color? textColor, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white70),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
    );
  }

  void _showLanguageDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("change_language".tr, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("English", style: TextStyle(color: Colors.white)),
              onTap: () async {
                await authController.setLanguage('en', 'US');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("हिंदी (Hindi)", style: TextStyle(color: Colors.white)),
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
