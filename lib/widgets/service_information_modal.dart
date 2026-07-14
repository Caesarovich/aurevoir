import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

/// A modal that displays the information of a service.
class ServiceInformationModal extends StatelessWidget {
  /// Constructor that takes a BonsoirService instance.
  const ServiceInformationModal({required this.service, super.key});

  /// The service to display the information of.
  final BonsoirService service;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Service Information'),
      insetPadding: const EdgeInsets.all(16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Name: ',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                service.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Type: ',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                service.type,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Port: ',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                service.port.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Host: ',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                'Unknown',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (service.attributes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Attributes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Table(
              children: service.attributes.entries.map((entry) {
                return TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  children: [
                    Text(entry.key),
                    Text(entry.value),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
