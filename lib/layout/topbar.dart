import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
          color: Colors.black54,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
          color: Colors.black54,
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.deepPurple,
          child: Text('U', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
