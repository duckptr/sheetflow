import 'package:flutter/material.dart';
import '../pages/upload_page.dart';
import '../pages/preview_page.dart';
import 'topbar.dart';

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

  final List<NavigationRailDestination> _destinations = [
    NavigationRailDestination(
      icon: Tooltip(
        message: '업로드',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Icon(Icons.upload_file_outlined),
        ),
      ),
      selectedIcon: Tooltip(
        message: '업로드',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Icon(Icons.upload_file),
        ),
      ),
      label: const Text('업로드'),
    ),
    NavigationRailDestination(
      icon: Tooltip(
        message: '미리보기',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Icon(Icons.preview_outlined),
        ),
      ),
      selectedIcon: Tooltip(
        message: '미리보기',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Icon(Icons.preview),
        ),
      ),
      label: const Text('미리보기'),
    ),
  ];

  void _handleRefinedData(List<Map<String, dynamic>> data) {
    setState(() {
      _refinedData = data;
      _selectedIndex = 1;
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
          /// ✅ Sidebar 개선 (슬림한 스타일 + 툴팁 + 호버 효과)
          Container(
            width: 100,
            color: const Color(0xFF1E1E2D),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.dashboard_customize, color: Colors.white, size: 28),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                Expanded(
                  child: NavigationRail(
                    backgroundColor: const Color(0xFF1E1E2D),
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    labelType: NavigationRailLabelType.none,
                    useIndicator: true,
                    groupAlignment: -1.0,
                    selectedIconTheme: const IconThemeData(color: Colors.white, size: 26),
                    unselectedIconTheme: const IconThemeData(color: Colors.white38, size: 22),
                    destinations: _destinations,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '© 2025',
                  style: TextStyle(fontSize: 12, color: Colors.white38),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          /// ✅ Main Area
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
