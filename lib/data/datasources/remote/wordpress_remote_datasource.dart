import 'dart:io'; // Thêm thư viện này
import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Thêm thư viện cấu hình kết nối sâu của Dio
import '../../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
}

class WordPressRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  WordPressRemoteDataSourceImpl({required this.dio}) {
    // 🔥 BƯỚC ĐỘT PHÁ 1: Vượt rào kiểm tra chứng chỉ SSL khắt khe của điện thoại Android
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      // --- BẮT ĐẦU GỌI API ĐẾN TRANG WEB --- 

      // 🔥 BƯỚC ĐỘT PHÁ 2: Giả lập 100% thiết bị Android thật lướt web
      final response = await dio.get(
        'https://shopcuahau.id.vn/wp-json/wp/v2/posts',
        // Đổi true thành '1' (API của WordPress thường chuộng số 1 hơn chữ true để tránh lỗi định dạng)
        queryParameters: {'_embed': '1'},
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 12; SM-S906N Build/QP1A.190711.020) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
            'Accept': '*/*',
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate, br',
          },
        ),
      );

      // --- KẾT NỐI THÀNH CÔNG! ---

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        // --- LẤY ĐƯỢC BÀI VIẾT TỪ WEB --- 

        return jsonList.map((json) {
          try {
            return PostModel.fromJson(json);
          } catch (e) {
            // --- LỖI KHI BÓC TÁCH DỮ LIỆU --- 
            rethrow;
          }
        }).toList();
      } else {
        // --- LỖI SERVER --- 
        throw Exception('Lỗi server: Không thể tải bài viết');
      }
    } catch (e) {
      // --- LỖI KẾT NỐI MẠNG HOẶC API --- 
      throw Exception('Lỗi kết nối API: $e');
    }
  }
}