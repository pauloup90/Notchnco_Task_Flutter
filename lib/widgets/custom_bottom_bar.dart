import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6F35A1),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      elevation: 10.0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined, size: 24),
          activeIcon: Icon(Icons.grid_view, size: 24),
          label: 'Categories',
          tooltip: 'Explore movies by category',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border, size: 24),
          activeIcon: Icon(Icons.favorite, size: 24),
          label: 'Favorites',
          tooltip: 'View your favorite movies',
        ),
      ],
    );
  }
}
