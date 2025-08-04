import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/summary_card.dart';
import '../widgets/paginated_excel_table.dart'; // ✅ 변경된 테이블 위젯 import

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
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/result/'));

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
    final List<Map<String, dynamic>> duplicates =
        rawDuplicates is List
            ? List<Map<String, dynamic>>.from(rawDuplicates)
            : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 📊 요약 카드
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: '전체 항목 수',
                  value: '$total',
                  icon: Icons.table_rows,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: '중복 항목 수',
                  value: '$duplicated',
                  icon: Icons.warning,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          const Text(
            '중복 항목 목록',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (duplicates.isEmpty)
            const Text(
              '✅ 중복 항목이 없습니다.',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            )
          else
            PaginatedExcelTable(
              data: duplicates,
            ),
        ],
      ),
    );
  }
}
