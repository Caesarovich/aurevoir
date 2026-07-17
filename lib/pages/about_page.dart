import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _githubUri = Uri.parse('https://github.com/Caesarovich/aurevoir');
final String _githubUrl = _githubUri.toString();

/// A page that displays information about the app.
class AboutPage extends StatefulWidget {
  /// Constructor for the AboutPage.
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    unawaited(_initPackageInfo());
  }

  Future<void> _initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              packageInfo?.appName ?? 'App Name',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${packageInfo?.version}+${packageInfo?.buildNumber}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'This is an open source application that allows you to broadcast'
              ' and discover services on your local network using mDNS.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'For more information, visit our website:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                unawaited(launchUrl(_githubUri));
              },
              child: Row(
                children: [
                  const Icon(Icons.link),
                  const SizedBox(width: 8),
                  Text(
                    _githubUrl,
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
