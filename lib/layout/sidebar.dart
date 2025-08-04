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
      width: 220,
      color: const Color(0xFF1E1E2D), // 어두운 배경
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'SheetFlow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildNavItem(
            icon: Icons.upload_file,
            label: '업로드',
            route: '/upload',
          ),
          _buildNavItem(
            icon: Icons.analytics,
            label: '분석 결과',
            route: '/analysis',
          ),
          _buildNavItem(
            icon: Icons.preview,
            label: '미리보기',
            route: '/preview',
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              '© 2025 SheetFlow',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool isSelected = selectedRoute == route;

    return InkWell(
      onTap: () => onRouteSelected(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white10 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
