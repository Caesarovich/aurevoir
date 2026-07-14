import 'package:flutter/material.dart';

/// A widget that adapts its navigation UI based on the available width.
class AdaptiveNavShell extends StatefulWidget {
  /// Constructor for the AdaptiveNavShell.
  const AdaptiveNavShell({
    required this.width,
    required this.destinations,
    required this.pages,
    super.key,
    this.breakpoint = 600,
  });

  /// The current width of the available space.
  final double width;

  /// The width at which the navigation UI should switch between
  /// bottom navigation and navigation rail.
  final double breakpoint;

  /// The list of navigation destinations.
  final List<NavigationDestination> destinations;

  /// The list of pages corresponding to the navigation destinations.
  final List<Widget> pages;

  @override
  State<AdaptiveNavShell> createState() => _AdaptiveNavShellState();
}

class _AdaptiveNavShellState extends State<AdaptiveNavShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    assert(
      widget.destinations.length == widget.pages.length,
      'Destinations and pages must have the same length',
    );

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
