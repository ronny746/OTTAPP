import 'media_item.dart';

class CommentModel {
  final String id;
  final String mediaId;
  final String userId;
  final String userName;
  final String text;
  int likesCount;
  final String? parentCommentId;
  final DateTime createdAt;

  // Local state
  List<CommentModel> replies = [];
  List<String> likesList = [];

  CommentModel({
    required this.id,
    required this.mediaId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.likesCount,
    this.parentCommentId,
    required this.createdAt,
    this.likesList = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedLikes = [];
    if (json['likes'] != null) {
      for (var l in json['likes']) {
        if (l is String) parsedLikes.add(l);
        if (l is Map && l['_id'] != null) parsedLikes.add(l['_id'].toString());
      }
    }

    return CommentModel(
      id: json['_id'] ?? '',
      mediaId: json['mediaId'] ?? '',
      userId: json['user'] is Map ? json['user']['_id'] : (json['user'] ?? ''),
      userName: json['user'] is Map ? (json['user']['name'] ?? 'User') : 'User',
      text: json['text'] ?? '',
      likesCount: parsedLikes.length,
      likesList: parsedLikes,
      parentCommentId: json['parentCommentId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  bool get isLikedByMe {
    return MediaItem.currentUserId != null && likesList.contains(MediaItem.currentUserId);
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 7) return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'Just now';
  }
}
