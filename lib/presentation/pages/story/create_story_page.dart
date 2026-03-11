import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/story_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/story/story_bloc.dart';
import '../../../data/datasources/remote/supabase_remote_datasource.dart';
import '../../../injection_container.dart' as di;
import '../../widgets/common/avatar_widget.dart';

class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  String? _mediaPath;
  String? _mediaType;
  bool _loading = false;
  String _backgroundColor = '#1877F2';

  final List<String> _colors = [
    '#1877F2', '#FF4B2B', '#1D976C', '#8E2DE2', '#F2994A', '#2193b0'
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _canShare => _textController.text.trim().isNotEmpty || _mediaPath != null;

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() {
        _mediaPath = file.path;
        _mediaType = 'image';
      });
    }
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _mediaPath = file.path;
        _mediaType = 'video';
      });
    }
  }

  Future<void> _takePhoto() async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file != null) {
      setState(() {
        _mediaPath = file.path;
        _mediaType = 'image';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black, size: 30),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text('Tạo tin',
                      style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: (_loading || !_canShare) ? null : _submit,
                      style: TextButton.styleFrom(
                        backgroundColor: _canShare ? const Color(0xFF1877F2) : Colors.grey.shade200,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      child: _loading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('CHIA SẺ', style: TextStyle(color: _canShare ? Colors.white : Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile
                    Row(
                      children: [
                        AvatarWidget(name: user?.name ?? '', imageUrl: user?.avatarUrl, radius: 22),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.public, size: 14, color: Color(0xFF65676B)),
                                  SizedBox(width: 4),
                                  Text('Tin của bạn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF65676B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Text Input / Preview Area
                    if (_mediaPath == null)
                      Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(int.parse(_backgroundColor.replaceFirst('#', '0xFF'))),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _textController,
                            maxLines: null,
                            textAlign: TextAlign.center,
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: 'Bắt đầu nhập...',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      )
                    else
                      _buildMediaPreview(),

                    const SizedBox(height: 20),
                    if (_mediaPath == null) ...[
                      const Text('Chọn màu nền:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _colors.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => setState(() => _backgroundColor = _colors[index]),
                              child: Container(
                                margin: const EdgeInsets.only(right: 14),
                                width: 44,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(_colors[index].replaceFirst('#', '0xFF'))),
                                  shape: BoxShape.circle,
                                  border: _backgroundColor == _colors[index] ? Border.all(color: Colors.black, width: 2.5) : Border.all(color: Colors.grey.shade300),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            _buildBottomToolBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 450),
            width: double.infinity,
            color: Colors.grey.shade100,
            child: _mediaType == 'video'
                ? Container(
                    color: Colors.black,
                    child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)))
                : (kIsWeb ? Image.network(_mediaPath!) : Image.file(File(_mediaPath!))),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => setState(() {
              _mediaPath = null;
              _mediaType = null;
            }),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          const Text('Thêm vào tin của bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          _ToolIcon(icon: Icons.photo_library, color: Colors.green, onTap: _pickImage),
          _ToolIcon(icon: Icons.videocam, color: Colors.red, onTap: _pickVideo),
          _ToolIcon(icon: Icons.camera_alt, color: Colors.blue, onTap: _takePhoto),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    setState(() => _loading = true);

    try {
      String? url;
      if (_mediaPath != null) {
        final remote = di.sl<SupabaseRemoteDatasource>();
        final xFile = XFile(_mediaPath!);
        final bytes = await xFile.readAsBytes();
        final ext = xFile.name.contains('.') ? xFile.name.split('.').last.toLowerCase() : 'jpg';
        url = await remote.uploadPostMediaBytes(auth.user.id, bytes, ext);
      }

      final story = StoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: auth.user.id,
        userName: auth.user.name,
        userAvatar: auth.user.avatarUrl,
        type: _mediaPath != null ? (_mediaType == 'video' ? StoryType.video : StoryType.image) : StoryType.text,
        url: url,
        content: _mediaPath == null ? _textController.text.trim() : null,
        backgroundColor: _mediaPath == null ? _backgroundColor : null,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      if (mounted) {
        context.read<StoryBloc>().add(CreateStoryEvent(story));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ToolIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 26),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      constraints: const BoxConstraints(),
    );
  }
}
