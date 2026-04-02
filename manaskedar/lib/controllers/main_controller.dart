import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import '../utils/api_config.dart';
import 'main_screen_controller.dart';

class MainController extends GetxController {
  var isLoading = true.obs;
  var banners = <MediaItem>[].obs;
  var popularVideos = <MediaItem>[].obs;
  var audiobooks = <MediaItem>[].obs;
  var shorts = <MediaItem>[].obs;
  var shows = <MediaItem>[].obs;

  final PageController shortsPageController = PageController();

  void playShort(MediaItem item) {
    int index = shorts.indexWhere((s) => s.id == item.id);
    if (index != -1) {
      Get.find<MainScreenController>().selectedIndex.value = 2; // Switch to Shorts Tab
      if (shortsPageController.hasClients) {
        shortsPageController.jumpToPage(index);
      } else {
        // If not initialized yet, use a small delay or set initial page 
        // But jumpToPage usually works once tab is switched and built 
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
        fetchSpecificMedia(ApiConfig.movies, popularVideos),
        fetchSpecificMedia(ApiConfig.audios, audiobooks),
        fetchSpecificMedia(ApiConfig.shorts, shorts),
        fetchSpecificMedia(ApiConfig.shows, shows),
      ]);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBanners() async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.banners), headers: headers);
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
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
        List data = json.decode(response.body);
        targetList.value = data.map((m) => MediaItem.fromJson(m)).toList();
      }
    } catch (e) {
      print("Error fetching $url: $e");
    }
  }
}
