import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../utils/api_config.dart';
import '../models/media_item.dart';
import '../models/comment_model.dart';

class InteractionController extends GetxController {
  Future<void> toggleLike(MediaItem item) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.post(
        Uri.parse("${ApiConfig.user}/interactions/like/${item.id}"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = ApiConfig.decode(response.body);
        item.likesCount = data['likesCount'];
        if (data['likes'] != null) {
          item.likesList = (data['likes'] as List).map((e) => e.toString()).toList();
        } else {
          // Fallback optimistic update
          if (item.isLikedByMe) {
            item.likesList.remove(MediaItem.currentUserId);
          } else {
            if (MediaItem.currentUserId != null) item.likesList.add(MediaItem.currentUserId!);
          }
        }
        update();
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }

  Future<void> incrementShare(MediaItem item) async {
    try {
      final String shareText =
          "Check out '${item.title}' on Manaskedar OTT!\n\nDownload the app to watch it now!";
      await Share.share(shareText);

      // Only increment on server once per session/user locally
      if (item.isSharedLocally) return;

      final headers = await ApiConfig.getHeaders();
      final response = await http.post(
        Uri.parse("${ApiConfig.user}/interactions/share/${item.id}"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = ApiConfig.decode(response.body);
        item.sharesCount = data['shares'];
        item.isSharedLocally = true;
        update();
      }
    } catch (e) {
      print("Share Error: $e");
    }
  }

  var comments = <CommentModel>[].obs;
  var isCommentsLoading = false.obs;

  Future<void> fetchComments(String mediaId) async {
    try {
      isCommentsLoading(true);
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(
        Uri.parse("${ApiConfig.user}/interactions/comments/$mediaId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = ApiConfig.decode(response.body);
        List<CommentModel> flatComments = data
            .map((c) => CommentModel.fromJson(c))
            .toList();

        // Build Tree
        List<CommentModel> roots = [];
        Map<String, CommentModel> map = {};
        for (var c in flatComments) {
          map[c.id] = c;
        }

        for (var c in flatComments) {
          if (c.parentCommentId != null && map.containsKey(c.parentCommentId)) {
            map[c.parentCommentId]!.replies.add(c);
          } else {
            roots.add(c);
          }
        }

        comments.value = roots;
      }
    } catch (e) {
      print("Fetch Comments Error: $e");
    } finally {
      isCommentsLoading(false);
    }
  }

  Future<void> postComment(
    MediaItem item,
    String text, {
    String? parentId,
  }) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.post(
        Uri.parse("${ApiConfig.user}/interactions/comment"),
        headers: headers,
        body: ApiConfig.encode({
          'mediaId': item.id,
          'text': text,
          'parentId': parentId,
        }),
      );

      if (response.statusCode == 201) {
        final data = ApiConfig.decode(response.body);
        final newComment = CommentModel.fromJson(data);

        if (parentId != null) {
          // Find parent and attach
          for (var c in comments) {
            if (c.id == parentId) {
              c.replies.add(newComment);
              break;
            }
          }
        } else {
          comments.insert(0, newComment);
        }

        item.commentsCount += 1;
        comments.refresh();
        update();
      }
    } catch (e) {
      print("Comment Error: $e");
    }
  }

  Future<void> toggleCommentLike(String commentId) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.post(
        Uri.parse("${ApiConfig.user}/interactions/comment/$commentId/like"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = ApiConfig.decode(response.body);

        // Find comment and update likesCount
        void updateLikes(List<CommentModel> list) {
          for (var c in list) {
            if (c.id == commentId) {
              c.likesCount = data['likesCount'];
              if (data['likes'] != null) {
                c.likesList = (data['likes'] as List).map((e) => e.toString()).toList();
              } else {
                if (c.isLikedByMe) {
                  c.likesList.remove(MediaItem.currentUserId);
                } else {
                  if (MediaItem.currentUserId != null) c.likesList.add(MediaItem.currentUserId!);
                }
              }
              return;
            }
            updateLikes(c.replies); // recursive for deep nesting if any
          }
        }

        updateLikes(comments);
        comments.refresh();
      }
    } catch (e) {
      print("Comment Like Error: $e");
    }
  }

  // --- NEW: History & Favorites ---
  var watchHistory = <MediaItem>[].obs;
  var isHistoryLoading = false.obs;

  Future<void> fetchWatchHistory() async {
    try {
      isHistoryLoading(true);
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.history), headers: headers);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        watchHistory.value = data.map((h) {
          final media = MediaItem.fromJson(h['media']);
          media.lastPosition = h['position'] ?? 0;
          return media;
        }).toList();
      }
    } catch (e) {
      print("History Error: $e");
    } finally {
      isHistoryLoading(false);
    }
  }

  Future<void> updatePosition(String mediaId, int seconds) async {
    try {
      final headers = await ApiConfig.getHeaders();
      await http.post(
        Uri.parse(ApiConfig.history),
        headers: headers,
        body: json.encode({'mediaId': mediaId, 'position': seconds}),
      );
    } catch (e) {
      print("Update Position Error: $e");
    }
  }

  var watchFavorites = <MediaItem>[].obs;
  var isFavoritesLoading = false.obs;

  Future<void> fetchFavorites() async {
    try {
      isFavoritesLoading(true);
      final headers = await ApiConfig.getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.favorites), headers: headers);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        watchFavorites.value = data.map((m) {
          final media = MediaItem.fromJson(m);
          media.isFavorite = true;
          return media;
        }).toList();
      }
    } catch (e) {
      print("Fetch Favorites Error: $e");
    } finally {
      isFavoritesLoading(false);
    }
  }

  Future<void> toggleFavorite(MediaItem item) async {
    try {
      final headers = await ApiConfig.getHeaders();
      final response = await http.post(
        Uri.parse("${ApiConfig.favorites}/${item.id}"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = ApiConfig.decode(response.body);
        item.isFavorite = data['isFavorite'];
        
        // Update local list if we have it
        if (!item.isFavorite) {
          watchFavorites.removeWhere((m) => m.id == item.id);
        } else if (!watchFavorites.any((m) => m.id == item.id)) {
          watchFavorites.add(item);
        }
        
        update();
      }
    } catch (e) {
      print("Favorite Error: $e");
    }
  }
}
