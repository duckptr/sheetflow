import 'package:flutter/material.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import 'layout/main_layout.dart';

Process? _backendProcess; // 백엔드 프로세스 변수

Future<bool> waitForBackendReady() async {
  for (int i = 0; i < 10; i++) {
    try {
      final res = await http
          .get(Uri.parse('http://127.0.0.1:8000/docs'))
          .timeout(Duration(seconds: 1));
      if (res.statusCode == 200) {
        print('백엔드 준비 완료!');
        return true;
      }
    } catch (_) {}
    await Future.delayed(Duration(seconds: 1));
    print('백엔드 준비 중... (${i + 1}초)');
  }
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ sheetflow.exe가 있는 폴더에서 sheetflow_backend.exe 실행
  try {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final backendPath = p.join(exeDir, 'sheetflow_backend.exe');

    if (File(backendPath).existsSync()) {
      _backendProcess = await Process.start(backendPath, []);
      print('백엔드 실행 성공: $backendPath');

      // ✅ 백엔드 준비 대기
      final ready = await waitForBackendReady();
      if (!ready) {
        print('⚠ 백엔드 준비 실패 - 앱 종료');
        exit(1);
      }
    } else {
      print('백엔드 실행 파일을 찾을 수 없습니다: $backendPath');
    }
  } catch (e) {
    print('백엔드 실행 실패: $e');
  }

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
        fontFamily: 'JalnanGothic',
      ),
      home: const MainLayoutWrapper(),
    );
  }
}

class MainLayoutWrapper extends StatefulWidget {
  const MainLayoutWrapper({super.key});

  @override
  State<MainLayoutWrapper> createState() => _MainLayoutWrapperState();
}

class _MainLayoutWrapperState extends State<MainLayoutWrapper> {
  @override
  void dispose() {
    // ✅ 앱 종료 시 백엔드 프로세스 종료
    _backendProcess?.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MainLayout();
  }
}
