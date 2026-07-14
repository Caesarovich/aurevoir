import 'dart:convert';

import 'package:aurevoir/pages/broadcast_create_page.dart';
import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';
import 'package:aurevoir/widgets/broadcast_delete_all_dialog.dart';
import 'package:aurevoir/widgets/service_information_modal.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays a message when there are no broadcasted services
/// and provides an option to create a new broadcast.
class NoBroadcastedServices extends StatelessWidget {
  /// Constructor for the NoBroadcastedServices widget.
  const NoBroadcastedServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No services are currently being broadcasted.'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const CreateBroadcastPage(),
                  ),
                );
              },
              child: const Text('Create a new broadcast'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page that displays the list of broadcasted services.
class BroadcastListPage extends StatelessWidget {
  /// Constructor for the BroadcastListPage.
  const BroadcastListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BroadcastedServicesProvider>(
      builder: (context, model, child) {
        if (model.broadcasts.isEmpty) {
          return const NoBroadcastedServices();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Broadcasts'),
            actions: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Resume all broadcasts',
                onPressed: () => model.resumeAllBroadcasts(),
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                tooltip: 'Pause all broadcasts',
                onPressed: () => model.stopAllBroadcasts(),
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Remove all broadcasts',
                onPressed: () => _showDeleteAllConfirmationDialog(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const CreateBroadcastPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: ListView.builder(
                itemCount: model.broadcasts.length,
                itemBuilder: (context, index) {
                  return BroadcastedServiceRow(
                    broadcast: model.broadcasts[index],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteAllConfirmationDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return const DeleteAllConfirmationDialog();
      },
    );
  }
}

/// A widget that displays a single broadcasted service in a list.
class BroadcastedServiceRow extends StatelessWidget {
  /// Constructor for the BroadcastedServiceRow.
  const BroadcastedServiceRow({
    required this.broadcast,
    super.key,
  });

  /// The broadcasted service to display.
  final BonsoirBroadcast broadcast;

  ///
  String get summaryText => '''
      ${broadcast.service.type} : ${broadcast.service.port}
      (${broadcast.isReady ? 'Ready' : 'Not ready'})
      (${broadcast.isStopped ? 'Stopped' : 'Running'})
      ''';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(broadcast.service.name),
        leading: broadcast.isReady
            ? const Icon(Icons.wifi)
            : const Icon(Icons.wifi_off),
        subtitle: Text(summaryText),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Show information about ${broadcast.service.name}',
              onPressed: () => _showInfoDialog(context, broadcast),
            ),
            if (broadcast.isStopped)
              IconButton(
                icon: const Icon(Icons.play_arrow_outlined),
                tooltip: 'Resume broadcast',
                onPressed: () async {
                  final broadcastProvider =
                      Provider.of<BroadcastedServicesProvider>(
                    context,
                    listen: false,
                  );
                  final settingsProvider =
                      Provider.of<SettingsProvider>(context, listen: false);

                  await broadcastProvider.resumeBroadcast(broadcast);

                  await settingsProvider.setPersistedBroadcasts(
                    broadcastProvider.broadcasts
                        .map(
                          (broadcast) => jsonEncode(broadcast.service.toJson()),
                        )
                        .toList(),
                  );
                },
              ),
            if (broadcast.isReady)
              IconButton(
                icon: const Icon(Icons.pause),
                tooltip: 'Pause broadcast',
                onPressed: () async {
                  final broadcastProvider =
                      Provider.of<BroadcastedServicesProvider>(
                    context,
                    listen: false,
                  );
                  final settingsProvider =
                      Provider.of<SettingsProvider>(context, listen: false);

                  await broadcastProvider.stopBroadcast(broadcast);
                  await settingsProvider.setPersistedBroadcasts(
                    broadcastProvider.broadcasts
                        .map(
                          (broadcast) => jsonEncode(broadcast.service.toJson()),
                        )
                        .toList(),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              tooltip: 'Delete broadcast ${broadcast.service.name}',
              onPressed: () async {
                final broadcastProvider =
                    Provider.of<BroadcastedServicesProvider>(
                  context,
                  listen: false,
                );
                final settingsProvider =
                    Provider.of<SettingsProvider>(context, listen: false);

                await broadcastProvider.removeBroadcast(broadcast);
                await settingsProvider.setPersistedBroadcasts(
                  broadcastProvider.broadcasts
                      .map(
                        (broadcast) => jsonEncode(broadcast.service.toJson()),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInfoDialog(
    BuildContext context,
    BonsoirBroadcast broadcast,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return ServiceInformationModal(service: broadcast.service);
      },
    );
  }
}
