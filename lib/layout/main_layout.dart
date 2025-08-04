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

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.upload_file),
      label: Text('업로드'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.preview),
      label: Text('미리보기'),
    ),
  ];

  void _handleRefinedData(List<Map<String, dynamic>> data) {
    setState(() {
      _refinedData = data;
      _selectedIndex = 1; // 자동으로 미리보기 탭으로 전환
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
          /// ✅ Sidebar
          Container(
            width: 220,
            color: const Color(0xFF1E1E2D),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  '📊 SheetFlow',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                Expanded(
                  child: NavigationRail(
                    backgroundColor: const Color(0xFF1E1E2D),
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: const IconThemeData(color: Colors.white),
                    unselectedIconTheme: const IconThemeData(color: Colors.white38),
                    selectedLabelTextStyle: const TextStyle(color: Colors.white),
                    unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
                    destinations: _destinations,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '© 2025 SheetFlow',
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
