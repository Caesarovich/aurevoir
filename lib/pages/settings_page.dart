import 'dart:convert';

import 'package:aurevoir/pages/about_page.dart';
import 'package:aurevoir/pages/broadcast_create_page.dart';
import 'package:aurevoir/pages/licences_page.dart';
import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';

Future<String?> _showAddServiceDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();

  final serviceTypeController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
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

class SettingsCategoryCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsCategoryCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return ListView(
              children: [
                SettingsCategoryCard(
                  title: 'Appearance',
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: settings.darkMode,
                      onChanged: (value) {
                        settings.toggleDarkMode();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsCategoryCard(
                  title: "Service discovery",
                  children: [
                    SwitchListTile(
                      title: const Row(
                        children: [
                          Text('Resolve services'),
                          SizedBox(width: 8),
                          Tooltip(
                            message: 'Changing this setting might require a restart to take effect',
                            child: Icon(Icons.info_outline, size: 16),
                          ),
                        ],
                      ),
                      value: settings.resolveServices,
                      onChanged: (value) {
                        settings.toggleServiceResolution();
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
                                onPressed: () {
                                  final services = settings.mdnsServices;
                                  services.remove(service);
                                  settings.setMdnsServices(services);
                                },
                              ),
                            );
                          }).toList()),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                String? newService = await _showAddServiceDialog(context);
                                if (newService != null && newService.isNotEmpty) {
                                  final services = settings.mdnsServices;
                                  services.add(newService);
                                  settings.setMdnsServices(services);
                                }
                              },
                              child: const Text('Add Service'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsCategoryCard(
                  title: 'Broadcasting',
                  children: [
                    SwitchListTile(
                      title: const Row(
                        children: [
                          Text('Persist broadcasts'),
                          SizedBox(width: 8),
                          Tooltip(
                            message: 'When enabled, broadcasts will be persisted across app restarts',
                            child: Icon(Icons.info_outline, size: 16),
                          ),
                        ],
                      ),
                      value: settings.persistBroadcasts,
                      onChanged: (value) {
                        final broadcastProvider = Provider.of<BroadcastedServicesProvider>(context, listen: false);

                        settings.togglePersistBroadcasts();

                        value
                            ? settings.setPersistedBroadcasts(
                                broadcastProvider.broadcasts.map((broadcast) => jsonEncode(broadcast.service.toJson())).toList())
                            : settings.setPersistedBroadcasts([]);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutPage()));
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info),
                            SizedBox(width: 8),
                            Text('About'),
                          ],
                        )),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LicencesPage()));
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notes),
                            SizedBox(width: 8),
                            Text('Licences'),
                          ],
                        )),
                  ],
                ),
              ],
            );
          },
        )),
      ),
    );
  }
}
