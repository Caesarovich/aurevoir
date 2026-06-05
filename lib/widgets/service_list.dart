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
        ListView.separated(
          itemCount: services.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return ResolvedServiceRow(service: services[index]);
          },
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

  List<String> get hostAddresses {
    final List<String> hosts = [
      if (service.hostname != null) service.hostname!,
      ...service.hostAddresses,
    ];

    return hosts.isNotEmpty ? hosts : ['Unknown'];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            SizedBox(
              height: 54,
              child: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Icon(serviceIcon, color: Theme.of(context).colorScheme.onPrimary, size: 36),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                maxLines: 1,
                                softWrap: false,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                service.type,
                                maxLines: 1,
                                softWrap: false,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('PORT',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text(service.port.toString(), style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Hosts:', style: Theme.of(context).textTheme.labelLarge),
                ...hostAddresses.map((address) => _CopyableInfoCard(value: address))
              ],
            ),
            if (service.attributes.isNotEmpty) ...[
              ExpansionTile(
                expandedAlignment: Alignment.topLeft,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Row(
                  spacing: 6,
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    Text("${service.attributes.length} Attributes", style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                children: [
                  ...service.attributes.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 6),
                      child: _CopyableInfoCard(title: entry.key, value: entry.value),
                    );
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

class _CopyableInfoCard extends StatelessWidget {
  const _CopyableInfoCard({
    required this.value,
    this.title,
  });

  final String value;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Click to copy the value",
      waitDuration: Duration(milliseconds: 500),
      child: Card(
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Value copied to clipboard')),
            );
          },
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Wrap(children: [
                if (title != null) Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value),
              ])),
        ),
      ),
    );
  }
}
