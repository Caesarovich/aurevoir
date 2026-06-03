import 'package:aurevoir/widgets/text_divider.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

class UnresolvedServiceList extends StatelessWidget {
  final List<BonsoirService> services;

  const UnresolvedServiceList({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextDivider(text: 'Unresolved Services'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            itemCount: services.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return UnresolvedServiceRow(service: services[index]);
            },
          ),
        ),
      ],
    );
  }
}

class UnresolvedServiceRow extends StatelessWidget {
  final BonsoirService service;

  const UnresolvedServiceRow({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            _ServiceInformationRow(title: 'Type', value: service.type),
            _ServiceInformationRow(title: 'Port', value: service.port.toString()),
            if (service.attributes.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Center(
                child: Text('Attributes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...service.attributes.entries.map((entry) {
                return _ServiceInformationRow(title: entry.key, value: entry.value);
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _ServiceInformationRow extends StatelessWidget {
  const _ServiceInformationRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(value),
    ]);
  }
}
