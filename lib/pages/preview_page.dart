// preview_page.dart
import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '📋 정제된 데이터를 미리보기로 보여줍니다.',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
