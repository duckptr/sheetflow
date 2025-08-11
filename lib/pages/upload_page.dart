import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  // 파일 처리 상태
  String? _processStatus;
  // 통계 처리 상태
  String? _statsStatus;

  // 파일 처리 결과 저장
  List<Map<String, dynamic>> _analyses = [];

  // 통계 데이터 저장
  List<dynamic>? _statsData;
  String? _statsFileName;

  Future<Map<String, dynamic>?> _analyzeExcel(File file) async {
    final uri = Uri.parse('http://localhost:8000/analyze/analyze_excel');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    final res = await req.send();
    if (res.statusCode == 200) {
      final body = await res.stream.bytesToString();
      return json.decode(body) as Map<String, dynamic>;
    }
    return null;
  }

  // 1. 파일 처리: 정렬, 중복 확인
  Future<void> _processFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() => _processStatus = '처리 중...');
      _analyses.clear();
      for (var f in result.files) {
        if (f.path == null) continue;
        final resp = await _analyzeExcel(File(f.path!));
        if (resp != null) {
          final stats = resp['product_stats'] is List<dynamic>
              ? resp['product_stats'] as List<dynamic>
              : <dynamic>[];
          _analyses.add({
            'fileName': f.name,
            'filePath': f.path!,
            'product_stats': stats,
          });
        }
      }
      setState(() {
        _processStatus = _analyses.isNotEmpty ? '완료' : '실패';
      });
    }
  }

  // 2. 통계 업로드: 차트용 데이터
  Future<void> _uploadStats() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _statsStatus = '분석 중...';
        _statsFileName = result.files.single.name;
      });
      final resp = await _analyzeExcel(File(result.files.single.path!));
      setState(() {
        if (resp != null && resp['product_stats'] is List<dynamic>) {
          _statsData = resp['product_stats'] as List<dynamic>;
          _statsStatus = '통계 완료';
        } else {
          _statsData = null;
          _statsStatus = '통계 실패';
        }
      });
    }
  }

  // 3. 처리 결과 다운로드: Downloads 폴더 저장
  Future<void> _downloadResults() async {
    if (_analyses.isEmpty) return;
    setState(() => _processStatus = '다운로드 중...');
    final downloadsDir = Directory('${Platform.environment['USERPROFILE']}\\Downloads');
    final List<String> saved = [];
    for (var a in _analyses) {
      final path = a['filePath'] as String;
      final uri = Uri.parse('http://localhost:8000/analyze/download_result');
      final req = http.MultipartRequest('POST', uri);
      req.files.add(await http.MultipartFile.fromPath('file', path));
      final res = await req.send();
      if (res.statusCode == 200) {
        final bytes = await res.stream.toBytes();
        final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final savePath = '${downloadsDir.path}\\${a['fileName']}_$ts.xlsx';
        await File(savePath).writeAsBytes(bytes);
        saved.add(savePath);
      }
    }
    setState(() => _processStatus = saved.isNotEmpty ? '다운로드 완료' : '다운로드 실패');
    if (saved.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다운로드: ${saved.join(', ')}')),
      );
    }
  }

  Color _statusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.contains('중')) return Colors.blue;
    if (status.contains('완료')) return Colors.green;
    if (status.contains('실패')) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchHeader(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProcessCard(),
              const SizedBox(width: 16),
              _buildStatsCard(),
            ],
          ),
          if (_statsData != null) ...[
            const SizedBox(height: 32),
            _buildCharts(_statsData!, _statsFileName!),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: const InputDecoration.collapsed(
                    hintText: '제품코드를 검색하세요'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      );

  Widget _buildProcessCard() => Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('파일 업로드', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _processFiles,
                child: const Text('파일 선택 및 처리'),
              ),
              const SizedBox(height: 8),
              if (_processStatus != null)
                Text('상태: $_processStatus', style: TextStyle(color: _statusColor(_processStatus))),
              if (_analyses.isNotEmpty) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _downloadResults,
                  child: const Text('다운로드'),
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildStatsCard() => Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('통계 업로드', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _uploadStats,
                child: const Text('통계 파일 선택'),
              ),
              const SizedBox(height: 8),
              if (_statsStatus != null)
                Text('상태: $_statsStatus', style: TextStyle(color: _statusColor(_statsStatus))),
            ],
          ),
        ),
      );

  Widget _buildCharts(List<dynamic> data, String fileName) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fileName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // 수율 차트
          LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    return i < data.length ? Text(data[i]['product_code']) : const Text('');
                  },
                )),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: List.generate(data.length,
                      (i) => FlSpot(i.toDouble(), (data[i]['ship_rate'] as num).toDouble())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 불량률 차트
          LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    return i < data.length ? Text(data[i]['product_code']) : const Text('');
                  },
                )),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: List.generate(data.length,
                      (i) => FlSpot(i.toDouble(), 100 - (data[i]['ship_rate'] as num).toDouble())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 불량 수량 차트
          BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    return i < data.length ? Text(data[i]['product_code']) : const Text('');
                  },
                )),
              ),
              barGroups: List.generate(data.length, (i) {
                final total = data[i]['testedqty'] as int;
                final good = data[i]['goodqty'] as int;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: (total - good).toDouble(),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          // 판매 수량 차트
          BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    return i < data.length ? Text(data[i]['product_code']) : const Text('');
                  },
                )),
              ),
              barGroups: List.generate(data.length, (i) {
                final good = data[i]['goodqty'] as int;
                return BarChartGroupData(
                  x: i,
                  barRods: [BarChartRodData(toY: good.toDouble())],
                );
              }),
            ),
          ),
        ],
      );
}
