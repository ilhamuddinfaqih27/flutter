

import 'package:app_iot/rfhTA/page/log.dart';
import 'package:app_iot/rfhTA/page/profilepage.dart';
import 'package:flutter/material.dart';
import 'navbar.dart';
import '../page/apphome.dart';
import '../page/weather.dart';

class Navigate extends StatefulWidget {
  const Navigate({super.key});

  @override
  State<Navigate> createState() => _NavigateState();
}

class _NavigateState extends State<Navigate> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Apphome(),
    WeatherDashboard(),
    ChartGallery(),
    ProfilePage1(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ResponsiveNavBar(),
      drawer: const ResponsiveDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
            backgroundColor: Color.fromARGB(150, 50, 11, 157),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sunny_snowing),
            activeIcon: Icon(Icons.sunny_snowing),
            label: 'Weather',
            backgroundColor: Color.fromARGB(150, 50, 11, 157),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Cart',
            backgroundColor: Color.fromARGB(150, 50, 11, 157),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
            backgroundColor: Color.fromARGB(150, 50, 11, 157),
          ),
        ],
      ),
    );
  }
}