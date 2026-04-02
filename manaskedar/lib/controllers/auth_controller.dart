import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import '../models/media_item.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var phoneNumber = "".obs;
  var isSendingOtp = false.obs;
  var isVerifyingOtp = false.obs;

  var userName = "".obs;
  var userPhone = "".obs;
  var userCity = "".obs;
  var userImageUrl = "".obs;

  var isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Language
    final lang = prefs.getString('language') ?? 'en_US';
    final parts = lang.split('_');
    Get.updateLocale(Locale(parts[0], parts[1]));

    final token = prefs.getString('token');
    isLoggedIn.value = (token != null && token.isNotEmpty);
    
    if (isLoggedIn.value) {
      await fetchProfile();
    }
    isReady.value = true;
  }

  Future<void> setLanguage(String langCode, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', '${langCode}_$countryCode');
    Get.updateLocale(Locale(langCode, countryCode));
  }

  Future<void> fetchProfile() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(Uri.parse("${ApiConfig.auth}/profile"), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        userName.value = data['name'] ?? 'OTT User';
        userPhone.value = data['phone'] ?? '';
        userCity.value = data['city'] ?? '';
        userImageUrl.value = data['imageUrl'] ?? '';
        if (data['_id'] != null) {
          MediaItem.setCurrentUserId(data['_id'].toString());
        }
      }
    } catch (e) {
      print("Profile fetch error: $e");
    }
  }

  Future<bool> updateProfile({required String name, required String city, required String imageUrl}) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.put(
        Uri.parse("${ApiConfig.auth}/profile"),
        headers: headers,
        body: json.encode({'name': name, 'city': city, 'imageUrl': imageUrl})
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        userName.value = data['name'] ?? 'OTT User';
        userCity.value = data['city'] ?? '';
        userImageUrl.value = data['imageUrl'] ?? '';
        Get.snackbar("Success", "Profile updated successfully!", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar("Error", "Failed to update profile", backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Network error", backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  void sendOtp(String phone) async {
    isSendingOtp.value = true;
    phoneNumber.value = phone;
    
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.auth}/send-otp"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone}),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("OTP Sent", "Verification code sent to $phone", snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to send OTP", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSendingOtp.value = false;
    }
  }

  void verifyOtp(String code) async {
    isVerifyingOtp.value = true;
    
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.auth}/verify-otp"),
        headers: {'Content-Type': 'application/json'},
        // Added deviceId to satisfy backend multi-session tracking
        body: json.encode({'phone': phoneNumber.value, 'otp': code, 'deviceId': 'flutter_mobile_app'}),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setBool('isLoggedIn', true);
        
        isLoggedIn.value = true;
        await fetchProfile();
        Get.offAllNamed('/main'); 
      } else {
        Get.snackbar("Error", "Invalid verification code.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Network error", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  void logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      await http.post(
        Uri.parse("${ApiConfig.auth}/logout"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'deviceId': 'flutter_mobile_app'})
      );
      
      await prefs.remove('token');
      await prefs.setBool('isLoggedIn', false);
      
      isLoggedIn.value = false;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", "Logout failed", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
