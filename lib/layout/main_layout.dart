import 'package:flutter/material.dart';
import '../pages/upload_page.dart';
import '../pages/preview_page.dart';
import 'topbar.dart';
import '../layout/sidebar.dart'; // 📌 새 Sidebar 위젯 임포트

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _refinedData = [];

  final List<String> _titles = [
    '파일 업로드',
    '정제된 데이터 미리보기',
  ];

  void _handleRefinedData(List<Map<String, dynamic>> data) {
    setState(() {
      _refinedData = data;
      _selectedIndex = 1; // 업로드 후 자동으로 미리보기로 이동
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      UploadPage(onRefinedData: _handleRefinedData),
      PreviewPage(data: _refinedData),
    ];

    return Scaffold(
      body: Row(
        children: [
          /// ✅ 기존 NavigationRail 대신 Sidebar 사용
          Sidebar(
            selectedRoute: _selectedIndex == 0 ? '/upload' : '/preview',
            onRouteSelected: (route) {
              setState(() {
                _selectedIndex = (route == '/upload') ? 0 : 1;
              });
            },
          ),

          /// ✅ 메인 영역
          Expanded(
            child: Scaffold(
              backgroundColor: const Color(0xFFF6F8FA),
              appBar: TopBar(title: _titles[_selectedIndex]),
              body: pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
