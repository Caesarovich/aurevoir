import 'package:aurevoir/oss_licenses.dart';
import 'package:flutter/material.dart';

/// A page that displays the licences of
/// the open source dependencies used in the application.
class LicencesPage extends StatelessWidget {
  /// Constructor for the LicencesPage.
  const LicencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Licences'),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: allDependencies.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => LicenceDetailPage(
                        title: allDependencies[index].name[0].toUpperCase() +
                            allDependencies[index].name.substring(1),
                        licence: allDependencies[index].license!,
                      ),
                    ),
                  );
                },
                //capitalize the first letter of the string
                title: Text(
                  allDependencies[index].name[0].toUpperCase() +
                      allDependencies[index].name.substring(1),
                ),
                subtitle: Text(allDependencies[index].description),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A page that displays the details of a licence.
class LicenceDetailPage extends StatelessWidget {
  /// Constructor for the LicenceDetailPage.
  const LicenceDetailPage({
    required this.title,
    required this.licence,
    super.key,
  });

  /// The title of the licence.
  final String title;

  /// The licence text.
  final String licence;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Text(
                  licence,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
