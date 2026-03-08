import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/post/post_bloc.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../../domain/entities/post_entity.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  const PostDetailPage({super.key, required this.postId});
  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentCtrl = TextEditingController();
  final _focusNode = FocusNode();
  String? _replyingToId;
  String? _replyingToName;

  void _setReply(String commentId, String name) {
    setState(() {
      _replyingToId = commentId;
      _replyingToName = name;
    });
    _focusNode.requestFocus();
  }

  void _clearReply() => setState(() {
        _replyingToId = null;
        _replyingToName = null;
      });

  @override
  void dispose() {
    _commentCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  PostEntity? _findPost(PostState state) {
    if (state is PostLoaded) {
      try {
        return state.posts.firstWhere((p) => p.id == widget.postId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Bài viết',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<PostBloc, PostState>(builder: (context, state) {
        final post = _findPost(state);
        if (post == null) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1877F2)));
        }
        final auth = context.read<AuthBloc>().state;
        final uid = auth is AuthAuthenticated ? auth.user.id : '';
        final myReaction = post.reactionOf(uid);

        return Column(children: [
          Expanded(
              child: ListView(children: [
            Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: AvatarWidget(
                          name: post.authorName,
                          imageUrl: post.authorAvatar,
                          radius: 20),
                      title: Text(post.authorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Row(children: [
                        Text(timeago.format(post.createdAt, locale: 'vi'),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(width: 4),
                        Icon(Icons.public,
                            size: 12, color: Colors.grey.shade600),
                      ]),
                      trailing: const Icon(Icons.more_horiz),
                    ),
                    if (post.content != null && post.content!.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Text(post.content!,
                              style:
                                  const TextStyle(fontSize: 16, height: 1.3))),
                    if (post.mediaUrls.isNotEmpty) _buildMediaContent(post),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        if (post.likeCount > 0) ...[
                          Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                  color: Color(0xFF1877F2),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.thumb_up,
                                  color: Colors.white, size: 10)),
                          const SizedBox(width: 4),
                          Text('${post.likeCount}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ]),
                    ),
                    const Divider(height: 1),
                    Row(children: [
                      Expanded(
                          child: _ReactionButton(
                        myReaction: myReaction,
                        onReact: (t) => context.read<PostBloc>().add(
                            ReactToPostEvent(
                                postId: post.id, userId: uid, reactionType: t)),
                      )),
                      Expanded(
                          child: _ActionButton(
                              icon: Icons.chat_bubble_outline,
                              label: 'Bình luận',
                              onTap: () => _focusNode.requestFocus())),
                      Expanded(
                          child: _ActionButton(
                              icon: Icons.share_outlined,
                              label: 'Chia sẻ',
                              onTap: () {})),
                    ]),
                    const Divider(height: 1),
                  ],
                )),
            const SizedBox(height: 8),
            Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: Text('Tất cả bình luận',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15))),
                    ...post.comments.map((c) => _CommentItem(
                          comment: c,
                          currentUserId: uid,
                          onLike: () => context.read<PostBloc>().add(
                              LikeCommentEvent(
                                  postId: post.id,
                                  commentId: c.id,
                                  userId: uid)),
                          onReply: () => _setReply(c.id, c.authorName),
                          children: c.replies
                              .map((r) => _CommentItem(
                                    comment: r,
                                    currentUserId: uid,
                                    isReply: true,
                                    onLike: () => context.read<PostBloc>().add(
                                        LikeCommentEvent(
                                            postId: post.id,
                                            commentId: r.id,
                                            userId: uid)),
                                    onReply: () =>
                                        _setReply(c.id, r.authorName),
                                  ))
                              .toList(),
                        )),
                    const SizedBox(height: 20),
                  ],
                )),
          ])),
          if (_replyingToName != null)
            Container(
                color: const Color(0xFFE7F3FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  Expanded(
                      child: Text('Đang trả lời $_replyingToName',
                          style: const TextStyle(
                              color: Color(0xFF1877F2),
                              fontSize: 13,
                              fontWeight: FontWeight.bold))),
                  GestureDetector(
                      onTap: _clearReply,
                      child: const Icon(Icons.close,
                          size: 18, color: Color(0xFF1877F2)))
                ])),
          _buildCommentInput(
              context, uid, auth is AuthAuthenticated ? auth.user.name : ''),
        ]);
      }),
    );
  }

  Widget _buildMediaContent(PostEntity post) {
    return Column(
      children: List.generate(post.mediaUrls.length, (index) {
        final url = post.mediaUrls[index];
        final type =
            post.mediaTypes.length > index ? post.mediaTypes[index] : 'image';
        if (type == 'video') return _VideoPlayerWidget(url: url);
        return Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            child: url.startsWith('http')
                ? Image.network(url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _errorIcon())
                : Image.file(File(url),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _errorIcon()));
      }),
    );
  }

  Widget _errorIcon() => Container(
      height: 200,
      color: Colors.grey.shade200,
      child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 40)));

  Widget _buildCommentInput(BuildContext context, String uid, String name) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 8),
      child: Row(children: [
        BlocBuilder<AuthBloc, AuthState>(builder: (_, auth) {
          final user = auth is AuthAuthenticated ? auth.user : null;
          return AvatarWidget(
              name: user?.name ?? '', imageUrl: user?.avatarUrl, radius: 18);
        }),
        const SizedBox(width: 8),
        Expanded(
            child: TextField(
          controller: _commentCtrl,
          focusNode: _focusNode,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: _replyingToName != null
                ? 'Trả lời $_replyingToName...'
                : 'Viết bình luận...',
            hintStyle: const TextStyle(color: Color(0xFF65676B), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF0F2F5),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded,
                    color: Color(0xFF1877F2), size: 22),
                onPressed: () => _send(context, uid, name)),
          ),
          onSubmitted: (_) => _send(context, uid, name),
        )),
      ]),
    );
  }

  void _send(BuildContext context, String uid, String name) {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || uid.isEmpty) return;
    context.read<PostBloc>().add(AddCommentEvent(
        postId: widget.postId,
        authorId: uid,
        authorName: name,
        content: text,
        parentId: _replyingToId));
    _commentCtrl.clear();
    _clearReply();
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});
  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.url.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url))
        : VideoPlayerController.file(File(widget.url));
    _controller.initialize().then((_) => setState(() => _initialized = true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
          height: 200,
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()));
    }
    return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(alignment: Alignment.center, children: [
          VideoPlayer(_controller),
          GestureDetector(
              onTap: () => setState(() => _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play()),
              child: Icon(_controller.value.isPlaying ? null : Icons.play_arrow,
                  color: Colors.white, size: 50))
        ]));
  }
}

