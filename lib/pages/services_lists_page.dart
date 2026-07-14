import 'package:aurevoir/providers/services_provider.dart';
import 'package:aurevoir/widgets/service_list.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Enum to represent the type of service list to display.
enum ServiceListType {
  /// Services that have been successfully resolved.
  resolved,

  /// Services that have been discovered but not yet resolved.
  unresolved,
}

/// Enum to represent the sort order for the service list.
enum SortOrderOption {
  /// Sort the services in ascending order.
  ascending,

  /// Sort the services in descending order.
  descending,
}

/// Enum to represent the sort option for the service list.
enum ServiceSortOption {
  /// Sort the services by name.
  name,

  /// Sort the services by type.
  type,

  /// Sort the services by port.
  port,

  /// Sort the services by hostname.
  hostname
}

/// A page that displays a list of services.
class ServiceListPage extends StatefulWidget {
  /// Constructor for the ServiceListPage.
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String value) {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  }

  bool _matchesSearch(BonsoirService service) {
    if (_searchQuery.isEmpty) return true;

    final name = service.name.toLowerCase();
    final type = service.type.toLowerCase();
    final port = service.port.toString().toLowerCase();
    final hostname = (service.hostname ?? '').toLowerCase();

    return name.contains(_searchQuery) ||
        type.contains(_searchQuery) ||
        port.contains(_searchQuery) ||
        hostname.contains(_searchQuery);
  }

  ServiceListType _currentListType = ServiceListType.resolved;

  SortOrderOption _currentSortOrder = SortOrderOption.ascending;
  ServiceSortOption _currentSortOption = ServiceSortOption.port;

  List<BonsoirService> _sortServices(List<BonsoirService> services) {
    final sortedServices = List<BonsoirService>.from(services)
      ..sort((a, b) {
        final result = switch (_currentSortOption) {
          ServiceSortOption.name =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          ServiceSortOption.type =>
            a.type.toLowerCase().compareTo(b.type.toLowerCase()),
          ServiceSortOption.port => a.port.compareTo(b.port),
          ServiceSortOption.hostname => (a.hostname ?? '')
              .toLowerCase()
              .compareTo((b.hostname ?? '').toLowerCase()),
        };

        return _currentSortOrder == SortOrderOption.ascending
            ? result
            : -result;
      });

    return sortedServices;
  }

  static const _noServicesWidget = Center(
    child: Text(
      'No services found',
      style: TextStyle(fontSize: 18, color: Colors.grey),
    ),
  );

  static const _noServicesMatchingSearchWidget = Center(
    child: Text(
      'No services match your search',
      style: TextStyle(fontSize: 18, color: Colors.grey),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, model, child) {
        final services = switch (_currentListType) {
          ServiceListType.resolved => model.resolvedServices,
          ServiceListType.unresolved => model.services,
        };

        final filteredServices = services.where(_matchesSearch).toList();

        final sortedServices = _sortServices(filteredServices);

        final noMatches = services.isNotEmpty && filteredServices.isEmpty;

        Widget bodyContent = _noServicesWidget;

        if (noMatches) {
          bodyContent = _noServicesMatchingSearchWidget;
        } else if (filteredServices.isNotEmpty) {
          bodyContent = ListView(
            children: [
              ResolvedServiceList(services: sortedServices),
            ],
          );
        }

        return Scaffold(
          appBar: AppBar(
            // titleSpacing: 0,
            //elevation: 32,
            title: TextField(
              controller: _searchController,
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search services',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          _updateSearchQuery('');
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            actions: [
              _ServiceSortPopupMenu(
                currentOption: _currentSortOption,
                onSelected: (option) {
                  setState(() {
                    _currentSortOption = option;
                  });
                },
              ),
              IconButton(
                tooltip: 'Toggle sort order',
                onPressed: () {
                  setState(() {
                    _currentSortOrder =
                        _currentSortOrder == SortOrderOption.ascending
                            ? SortOrderOption.descending
                            : SortOrderOption.ascending;
                  });
                },
                icon: Icon(
                  _currentSortOrder == SortOrderOption.ascending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ),
              _ServiceListTypePopupMenu(
                currentType: _currentListType,
                onSelected: (type) {
                  setState(() {
                    _currentListType = type;
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: bodyContent,
          ),
        );
      },
    );
  }
}

class _ServiceListTypePopupMenu extends StatelessWidget {
  const _ServiceListTypePopupMenu({
    required this.currentType,
    required this.onSelected,
  });
  final ServiceListType currentType;
  final ValueChanged<ServiceListType> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ServiceListType>(
      icon: const Icon(Icons.category),
      tooltip: 'Filter services',
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: ServiceListType.resolved,
          child: Text('Resolved Services'),
        ),
        const PopupMenuItem(
          value: ServiceListType.unresolved,
          child: Text('Unresolved Services'),
        ),
      ],
    );
  }
}

class _ServiceSortPopupMenu extends StatelessWidget {
  const _ServiceSortPopupMenu({
    required this.currentOption,
    required this.onSelected,
  });
  final ServiceSortOption currentOption;
  final ValueChanged<ServiceSortOption> onSelected;

  PopupMenuItem<ServiceSortOption> _buildSortItem(
    BuildContext context,
    ServiceSortOption option,
    String label,
  ) {
    return PopupMenuItem<ServiceSortOption>(
      value: option,
      child: Row(
        children: [
          if (currentOption == option)
            Icon(
              Icons.check,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ServiceSortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort services',
      onSelected: onSelected,
      itemBuilder: (context) => [
        _buildSortItem(context, ServiceSortOption.name, 'Name'),
        _buildSortItem(context, ServiceSortOption.type, 'Type'),
        _buildSortItem(context, ServiceSortOption.port, 'Port'),
        _buildSortItem(context, ServiceSortOption.hostname, 'Hostname'),
      ],
    );
  }
}
