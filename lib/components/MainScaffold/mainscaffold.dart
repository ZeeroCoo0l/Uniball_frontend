import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/bottomnavbar.dart';
import 'package:uniball_frontend_2/components/MainScaffold/uniballappbar.dart';
import 'package:uniball_frontend_2/components/drawer.dart';

class MainScaffold extends StatelessWidget {
  static bool isAdmin = false;
  final Widget child;
  final int selectedIndex;
  final Function(int) onTabChange;

  //Konstruktor
  const MainScaffold({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    // Hide back arrow for pages 0, 1, 2
    final bool showBackButton =
        !(selectedIndex == 0 || selectedIndex == 1 || selectedIndex == 2);
    return Scaffold(
      appBar: UniballAppBar(showBackButton: showBackButton),
      endDrawer: const UniballDrawer(),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0), // logo offset
        child: child,
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: selectedIndex,
        onTabChange: onTabChange,
      ),
    );
  }
}

//används för att byta sida via navbar
void handleTabChange(BuildContext context, int index) {
  if (index == -1) return;
  switch (index) {
    case 0:
      if (MainScaffold.isAdmin) {
        Navigator.pushNamed(context, '/homepage_admin');
      } else {
        Navigator.pushNamed(context, '/homepage');
      }
      break;
    case 1:
      Navigator.pushNamed(context, '/profilepageshort');
      break;
    case 2:
      Navigator.pushNamed(context, '/leaderboard');
      break;
  }
}
