import 'package:flutter/material.dart';

class AdaptiveNavShell extends StatefulWidget {
  const AdaptiveNavShell({
    super.key,
    this.breakpoint = 600,
    required this.width,
    required this.destinations,
    required this.pages,
  });

  final double width;
  final double breakpoint;
  final List<NavigationDestination> destinations;
  final List<Widget> pages;

  @override
  State<AdaptiveNavShell> createState() => _AdaptiveNavShellState();
}

class _AdaptiveNavShellState extends State<AdaptiveNavShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    assert(widget.destinations.length == widget.pages.length, 'Destinations and pages must have the same length');

    final isWide = widget.width >= widget.breakpoint;

    if (!isWide) {
      return Scaffold(
        body: widget.pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: widget.destinations,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            labelType: NavigationRailLabelType.all,
            destinations: widget.destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon ?? d.icon,
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: widget.pages[index]),
        ],
      ),
    );
  }
}