class _ReactionButton extends StatefulWidget {
  final ReactionType? myReaction;
  final Function(ReactionType?) onReact;
  const _ReactionButton({this.myReaction, required this.onReact});
  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton> {
  OverlayEntry? _overlay;

  void _showPicker(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    _overlay = OverlayEntry(
        builder: (_) => Positioned(
              left: 10,
              bottom: MediaQuery.of(context).size.height - offset.dy + 10,
              child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(children: [
                        _pickerIcon('👍', ReactionType.like),
                        _pickerIcon('❤️', ReactionType.love),
                        _pickerIcon('😆', ReactionType.haha),
                        _pickerIcon('😮', ReactionType.wow),
                        _pickerIcon('😢', ReactionType.sad),
                        _pickerIcon('😡', ReactionType.angry),
                      ]))),
            ));
    Overlay.of(context).insert(_overlay!);
  }

  Widget _pickerIcon(String emoji, ReactionType t) => GestureDetector(
      onTap: () {
        widget.onReact(t);
        _overlay?.remove();
      },
      child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(emoji, style: const TextStyle(fontSize: 28))));

  @override
  Widget build(BuildContext context) {
    final hasReact = widget.myReaction != null;
    final label = _getLabel(widget.myReaction);
    final color = _getColor(widget.myReaction);
    return GestureDetector(
      onLongPress: () => _showPicker(context),
      onTap: () => widget.onReact(hasReact ? null : ReactionType.like),
      child: SizedBox(
          height: 44,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(hasReact ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ])),
    );
  }

  String _getLabel(ReactionType? t) {
    if (t == null) return 'Thích';
    switch (t) {
      case ReactionType.like:
        return 'Thích';
      case ReactionType.love:
        return 'Yêu thích';
      case ReactionType.haha:
        return 'Haha';
      case ReactionType.wow:
        return 'Wow';
      case ReactionType.sad:
        return 'Buồn';
      case ReactionType.angry:
        return 'Phẫn nộ';
    }
  }

  Color _getColor(ReactionType? t) {
    if (t == null) return Colors.grey.shade700;
    if (t == ReactionType.like) return const Color(0xFF1877F2);
    if (t == ReactionType.love) return Colors.red;
    return Colors.orange;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
      child: InkWell(
          onTap: onTap,
          child: SizedBox(
              height: 44,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, color: Colors.grey.shade700, size: 20),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13))
              ]))));
}

class _CommentItem extends StatelessWidget {
  final CommentEntity comment;
  final String currentUserId;
  final bool isReply;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final List<Widget> children;

  const _CommentItem(
      {required this.comment,
      required this.currentUserId,
      this.isReply = false,
      required this.onLike,
      required this.onReply,
      this.children = const []});

  @override
  Widget build(BuildContext context) {
    final isLiked = comment.isLikedBy(currentUserId);
    return Padding(
        padding: EdgeInsets.fromLTRB(isReply ? 56 : 12, 4, 12, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AvatarWidget(
                name: comment.authorName,
                imageUrl: comment.authorAvatar,
                radius: isReply ? 14 : 17),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(18)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.authorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(comment.content,
                                style: const TextStyle(fontSize: 14))
                          ])),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(timeago.format(comment.createdAt, locale: 'vi'),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 11)),
                    const SizedBox(width: 12),
                    GestureDetector(
                        onTap: onLike,
                        child: Text(isLiked ? 'Bỏ thích' : 'Thích',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isLiked
                                    ? const Color(0xFF1877F2)
                                    : Colors.grey.shade600))),
                    if (comment.likeCount > 0) ...[
                      const SizedBox(width: 4),
                      Text('${comment.likeCount}👍',
                          style: const TextStyle(fontSize: 11))
                    ],
                    const SizedBox(width: 12),
                    GestureDetector(
                        onTap: onReply,
                        child: const Text('Phản hồi',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF65676B))))
                  ])
                ]))
          ]),
          ...children
        ]));
  }
}
