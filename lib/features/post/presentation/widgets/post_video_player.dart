import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostVideoPlayer extends StatefulWidget {
  final String videoPath;
  const PostVideoPlayer({super.key, required this.videoPath});

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller từ file hệ thống
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Cực kỳ quan trọng để tránh tràn bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 250,
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          // Hiển thị nút Play khi video đang dừng
          if (!_controller.value.isPlaying)
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
        ],
      ),
    );
  }
}