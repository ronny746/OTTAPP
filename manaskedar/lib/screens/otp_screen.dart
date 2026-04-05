import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_theme.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final List<TextEditingController> controllers = List.generate(4, (index) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Container(
        height: double.infinity,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  "VERIFY OTP", 
                  style: GoogleFonts.cinzel(
                    color: AppTheme.primaryColor, 
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 2
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => Text(
                  "Verification code sent to ${authController.phoneNumber.value}", 
                  style: GoogleFonts.lato(color: Colors.white38, fontSize: 16)
                )),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 60,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        maxLength: 1,
                        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 60),
                Obx(() {
                  return GestureDetector(
                    onTap: authController.isVerifyingOtp.value ? null : () {
                      String code = controllers.map((e) => e.text).join();
                      if (code.length < 4) {
                        Get.snackbar("Error", "Please enter 4-digit OTP", 
                           snackPosition: SnackPosition.BOTTOM, 
                           backgroundColor: AppTheme.backgroundColor, 
                           colorText: Colors.white);
                        return;
                      }
                      authController.verifyOtp(code);
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
                        child: authController.isVerifyingOtp.value 
                          ? const CircularProgressIndicator(color: Colors.black) 
                          : Text(
                              "VERIFY & LOG IN", 
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
                const SizedBox(height: 40),
                Center(
                   child: TextButton(
                      onPressed: () => authController.sendOtp(authController.phoneNumber.value),
                      child: Text(
                        "RESEND OTP", 
                        style: GoogleFonts.lato(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                   ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
