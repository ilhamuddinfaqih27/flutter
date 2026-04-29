import 'dart:ui';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(26),
        topRight: Radius.circular(26),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.35),
                width: 1.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: selectedIndex,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey.shade300,
            onTap: onTap,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud_rounded),
                label: "Cuaca",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.window_rounded),
                label: "Manual Control",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
