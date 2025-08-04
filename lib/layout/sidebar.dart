import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String selectedRoute;
  final void Function(String route) onRouteSelected;

  const Sidebar({
    Key? key,
    required this.selectedRoute,
    required this.onRouteSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, 
      color: const Color(0xFF1E1E2D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'MJ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28, // 좀 더 크게
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40),

          _buildNavItem(
            label: '📂 파일 업로드',
            route: '/upload',
          ),
          _buildNavItem(
            label: '📊 분석 결과',
            route: '/analysis',
          ),
          _buildNavItem(
            label: '🔍 미리보기',
            route: '/preview',
          ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(left: 24.0, bottom: 16.0),
            child: Text(
              '© 2025 MJ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required String route,
  }) {
    final bool isSelected = selectedRoute == route;

    return InkWell(
      onTap: () => onRouteSelected(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white10 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
