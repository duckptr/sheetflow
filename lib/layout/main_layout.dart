// sheetflow: Flutter desktop main layout with sidebar and routing

import 'package:flutter/material.dart';
import '../pages/upload_page.dart';
import '../pages/analysis_page.dart';
import '../pages/preview_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int? _selectedIndex; // null일 때는 비어 있는 초기 화면

  final List<Widget> _pages = [
    const UploadPage(),
    const AnalysisPage(),
    const PreviewPage(),
  ];

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.upload_file),
      label: Text('파일 업로드'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.search),
      label: Text('데이터 분석'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.table_chart),
      label: Text('미리보기'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: _destinations,
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: Colors.indigo),
            backgroundColor: Colors.grey[100],
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '📊 sheetflow',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _selectedIndex == null
                ? const Center(
                    child: Text(
                      '왼쪽 메뉴에서 기능을 선택해주세요.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : _pages[_selectedIndex!],
          ),
        ],
      ),
    );
  }
}
