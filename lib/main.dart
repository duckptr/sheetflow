import 'package:flutter/material.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';

import 'layout/main_layout.dart'; // 사이드바 포함된 메인 레이아웃

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 데스크탑 환경에서만 창 크기 고정
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    const windowSize = Size(1150, 800);
    setWindowTitle('SheetFlow');
    setWindowMinSize(windowSize);
    setWindowMaxSize(windowSize);
  }

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
        fontFamily: 'JalnanGothic', // ✅ 여기서 폰트 적용
      ),
      home: const MainLayout(),
    );
  }
}
