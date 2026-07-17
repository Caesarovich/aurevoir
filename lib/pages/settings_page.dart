import 'dart:convert';

import 'package:aurevoir/pages/about_page.dart';
import 'package:aurevoir/pages/broadcast_create_page.dart';
import 'package:aurevoir/pages/licences_page.dart';
import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<String?> _showAddServiceDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();

  final serviceTypeController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add a service type'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: serviceTypeController,
            decoration: const InputDecoration(
              hintText: '_http._tcp',
              errorMaxLines: 3, // Add this line to wrap error text
            ),
            validator: validateServiceType,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(serviceTypeController.text);
              }
            },
          ),
        ],
      );
    },
  );
}

/// Card widget that displays a category of settings
/// with a title and a list of children widgets.
class SettingsCategoryCard extends StatelessWidget {
  /// Constructor for the SettingsCategoryCard.
  const SettingsCategoryCard({
    required this.title,
    required this.children,
    super.key,
  });

  /// The title of the settings category.
  final String title;

  /// The list of children widgets that represent the settings in this category.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// The settings page of the application.
class SettingsPage extends StatefulWidget {
  /// Constructor for the SettingsPage.
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AppearanceSettings(settings: settings),
                const SizedBox(height: 16),
                _ServiceDiscoverySettings(settings: settings),
                const SizedBox(height: 16),
                _BroadcastingSettings(settings: settings),
                const SizedBox(height: 32),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AboutPage(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info),
                          SizedBox(width: 8),
                          Text('About'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LicencesPage(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notes),
                          SizedBox(width: 8),
                          Text('Licences'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppearanceSettings extends StatelessWidget {
  const _AppearanceSettings({
    required this.settings,
  });

  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return SettingsCategoryCard(
      title: 'Appearance',
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: settings.darkMode,
          onChanged: (value) async {
            await settings.toggleDarkMode();
          },
        ),
      ],
    );
  }
}

class _ServiceDiscoverySettings extends StatelessWidget {
  const _ServiceDiscoverySettings({
    required this.settings,
  });

  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return SettingsCategoryCard(
      title: 'Service discovery',
      children: [
        SwitchListTile(
          title: const Row(
            children: [
              Text('Resolve services'),
              SizedBox(width: 8),
              Tooltip(
                message: '''
                    Changing this setting might require
                    a restart to take effect
                    ''',
                child: Icon(Icons.info_outline, size: 16),
              ),
            ],
          ),
          value: settings.resolveServices,
          onChanged: (value) async {
            await settings.toggleServiceResolution();
          },
        ),
        ListTile(
          title: const Text('mDNS Services'),
          subtitle: Column(
            children: [
              Column(
                children: settings.mdnsServices.map((service) {
                  return ListTile(
                    title: Text(service),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final services = settings.mdnsServices..remove(service);
                        await settings.setMdnsServices(services);
                      },
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: () async {
                    final newService = await _showAddServiceDialog(context);
                    if (newService != null && newService.isNotEmpty) {
                      final services = settings.mdnsServices..add(newService);
                      await settings.setMdnsServices(services);
                    }
                  },
                  child: const Text('Add Service'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BroadcastingSettings extends StatelessWidget {
  const _BroadcastingSettings({
    required this.settings,
  });

  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return SettingsCategoryCard(
      title: 'Broadcasting',
      children: [
        SwitchListTile(
          title: const Row(
            children: [
              Text('Persist broadcasts'),
              SizedBox(width: 8),
              Tooltip(
                message: '''
                    When enabled, broadcasts will be
                    persisted across app restarts
                ''',
                child: Icon(Icons.info_outline, size: 16),
              ),
            ],
          ),
          value: settings.persistBroadcasts,
          onChanged: (value) async {
            final broadcastProvider = Provider.of<BroadcastedServicesProvider>(
              context,
              listen: false,
            );

            await settings.togglePersistBroadcasts();

            // If the user enables persist broadcasts
            // save the current broadcasts to settings.
            // If they disable it, clear the persisted broadcasts.
            if (value) {
              await settings.setPersistedBroadcasts(
                broadcastProvider.broadcasts
                    .map(
                      (broadcast) => jsonEncode(
                        broadcast.service.toJson(),
                      ),
                    )
                    .toList(),
              );
            } else {
              await settings.setPersistedBroadcasts([]);
            }
          },
        ),
      ],
    );
  }
}
