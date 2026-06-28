import 'dart:convert';

import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

String? validateServiceType(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a service type';
  }

  List<String> parts = value.split('.');
  if (parts.length != 2) {
    return 'Service type must be in the format _service._tcp or _service._udp';
  }

  String secondPart = parts.last;

  if (secondPart != '_tcp' && secondPart != '_udp') {
    return 'Service type must end with _tcp or _udp';
  }

  String firstPart = parts.first;

  if (!firstPart.startsWith('_')) {
    return 'Service type must begin with an underscore';
  }

  firstPart = firstPart.substring(1, firstPart.length);

  if (firstPart.startsWith('-')) {
    return 'Service type must not begin with a hyphen';
  }

  if (firstPart.endsWith('-')) {
    return 'Service type must not end with a hyphen';
  }

  if (firstPart.contains(RegExp(r'-{2,}'))) {
    return 'Service type must not contain adjacent hyphens';
  }

  if (firstPart.contains(RegExp(r'[^A-Za-z0-9-]'))) {
    return 'Service type must contain only letters, digits, and hyphens';
  }

  if (firstPart.isEmpty || firstPart.length > 15) {
    return 'Service type must be between 1 and 15 characters long';
  }

  return null;
}

String? _validatePort(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a service port';
  }
  if (int.tryParse(value) == null) {
    return 'Please enter a valid port number';
  }
  int port = int.parse(value);
  if (port < 0 || port > 65535) {
    return 'Port number must be between 0 and 65535';
  }
  return null;
}

String? _validateServiceName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a service name';
  }

  if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(value)) {
    return 'Service names must not contain ASCII control characters';
  }

  return null;
}

String? _validateAttributeKey(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an attribute key';
  }

  if (RegExp(r'[^\x21-\x7E]').hasMatch(value)) {
    return 'Attribute keys must contain only printable ASCII characters';
  }

  if (value.contains("=")) {
    return 'Attribute keys must not contain the equal sign';
  }

  if (value.length > 9) {
    return 'Attribute keys must be 9 characters or fewer';
  }

  return null;
}

String? _validateAttributeValue(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an attribute value';
  }

  if (value.length > 255) {
    return 'Attribute values must be 255 characters or fewer';
  }

  return null;
}

class CreateBroadcastPage extends StatefulWidget {
  const CreateBroadcastPage({super.key});

  @override
  State<CreateBroadcastPage> createState() => _CreateBroadcastPageState();
}

class _CreateBroadcastPageState extends State<CreateBroadcastPage> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _servicePortController = TextEditingController();
  final List<TextEditingController> _attributeKeyControllers = [];
  final List<TextEditingController> _attributeValueControllers = [];

  void _addAttribute() {
    setState(() {
      _attributeKeyControllers.add(TextEditingController());
      _attributeValueControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Broadcast'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                      child: Column(
                        children: [
                          Text('Service Information',
                              style: Theme.of(context).textTheme.labelLarge),
                          TextFormField(
                            autofocus: true,
                            decoration: const InputDecoration(
                                labelText: 'Service name'),
                            controller: _serviceNameController,
                            onFieldSubmitted: (_) => _handleSubmit(),
                            validator: _validateServiceName,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Service type'),
                            controller: _serviceTypeController,
                            onFieldSubmitted: (_) => _handleSubmit(),
                            validator: validateServiceType,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Service port'),
                            controller: _servicePortController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onFieldSubmitted: (_) => _handleSubmit(),
                            validator: _validatePort,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                    child: Column(
                      children: [
                        Text('Service Attributes',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8.0),
                        ..._attributeKeyControllers
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Attribute Key'),
                                  controller: _attributeKeyControllers[index],
                                  maxLength: 9,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  validator: _validateAttributeKey,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Attribute Value'),
                                  controller: _attributeValueControllers[index],
                                  maxLength: 254 -
                                      _attributeKeyControllers[index]
                                          .text
                                          .length,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  validator: _validateAttributeValue,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                tooltip: 'Remove attribute',
                                onPressed: () {
                                  setState(() {
                                    _attributeKeyControllers[index].dispose();
                                    _attributeValueControllers[index].dispose();
                                    _attributeKeyControllers.removeAt(index);
                                    _attributeValueControllers.removeAt(index);
                                  });
                                },
                              )
                            ],
                          );
                        }),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(
                                    labelText: 'Attribute Key'),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextFormField(
                                enabled: false,
                                decoration: const InputDecoration(
                                    labelText: 'Attribute Value'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              tooltip: 'Add attribute',
                              onPressed: _addAttribute,
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 32.0),
                  ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.wifi_tethering),
                    label: const Text('Broadcast service'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceTypeController.dispose();
    _servicePortController.dispose();
    for (var controller in _attributeKeyControllers) {
      controller.dispose();
    }
    for (var controller in _attributeValueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      BonsoirService service = BonsoirService(
        name: _serviceNameController.text,
        type: _serviceTypeController.text,
        port: int.parse(_servicePortController.text),
        attributes:
            _attributeKeyControllers.asMap().entries.fold<Map<String, String>>(
          {},
          (previousValue, entry) {
            int index = entry.key;
            String key = _attributeKeyControllers[index].text;
            String value = _attributeValueControllers[index].text;
            if (key.isNotEmpty && value.isNotEmpty) {
              previousValue[key] = value;
            }
            return previousValue;
          },
        ),
      );

      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final broadcastProvider =
          Provider.of<BroadcastedServicesProvider>(context, listen: false);

      broadcastProvider.broadcastService(service).then(
        (value) {
          settingsProvider.setPersistedBroadcasts(
            broadcastProvider.broadcasts
                .map((broadcast) => jsonEncode(broadcast.service.toJson()))
                .toList(),
          );
        },
      ).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to broadcast service: $e')));
      });

      Navigator.of(context).pop();
    }
  }
}
