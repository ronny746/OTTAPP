import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌌 PREMIUM GRADIENT BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.black, Color(0xFF1A0101), Colors.black],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // 💨 SLIGHT GLOW TOP LEFT
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryColor.withOpacity(0.1), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset('assets/images/logo.png', height: 120, filterQuality: FilterQuality.high),
                    ),
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    "Enter Your Mobile",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "We will send a high-security OTP for verification",
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                  const SizedBox(height: 50),
                  
                  // 💎 GLASSMORPHIC INPUT CARD
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: "Phone Number",
                          hintStyle: const TextStyle(color: Colors.white24, fontWeight: FontWeight.normal),
                          prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppTheme.primaryColor, size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  // 🔥 PREMIUM GLOWING BUTTON
                  Obx(() {
                    return GestureDetector(
                      onTap: authController.isSendingOtp.value ? null : () {
                        if (phoneController.text.length < 10) {
                          Get.snackbar("Invalid Number", "Please enter 10 digit number", 
                             snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                          return;
                        }
                        authController.sendOtp(phoneController.text);
                        Get.to(() => const OtpScreen());
                      },
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppTheme.primaryColor, Color(0xFFB71C1C)],
                          ),
                        ),
                        child: Center(
                          child: authController.isSendingOtp.value 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text(
                                "RECEIVE SECURE OTP", 
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
