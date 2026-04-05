import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 🌌 SPIRITUAL GRADIENT BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Color(0xFF2D0D22), // Dark Maroon accent
                    Color(0xFF1A0A2E), // Deep Royal Purple
                  ],
                ),
              ),
            ),
          ),
          
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/images/logo.png', 
                        height: 100, 
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.flash_on, color: AppTheme.primaryColor, size: 80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Welcome to",
                    style: GoogleFonts.lato(color: Colors.white60, fontSize: 16, letterSpacing: 2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "MANASKEDAR\nUNIVERSE",
                    style: GoogleFonts.cinzel(
                      color: AppTheme.primaryColor, 
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      height: 1.1,
                      letterSpacing: 2
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // 💎 PREMIUM INPUT
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.lato(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "Enter Mobile Number",
                        hintStyle: GoogleFonts.lato(color: Colors.white24, fontWeight: FontWeight.normal),
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppTheme.primaryColor, size: 20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),
                  
                  // 🔥 GOLDEN PILL BUTTON
                  Obx(() {
                    return GestureDetector(
                      onTap: authController.isSendingOtp.value ? null : () {
                        if (phoneController.text.length < 10) {
                          Get.snackbar("Invalid Number", "Please enter 10 digit number", 
                             snackPosition: SnackPosition.BOTTOM, 
                             backgroundColor: AppTheme.backgroundColor, 
                             colorText: Colors.white);
                          return;
                        }
                        authController.sendOtp(phoneController.text);
                        Get.to(() => const OtpScreen());
                      },
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: authController.isSendingOtp.value 
                            ? const CircularProgressIndicator(color: Colors.black) 
                            : Text(
                                "RECEIVE SECURE OTP", 
                                style: GoogleFonts.lato(
                                  color: Colors.black, 
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w900, 
                                  letterSpacing: 1.5
                                ),
                              ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
