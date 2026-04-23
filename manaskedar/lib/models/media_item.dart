class Episode {
  final String title;
  final String videoUrl;
  final String duration;
  final String? imageUrl;
  final String? description;

  Episode({required this.title, required this.videoUrl, this.duration = "30m", this.imageUrl, this.description});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      duration: json['duration'] ?? '30m',
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }
}

class MediaItem {
  final String id;
  final String title;
  final String imageUrl;
  final String videoUrl;
  final String type; // 'video', 'audio', 'short'
  final String description;
  final String rating;
  final String year;
  final String duration;
  final String? category;
  final bool isPremium;
  final String? language;
  
  // Episode Data
  final List<Episode> episodes;

  // Interaction Data
  int likesCount;
  int sharesCount;
  int commentsCount;
  int views;
  List<String> likesList;
  bool isSharedLocally; 
  int lastPosition; // In seconds
  bool isFavorite;

  MediaItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.videoUrl,
    required this.type,
    this.category,
    this.description = "",
    this.rating = "4.5",
    this.year = "2024",
    this.duration = "0s",
    this.isPremium = false,
    this.language,
    this.likesCount = 0,
    this.sharesCount = 0,
    this.commentsCount = 0,
    this.views = 0,
    this.likesList = const [],
    this.isSharedLocally = false,
    this.lastPosition = 0,
    this.isFavorite = false,
    this.episodes = const [],
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    List<String> parsedLikes = [];
    if (json['likes'] != null && json['likes'] is List) {
      for (var l in json['likes']) {
        if (l is String) parsedLikes.add(l);
        else if (l is Map && l['_id'] != null) parsedLikes.add(l['_id'].toString());
      }
    }

    String categoryStr = "";
    if (json['category'] != null) {
      if (json['category'] is List) {
        categoryStr = (json['category'] as List).join(", ");
      } else if (json['category'] is String) {
        categoryStr = json['category'];
      }
    }

    String durationStr = "0s";
    if (json['duration'] != null) {
      if (json['duration'] is num) {
        int totalSeconds = (json['duration'] as num).toInt();
        if (totalSeconds >= 3600) {
          durationStr = "${totalSeconds ~/ 3600}h ${(totalSeconds % 3600) ~/ 60}m";
        } else {
          durationStr = "${totalSeconds ~/ 60}m ${totalSeconds % 60}s";
        }
      } else {
        durationStr = json['duration'].toString();
      }
    }

    return MediaItem(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? json['thumbnail'] ?? '',
      videoUrl: json['videoUrl'] ?? json['url'] ?? '',
      type: json['type'] ?? 'video',
      category: categoryStr,
      description: json['description'] ?? '',
      rating: json['rating']?.toString() ?? '4.5',
      year: json['year']?.toString() ?? json['publishingYear']?.toString() ?? '2024',
      duration: durationStr,
      isPremium: json['isPremium'] ?? false,
      language: json['language'],
      likesCount: json['likesCount'] ?? parsedLikes.length,
      likesList: parsedLikes,
      sharesCount: json['shares'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      views: json['views'] ?? 0,
      lastPosition: json['lastPosition'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      episodes: json['episodes'] != null 
          ? (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList() 
          : [],
    );
  }

  // Check if liked
  bool get isLikedByMe {
    return currentUserId != null && likesList.contains(currentUserId);
  }

  static String? currentUserId;
  static void setCurrentUserId(String id) {
    currentUserId = id;
  }

  // Format Helper e.g. 1500 -> 1.5k
  String get formattedLikes => _formatNumber(likesCount);
  String get formattedShares => sharesCount == 0 ? "Share" : _formatNumber(sharesCount);
  String get formattedComments => _formatNumber(commentsCount);

  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}k';
    return num.toString();
  }
}
