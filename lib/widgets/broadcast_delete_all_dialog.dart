import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAllConfirmationDialog extends StatelessWidget {
  const DeleteAllConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete All Broadcasts'),
      content: const Text(
          'Are you sure you want to stop all broadcasts? This action cannot be undone.'),
      actions: <Widget>[
        TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            final broadcastProvider = Provider.of<BroadcastedServicesProvider>(
                context,
                listen: false);
            final settingsProvider =
                Provider.of<SettingsProvider>(context, listen: false);

            broadcastProvider.stopAllBroadcasts();

            settingsProvider.setPersistedBroadcasts([]);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
