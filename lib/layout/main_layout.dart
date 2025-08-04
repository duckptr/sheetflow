import 'package:flutter/material.dart';
import '../pages/upload_page.dart';
import '../pages/preview_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int? _selectedIndex;

  final List<Widget> _pages = [
    const UploadPage(),
    const PreviewPage(),
  ];

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.upload_file),
      label: Text('파일 업로드'),
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
          // ✅ Sidebar with title + NavigationRail
          Container(
            width: 220,
            color: Colors.grey[100],
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  '📊 Sheetflow',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(thickness: 1),
                Expanded(
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    destinations: _destinations,
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: const IconThemeData(color: Colors.indigo),
                    unselectedIconTheme: const IconThemeData(color: Colors.grey),
                    selectedLabelTextStyle: const TextStyle(color: Colors.indigo),
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ],
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
