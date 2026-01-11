import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../services/token_storage.dart';

class ImageUploadService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/upload-image';

  static Future<String> uploadImage(File imageFile) async {
    final token = await TokenStorage.getToken();

    final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // matches multer.single('image')
        imageFile.path,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(body);
      return data['image_url']; // ✅ FIXED
    } else {
      throw Exception('Upload failed: $body');
    }
  }
}
