import 'package:get/get.dart';
import 'package:manaskedar/models/media_item.dart';


enum DownloadStatus { pending, downloading, completed, failed }

class DownloadItem {
  final MediaItem item;
  var status = DownloadStatus.pending.obs;
  var progress = 0.0.obs;

  DownloadItem({required this.item});
}

class DownloadController extends GetxController {
  var downloadedItems = <DownloadItem>[].obs;

  void startDownload(MediaItem item) {
    // Check if already downloading or downloaded
    if (downloadedItems.any((e) => e.item.id == item.id)) return;

    final downloadItem = DownloadItem(item: item);
    downloadedItems.add(downloadItem);
    
    _simulateDownload(downloadItem);
  }

  void _simulateDownload(DownloadItem downloadItem) async {
    downloadItem.status.value = DownloadStatus.downloading;
    
    // Simulate progress
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 300));
      downloadItem.progress.value = i / 100;
      
      // Update system notification if we were using a real plugin here
      // For now, we update our reactive UI
    }

    downloadItem.status.value = DownloadStatus.completed;
    Get.snackbar(
      "Download Complete", 
      "${downloadItem.item.title} is now available offline.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeDownload(String id) {
    downloadedItems.removeWhere((e) => e.item.id == id);
  }
}
