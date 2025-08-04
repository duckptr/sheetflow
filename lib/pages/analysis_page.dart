import 'package:flutter/material.dart';
import '../widgets/excel_table.dart';

class AnalysisPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const AnalysisPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final total = result["total_rows"];
    final duplicated = result["duplicated_rows"];
    final preview = List<Map<String, dynamic>>.from(result["preview"]);

    return Scaffold(
      appBar: AppBar(title: const Text("중복 분석 결과")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📊 전체 행 수: $total"),
            Text("⚠️ 중복 행 수: $duplicated"),
            const SizedBox(height: 16),
            const Text("🧾 중복된 행 미리보기:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ExcelTable(data: preview),
            ),
          ],
        ),
      ),
    );
  }
}
