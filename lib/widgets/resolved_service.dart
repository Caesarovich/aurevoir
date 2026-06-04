import 'package:aurevoir/widgets/text_divider.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Map<String, IconData> serviceTypeIcons = {
  // Web services
  '_http': Icons.http,
  '_https': Icons.https,
  '_www': Icons.web,

  // Mail services
  '_smtp': Icons.email,
  '_pop2': Icons.email,
  '_pop3': Icons.email,
  '_imap': Icons.email,
  '_imap2': Icons.email,
  '_imap3': Icons.email,
  '_imaps': Icons.email,
  '_submission': Icons.email,
  '_submissions': Icons.email,

  // Printers & Scanners
  '_printer': Icons.print,
  '_ipp': Icons.print,
  '_ipps': Icons.print,
  '_pdl-datastream': Icons.print,
  '_scanner': Icons.scanner,
  '_uscan': Icons.scanner,
  '_uscans': Icons.scanner,
  '_eapsp': Icons.print_sharp,

  // Apple services
  '_airplay': Icons.airplay,
  '_airdrop': Icons.wifi_tethering,
  '_apple-mobdev2': Icons.phone_iphone,
  '_afpovertcp': Icons.folder_shared,
  '_daap': Icons.music_note,
  '_raop': Icons.speaker,

  // File sharing
  '_smb': Icons.folder_shared,
  '_nfs': Icons.folder_shared,
  '_ftp': Icons.folder,

  // Media streaming
  '_rtsp': Icons.videocam,
  '_rtsp-alt': Icons.videocam,
  '_rtsps': Icons.videocam,
  '_rtsps-alt': Icons.videocam,

  // Database services
  '_mysql': Icons.storage,
  '_mysql-cluster': Icons.cloud,
  '_mysql-cm-agent': Icons.storage,
  '_mysql-im': Icons.storage,
  '_mysql-proxy': Icons.storage,
  '_postgresql': Icons.storage,
  '_pgbackrest': Icons.storage,
  '_redis': Icons.storage,
  '_mongodb': Icons.storage,

  // Other services
  '_ssh': Icons.computer,
  '_mqtt': Icons.wifi,
};

class ResolvedServiceList extends StatelessWidget {
  final List<BonsoirService> services;

  const ResolvedServiceList({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextDivider(text: 'Resolved Services'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            itemCount: services.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return ResolvedServiceRow(service: services[index]);
            },
          ),
        ),
      ],
    );
  }
}

class ResolvedServiceRow extends StatelessWidget {
  final BonsoirService service;

  const ResolvedServiceRow({super.key, required this.service});

  IconData get serviceIcon {
    final String serviceType = service.type.split('.').first;
    return serviceTypeIcons[serviceType] ?? Icons.device_unknown;
  }

  String get hostAddresses {
    if (service.hostAddresses.isEmpty) return 'Unknown';
    return service.hostAddresses.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              spacing: 6.0,
              children: [
                Icon(serviceIcon, size: 42),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      service.type,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 12.0,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HOSTNAME', style: Theme.of(context).textTheme.labelMedium),
                    Text(service.hostname ?? 'Unknown', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PORT', style: Theme.of(context).textTheme.labelMedium),
                    Text(service.port.toString(), style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ],
            ),
            _ServiceInformationRow(title: 'HOSTS', value: hostAddresses),
            if (service.attributes.isNotEmpty) ...[
              ExpansionTile(
                expandedAlignment: Alignment.topLeft,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text("(${service.attributes.length}) Attributes", style: Theme.of(context).textTheme.bodyMedium),
                children: [
                  ...service.attributes.entries.map((entry) {
                    return _ServiceInformationRow(title: entry.key, value: entry.value);
                  }),
                ],
              ),
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
    return Tooltip(
      message: "Click to copy the value",
      waitDuration: Duration(milliseconds: 500),
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title copied to clipboard')),
            );
          },
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Wrap(children: [
                Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value),
              ])),
        ),
      ),
    );
  }
}
