import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const BottomNav({super.key, required this.selectedIndex, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: GNav(
          activeColor: Colors.green, // Selected tab color
          tabBackgroundColor: Colors.grey.shade800,
          gap: 8,
          padding: EdgeInsets.all(16),
          tabs: [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.person, text: 'Profile'),
            GButton(icon: Icons.leaderboard, text: 'Leaderboard'),
          ],
          selectedIndex:
              selectedIndex, // Set this to -1 to prevent any tab from being selected
          onTabChange: (index) {
            // Allow interaction but no highlighting on non-selected pages
            onTabChange(index);
          },
        ),
      ),
    );
  }
}