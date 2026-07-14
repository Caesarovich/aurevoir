import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A dialog that asks the user to confirm the deletion of all broadcasts.
class DeleteAllConfirmationDialog extends StatelessWidget {
  /// Constructor for the DeleteAllConfirmationDialog.
  const DeleteAllConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete All Broadcasts'),
      content: const Text(
        '''
        Are you sure you want to stop all broadcasts?
        This action cannot be undone.
        ''',
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Delete'),
          onPressed: () async {
            final navigator = Navigator.of(context);
            final broadcastProvider = Provider.of<BroadcastedServicesProvider>(
              context,
              listen: false,
            );
            final settingsProvider =
                Provider.of<SettingsProvider>(context, listen: false);

            await Future.wait(
              [
                broadcastProvider.stopAllBroadcasts(),
                settingsProvider.setPersistedBroadcasts([]),
                broadcastProvider.removeAllBroadcasts(),
              ],
            );

            navigator.pop();
          },
        ),
      ],
    );
  }
}
