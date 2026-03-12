import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    super.authorAvatar,
    super.content,
    super.mediaUrls = const [],
    super.mediaTypes = const [],
    super.likedByIds = const [],
    super.comments = const [],
    required super.createdAt,
    super.isPublic = true,
    super.sharedPost,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // 1. Lấy link ảnh đại diện từ WordPress (nếu có)
    String coverImage = '';
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        json['_embedded']['wp:featuredmedia'].isNotEmpty) {
      coverImage = json['_embedded']['wp:featuredmedia'][0]['source_url'] ?? '';
    }

    // 2. Lấy thông tin tác giả từ WordPress
    String author = 'Admin';
    String avatar = '';
    if (json['_embedded'] != null &&
        json['_embedded']['author'] != null &&
        json['_embedded']['author'].isNotEmpty) {
      author = json['_embedded']['author'][0]['name'] ?? 'Admin';
      // Lấy avatar của tác giả trên web (nếu có)
      avatar = json['_embedded']['author'][0]['avatar_urls']?['96'] ?? '';
    }

    // 3. Xử lý Tiêu đề và Nội dung
    String title = json['title']?['rendered'] ?? '';
    String rawContent = json['content']?['rendered'] ?? '';

    // Ghép thẳng tiêu đề vào nội dung bằng thẻ in đậm của HTML để hiển thị trên app
    String finalContent = '';
    if (title.isNotEmpty) {
      finalContent += '<h2>$title</h2>';
    }
    finalContent += rawContent;

    return PostModel(
      id: json['id'].toString(),
      authorId: json['author'].toString(), // ID của tác giả trên web
      authorName: author,
      authorAvatar: avatar,
      content: finalContent,
      // Đưa ảnh cover vào danh sách mediaUrls của app
      mediaUrls: coverImage.isNotEmpty ? [coverImage] : [],
      mediaTypes: coverImage.isNotEmpty ? ['image'] : [],
      createdAt: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      // Các trường như likedByIds, comments không cần truyền vì đã có const [] mặc định
    );
  }
}