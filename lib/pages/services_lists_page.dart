import 'package:aurevoir/widgets/resolved_service.dart';
import 'package:aurevoir/widgets/unresolved_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurevoir/providers/services_provider.dart';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, model, child) {
        return ListView(
          children: [
            ResolvedServiceList(services: model.resolvedServices),
            UnresolvedServiceList(services: model.services),
          ],
        );
      },
    );
  }
}
