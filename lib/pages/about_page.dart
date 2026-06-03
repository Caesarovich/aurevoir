import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              packageInfo?.appName ?? 'App Name',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Version ${packageInfo?.version}+${packageInfo?.buildNumber}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'This is a sample app to demonstrate the creation of an About page in Flutter. '
              'You can add more information about your app here, such as its purpose, features, '
              'and any other relevant details.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Text(
              'For more information, visit our website:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            const Row(
              children: [
                Icon(Icons.link),
                SizedBox(width: 8.0),
                Text(
                  'GitHub: https://github.com/your-repo',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
