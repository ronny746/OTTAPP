import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/media_item.dart';
import '../models/comment_model.dart';
import '../controllers/interaction_controller.dart';
import '../utils/app_theme.dart';

class CommentSheet extends StatefulWidget {
  final MediaItem item;
  const CommentSheet({super.key, required this.item});

  @override
  _CommentSheetState createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final InteractionController _interactionController = Get.put(InteractionController());
  final TextEditingController _textController = TextEditingController();
  CommentModel? _replyingTo;

  @override
  void initState() {
    super.initState();
    _interactionController.fetchComments(widget.item.id);
  }

  void _submitComment() async {
    if (_textController.text.trim().isEmpty) return;
    
    final text = _textController.text.trim();
    final parentId = _replyingTo?.id;
    
    _textController.clear();
    setState(() => _replyingTo = null); // clear reply state
    
    await _interactionController.postComment(widget.item, text, parentId: parentId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 15),
          const Text("Comments", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24, height: 30),
          
          Expanded(
            child: Obx(() {
              if (_interactionController.isCommentsLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }

              if (_interactionController.comments.isEmpty) {
                return const Center(child: Text("No comments yet. Be the first to comment!", style: TextStyle(color: Colors.grey)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: _interactionController.comments.length,
                itemBuilder: (context, index) {
                  final comment = _interactionController.comments[index];
                  return _buildCommentTile(comment);
                },
              );
            }),
          ),
          
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: isReply ? 40 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            radius: isReply ? 14 : 18,
            child: Text(comment.userName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.userName, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(comment.timeAgo, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(comment.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                         await _interactionController.toggleCommentLike(comment.id);
                         setState((){});
                      },
                      child: Text("Like", style: TextStyle(color: comment.isLikedByMe ? Colors.red : Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 25),
                    GestureDetector(
                      onTap: () {
                         setState(() {
                           _replyingTo = comment;
                         });
                      },
                      child: const Text("Reply", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (comment.replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      children: comment.replies.map((reply) => _buildCommentTile(reply, isReply: true)).toList(),
                    ),
                  )
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                 onTap: () async {
                   await _interactionController.toggleCommentLike(comment.id);
                   setState((){});
                 },
                 child: Icon(
                   comment.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                   color: comment.isLikedByMe ? Colors.red : Colors.grey, 
                   size: 16
                 ),
              ),
              const SizedBox(height: 5),
              Text(comment.likesCount > 0 ? comment.likesCount.toString() : "", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 15, right: 15, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingTo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text("Replying to ${_replyingTo!.userName}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: const Icon(Icons.close, color: Colors.grey, size: 16),
                  )
                ],
              ),
            ),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _submitComment,
                child: const Icon(Icons.send, color: AppTheme.primaryColor),
              )
            ],
          ),
        ],
      ),
    );
  }
}
