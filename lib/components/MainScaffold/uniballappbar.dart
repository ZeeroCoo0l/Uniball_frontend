import 'package:flutter/material.dart';

class UniballAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const UniballAppBar({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppBar(
          automaticallyImplyLeading: showBackButton,
          backgroundColor: const Color(0xFF6CBC8C),
          elevation: 0,
          flexibleSpace: Align(
            alignment: Alignment.bottomRight,
            child: Padding(padding: const EdgeInsets.only(right: 10.0)),
          ),
        ),
        Positioned(
          bottom: -35,
          left: MediaQuery.of(context).size.width / 2 - 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6CBC8C),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 38,
                backgroundImage: AssetImage('assets/uniballLogo.png'),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
