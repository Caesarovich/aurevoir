import 'package:aurevoir/pages/broadcast_list_page.dart';
import 'package:aurevoir/pages/services_lists_page.dart';
import 'package:aurevoir/pages/settings_page.dart';
import 'package:flutter/material.dart';

import 'package:aurevoir/widgets/adaptive_nav_shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<NavigationDestination> _destinations = [
    NavigationDestination(
      label: 'Services',
      icon: Icon(Icons.list),
    ),
    NavigationDestination(
      label: 'Broadcasts',
      icon: Icon(Icons.wifi_tethering),
    ),
    NavigationDestination(
      label: 'Settings',
      icon: Icon(Icons.settings),
    ),
  ];

  final List<Widget> _pages = [
    const ServiceListPage(),
    const BroadcastListPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavShell(
      width: MediaQuery.sizeOf(context).width,
      breakpoint: 900,
      destinations: _destinations,
      pages: _pages,
    );
  }
}
