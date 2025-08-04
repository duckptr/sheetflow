// file_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class FileService {
  static const String _baseUrl = 'http://localhost:8000'; // FastAPI 주소

  static Future<bool> uploadExcelFile(File file) async {
    try {
      final uri = Uri.parse('$_baseUrl/upload');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: basename(file.path),
          ),
        );

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('업로드 오류: $e');
      return false;
    }
  }
}
