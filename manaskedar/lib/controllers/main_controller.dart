import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manaskedar/controllers/auth_controller.dart';
import '../models/media_item.dart';
import '../utils/api_config.dart';
import '../utils/cache_manager.dart';
import 'main_screen_controller.dart';

class HomeSection {
  final String title;
  final String subtitle;
  final List<MediaItem> items;

  HomeSection({required this.title, required this.subtitle, required this.items});
}

class MainController extends GetxController {
  var isLoading = true.obs;
  var banners = <MediaItem>[].obs;
  var popularVideos = <MediaItem>[].obs;
  var audiobooks = <MediaItem>[].obs;
  var shorts = <MediaItem>[].obs;
  var shows = <MediaItem>[].obs;
  var continueWatching = <MediaItem>[].obs;
  var homeSections = <HomeSection>[].obs;

  var categoriesList = <String>["All"].obs;

  final PageController shortsPageController = PageController();
  var currentShortIndex = 0.obs;
  var currentBannerIndex = 0.obs;
  var selectedShortsCategory = "All".obs;

  List<MediaItem> get filteredShorts {
    if (selectedShortsCategory.value == "All") return shorts;
    return shorts.where((s) => s.category?.toLowerCase() == selectedShortsCategory.value.toLowerCase()).toList();
  }

  void playShort(MediaItem item) {
    selectedShortsCategory.value = "All"; 
    int index = shorts.indexWhere((s) => s.id == item.id);
    if (index != -1) {
      Get.find<MainScreenController>().selectedIndex.value = 2; // Switch to Shorts Tab
      if (shortsPageController.hasClients) {
        shortsPageController.jumpToPage(index);
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (shortsPageController.hasClients) shortsPageController.jumpToPage(index);
        });
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      isLoading(true);
      await fetchHomeData();
      await fetchCategoriesList();
      preCacheMedia();
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchHomeData() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.home), headers: headers);
      
      print("Home Data Response Status: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = ApiConfig.decode(response.body);
        
        // Populate Banners
        if (data['banners'] != null) {
          banners.value = (data['banners'] as List).map((b) => MediaItem.fromJson(b['mediaId'])).toList();
        }

        // Populate Sections with robust parsing
        if (data['sections'] != null) {
          List<HomeSection> parsedSections = [];
          for (var s in (data['sections'] as List)) {
             try {
               final String title = s['title'] ?? '';
               final String subtitle = s['subtitle'] ?? '';
               final List itemsJson = s['items'] ?? [];
               final List<MediaItem> items = itemsJson.map((m) => MediaItem.fromJson(m)).toList();
               
               if (items.isNotEmpty) {
                 parsedSections.add(HomeSection(title: title, subtitle: subtitle, items: items));
               }
             } catch (e) {
               print("Error parsing section: $e");
             }
          }
          homeSections.value = parsedSections;

          // Clear previous values to ensure fresh load
          shorts.clear();
          shows.clear();
          audiobooks.clear();
          popularVideos.clear();
          continueWatching.clear();

          // Sync categorized lists based on case-insensitive keywords
          for (var section in homeSections) {
             final String upperTitle = section.title.toUpperCase();
             if (upperTitle.contains('SHORT')) {
               shorts.value = section.items;
             } else if (upperTitle.contains('SHOW')) {
               shows.value = section.items;
             } else if (upperTitle.contains('AUDIO') || upperTitle.contains('NADA')) {
               audiobooks.value = section.items;
             } else if (upperTitle.contains('MOVIE') || upperTitle.contains('MAHA')) {
               popularVideos.value = section.items;
             } else if (upperTitle.contains('WATCHING') || upperTitle.contains('CONTINUE')) {
               continueWatching.value = section.items;
             }
          }
        }
      } else if (response.statusCode == 401) {
          Get.snackbar("Session Expired", "Please login again to sync with the new server.", 
            backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
          Get.find<AuthController>().logout();
      }
    } catch (e) {
      print("Error fetching home data: $e");
      Get.snackbar("Network Error", "Unable to reach the server. Check your Internet or IP config.", 
        backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchCategoriesList() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.categories), headers: headers);
      if (response.statusCode == 200) {
        List data = ApiConfig.decode(response.body);
        categoriesList.value = ["All", ...data.map((c) => c['name'].toString())];
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  void preCacheMedia() {
    print("🚀 Pro-Active Video Caching Starting...");
    for (var i = 0; i < popularVideos.length && i < 2; i++) {
        final url = popularVideos[i].videoUrl;
        if (url.isNotEmpty && Uri.tryParse(url)?.hasAuthority == true) {
            CustomCacheManager.instance.downloadFile(url).catchError((e) => print("Cache Movie Error: $e"));
        }
    }

    for (var i = 0; i < shorts.length && i < 5; i++) {
        final url = shorts[i].videoUrl;
        if (url.isNotEmpty && Uri.tryParse(url)?.hasAuthority == true) {
            CustomCacheManager.instance.downloadFile(url).catchError((e) => print("Cache Shorts Error: $e"));
        }
    }
  }
}
