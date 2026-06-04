import 'dart:convert';

import 'package:aurevoir/pages/broadcast_create_page.dart';
import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';
import 'package:aurevoir/widgets/broadcast_delete_all_dialog.dart';
import 'package:aurevoir/widgets/service_information_modal.dart';
import 'package:flutter/material.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:provider/provider.dart';

class NoBroadcastedServices extends StatelessWidget {
  const NoBroadcastedServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No services are currently being broadcasted.'),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
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

class BroadcastListPage extends StatelessWidget {
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateBroadcastPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: ListView.builder(
              itemCount: model.broadcasts.length,
              itemBuilder: (context, index) {
                return BroadcastedServiceRow(broadcast: model.broadcasts[index]);
              },
            )),
          ),
        );
      },
    );
  }

  void _showDeleteAllConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DeleteAllConfirmationDialog();
      },
    );
  }
}

class BroadcastedServiceRow extends StatelessWidget {
  const BroadcastedServiceRow({
    super.key,
    required this.broadcast,
  });

  final BonsoirBroadcast broadcast;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(broadcast.service.name),
        leading: broadcast.isReady ? const Icon(Icons.wifi) : const Icon(Icons.wifi_off),
        subtitle: Text(
            '${broadcast.service.type} : ${broadcast.service.port.toString()}  (${broadcast.isReady ? 'Ready' : 'Not ready'}) (${broadcast.isStopped ? 'Stopped' : 'Running'})'),
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
                onPressed: () {
                  final broadcastProvider = Provider.of<BroadcastedServicesProvider>(context, listen: false);
                  final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

                  broadcastProvider.resumeBroadcast(broadcast).then(
                        (value) => settingsProvider.setPersistedBroadcasts(
                          broadcastProvider.broadcasts.map((broadcast) => jsonEncode(broadcast.service.toJson())).toList(),
                        ),
                      );
                },
              ),
            if (broadcast.isReady)
              IconButton(
                icon: const Icon(Icons.pause),
                tooltip: 'Pause broadcast',
                onPressed: () {
                  final broadcastProvider = Provider.of<BroadcastedServicesProvider>(context, listen: false);
                  final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

                  broadcastProvider.stopBroadcast(broadcast).then(
                        (value) => settingsProvider.setPersistedBroadcasts(
                          broadcastProvider.broadcasts.map((broadcast) => jsonEncode(broadcast.service.toJson())).toList(),
                        ),
                      );
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              tooltip: 'Delete broadcast ${broadcast.service.name}',
              onPressed: () {
                final broadcastProvider = Provider.of<BroadcastedServicesProvider>(context, listen: false);
                final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

                broadcastProvider.removeBroadcast(broadcast).then(
                      (value) => settingsProvider.setPersistedBroadcasts(
                        broadcastProvider.broadcasts.map((broadcast) => jsonEncode(broadcast.service.toJson())).toList(),
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, BonsoirBroadcast broadcast) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiceInformationModal(service: broadcast.service);
      },
    );
  }
}
