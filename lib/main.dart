import 'package:flutter/material.dart';
import 'layout/main_layout.dart'; // ← 사이드바 포함된 메인 화면

void main() {
  runApp(const SheetflowApp());
}

class SheetflowApp extends StatelessWidget {
  const SheetflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sheetflow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MainLayout(), // ← 여기가 핵심
    );
  }
}
