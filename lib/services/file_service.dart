import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class FileService {
  // ⛳️ FastAPI 서버 주소
  static const String _baseUrl = 'http://10.1.25.127:8000'; // 필요 시 변경

  static Future<Map<String, dynamic>?> uploadExcelFile(File file) async {
    try {
      // ✅ 슬래시(/) 추가로 리디렉션 방지
      final uri = Uri.parse('$_baseUrl/upload/');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: basename(file.path),
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResult = jsonDecode(responseBody);

        return jsonResult['result']; // FastAPI에서 반환하는 분석 결과
      } else {
        print('❌ 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 업로드 오류: $e');
    }
    return null;
  }
}
