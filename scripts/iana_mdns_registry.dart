// This script downloads the IANA mDNS registry and prints the servicenames
// and transport protocols to the console.

// We do not care for this script
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

final Uri _ianaMdnsRegistryUri = Uri.parse(
  'https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.csv',
);

Future<String> downloadRegistry() async {
  final httpClient = HttpClient();

  try {
    final request = await httpClient.getUrl(_ianaMdnsRegistryUri);
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Request failed with status: ${response.statusCode}',
        uri: _ianaMdnsRegistryUri,
      );
    }

    return await response.transform(utf8.decoder).join();
  } finally {
    httpClient.close();
  }
}

Future<List<List<dynamic>>> downloadAndParseRegistry() async {
  final csvText = await downloadRegistry();
  return Csv().decode(csvText);
}

Future<void> main() async {
  final rows = await downloadAndParseRegistry();

  final transportProtocols = Set<String>.from(
    rows.skip(1).map((row) => row[2].toString().toLowerCase()),
  );

  final serviceNames = Set<String>.from(
    rows.skip(1).map((row) => row[0].toString().toLowerCase()),
  );

  print('=== Service Names ===');
  serviceNames.forEach(print);

  print('\n=== Transport Protocols ===');
  transportProtocols.forEach(print);
}
