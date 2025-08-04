// analysis_page.dart
import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '🔍 업로드된 데이터를 기반으로 분석 결과를 표시합니다.',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
