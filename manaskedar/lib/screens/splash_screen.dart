import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../widgets/spiritual_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SpiritualBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Animated GIF Splash
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    "assets/images/splah.gif",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                "MANASKEDAR",
                style: GoogleFonts.cinzel(
                  color: AppTheme.primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "AWAKEN YOUR SOUL",
                style: GoogleFonts.cinzel(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 60),
              // Subtle espiritual loading
              const CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 1.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
