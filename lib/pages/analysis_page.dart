import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  Map<String, dynamic>? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchAnalysis();
  }

  Future<void> fetchAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/result/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == null) {
          setState(() {
            _error = '분석 결과가 없습니다.';
            _isLoading = false;
          });
          return;
        }
        setState(() {
          _result = data['result'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = json.decode(response.body)['error'] ?? '서버 오류';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '연결 실패: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('❌ 오류: $_error'));
    }

    final total = _result?["total"] ?? 0;
    final duplicated = _result?["duplicated"] ?? 0;

    final rawDuplicates = _result?["duplicates"];
    final List<dynamic> duplicates =
        rawDuplicates is List ? rawDuplicates : <dynamic>[];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('총 항목 수: $total'),
          Text('중복된 항목 수: $duplicated'),
          const SizedBox(height: 16),
          const Text('중복 항목 목록:'),
          const SizedBox(height: 8),
          Expanded(
            child: duplicates.isEmpty
                ? const Text('✅ 중복 항목이 없습니다.')
                : ListView.builder(
                    itemCount: duplicates.length,
                    itemBuilder: (context, index) {
                      final row = duplicates[index];
                      return Card(
                        child: ListTile(
                          title: Text('${row['제품코드']} - ${row['시작시리얼']} ~ ${row['종료시리얼']}'),
                          subtitle: Text('${row['날짜']}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
