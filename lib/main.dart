import 'package:flutter/material.dart';
import 'layout/main_layout.dart'; // 사이드바 포함된 메인 레이아웃

void main() {
  runApp(const SheetflowApp());
}

class SheetflowApp extends StatelessWidget {
  const SheetflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SheetFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        fontFamily: 'Roboto', // 시스템 폰트 or 원하는 폰트
      ),
      home: const MainLayout(),
    );
  }
}
