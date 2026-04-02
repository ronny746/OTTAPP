import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import '../utils/api_config.dart';
import '../utils/cache_manager.dart';
import 'main_screen_controller.dart';

class MainController extends GetxController {
  var isLoading = true.obs;
  var banners = <MediaItem>[].obs;
  var popularVideos = <MediaItem>[].obs;
  var audiobooks = <MediaItem>[].obs;
  var shorts = <MediaItem>[].obs;
  var shows = <MediaItem>[].obs;
  var categoriesList = <String>["All"].obs;

  final PageController shortsPageController = PageController();
  var currentShortIndex = 0.obs;
  var selectedShortsCategory = "All".obs;

  List<MediaItem> get filteredShorts {
    if (selectedShortsCategory.value == "All") return shorts;
    return shorts.where((s) => s.category?.toLowerCase() == selectedShortsCategory.value.toLowerCase()).toList();
  }

  void playShort(MediaItem item) {
    // We switch to All if playing a specific short to ensure it's found
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
      await Future.wait([
        fetchBanners(),
        fetchCategoriesList(),
        fetchSpecificMedia(ApiConfig.movies, popularVideos),
        fetchSpecificMedia(ApiConfig.audios, audiobooks),
        fetchSpecificMedia(ApiConfig.shorts, shorts),
        fetchSpecificMedia(ApiConfig.shows, shows),
      ]);
      preCacheMedia();
    } finally {
      isLoading(false);
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
    // Only cache if URL is valid
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

  Future<void> fetchBanners() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.banners), headers: headers);
      if (response.statusCode == 200) {
        List data = ApiConfig.decode(response.body);
        banners.value = data.map((b) => MediaItem.fromJson(b['mediaId'])).toList();
      }
    } catch (e) {
      print("Error fetching banners: $e");
    }
  }

  Future<void> fetchSpecificMedia(String url, RxList<MediaItem> targetList) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        List data = ApiConfig.decode(response.body);
        targetList.value = data.map((m) => MediaItem.fromJson(m)).toList();
      }
    } catch (e) {
      print("Error fetching $url: $e");
    }
  }
}
