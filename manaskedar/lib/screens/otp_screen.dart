import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text("VERIFY OTP", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 10),
              Obx(() => Text("Verificaton code sent to ${authController.phoneNumber.value}", style: const TextStyle(color: Colors.white38, fontSize: 16))),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Container(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: authController.isVerifyingOtp.value ? null : () {
                      String code = controllers.map((e) => e.text).join();
                      if (code.length < 4) {
                        Get.snackbar("Error", "Please enter 4-digit OTP", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      authController.verifyOtp(code);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: authController.isVerifyingOtp.value 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("VERIFY & LOG IN", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                );
              }),
              const SizedBox(height: 30),
              Center(
                 child: TextButton(
                    onPressed: () => authController.sendOtp(authController.phoneNumber.value),
                    child: const Text("RESEND OTP", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 14)),
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
