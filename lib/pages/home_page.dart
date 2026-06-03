import 'package:aurevoir/pages/broadcast_list_page.dart';
import 'package:aurevoir/pages/services_lists_page.dart';
import 'package:aurevoir/pages/settings_page.dart';
import 'package:flutter/material.dart';

class NavigationItem {
  final Widget screen;
  final String title;
  final IconData icon;

  NavigationItem({
    required this.screen,
    required this.title,
    required this.icon,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedScreenIndex = 0;

  final List<NavigationItem> _screens = [
    NavigationItem(
      screen: const ServiceListPage(),
      title: 'Services',
      icon: Icons.home,
    ),
    NavigationItem(
      screen: const BroadcastListPage(),
      title: 'My Broadcasts',
      icon: Icons.wifi_tethering,
    ),
    NavigationItem(screen: const SettingsPage(), title: "Settings", icon: Icons.settings)
  ];

  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedScreenIndex].screen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedScreenIndex,
        onTap: _selectScreen,
        items: _screens
            .map(
              (screen) => BottomNavigationBarItem(
                icon: Icon(screen.icon),
                label: screen.title,
              ),
            )
            .toList(),
      ),
    );
  }
}
