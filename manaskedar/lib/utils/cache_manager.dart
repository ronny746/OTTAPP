import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'manaskedarMediaCache';
  
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200, // Maximum items
      repo: JsonCacheInfoRepository(databaseName: key), // Local JSON tracking
      fileService: HttpFileService(),
    ),
  );
}
