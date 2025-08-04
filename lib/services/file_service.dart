import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class FileService {
  // ⛳️ FastAPI 서버 주소
  static const String _baseUrl = 'http://10.1.25.127:8000'; // 필요 시 변경

  /// 📌 엑셀 업로드 및 중복 분석 결과 받기
  static Future<Map<String, dynamic>?> uploadExcelFile(File file) async {
    try {
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
        return jsonResult['result'];
      } else {
        print('❌ 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 업로드 오류: $e');
    }
    return null;
  }

  /// 📌 제품코드별 시리얼 추적 분석 결과 받기
  static Future<List<dynamic>?> groupSerials(File file) async {
    try {
      final uri = Uri.parse('$_baseUrl/group/');

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
        final respStr = await response.stream.bytesToString();
        final jsonData = json.decode(respStr);
        return jsonData['grouped_by_product'];
      } else {
        print('❌ 그룹 분석 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 그룹 분석 오류: $e');
    }
    return null;
  }

  /// 📌 정렬 기능 API 호출
  static Future<Map<String, dynamic>?> sortExcelFile(File file) async {
    try {
      final uri = Uri.parse('$_baseUrl/sort/sort_excel');

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
        final respStr = await response.stream.bytesToString();
        final jsonData = json.decode(respStr);
        return jsonData; // { "sorted_preview": [...] }
      } else {
        print('❌ 정렬 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 정렬 요청 오류: $e');
    }
    return null;
  }

  /// 📌 파일 생성(다운로드) API 호출
  static Future<List<int>?> generateExcelFile(File file) async {
    try {
      final uri = Uri.parse('$_baseUrl/generate/generate_excel');

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
        // 바이너리 데이터(엑셀 파일)
        return await response.stream.toBytes();
      } else {
        print('❌ 파일 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 파일 생성 요청 오류: $e');
    }
    return null;
  }
}
