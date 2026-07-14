import 'dart:async';
import 'dart:convert';

import 'package:aurevoir/app_logger.dart';
import 'package:aurevoir/pages/home_page.dart';
import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:aurevoir/providers/services_provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';
import 'package:aurevoir/theme.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger _logger = getLogger('bootstrap');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const _BootstrapApp());
}

Future<Widget> _buildApp() async {
  final settingsProvider = SettingsProvider(
    prefs: await SharedPreferences.getInstance(),
  );
  final broadcastedServicesProvider = BroadcastedServicesProvider();
  final serviceTypeProvider = ServiceTypeProvider();
  final serviceProvider = ServiceProvider();

  await _loadPersistedBroadcasts(settingsProvider, broadcastedServicesProvider);
  await serviceTypeProvider.startServiceTypeDiscovery();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => settingsProvider),
      ChangeNotifierProvider(create: (_) => broadcastedServicesProvider),
      ChangeNotifierProxyProvider<SettingsProvider, ServiceTypeProvider>(
        create: (_) => serviceTypeProvider,
        update: (_, settingsProvider, serviceTypeProvider) =>
            serviceTypeProvider!
              ..updateUserDefinedServiceTypes(settingsProvider.mdnsServices),
      ),
      ChangeNotifierProxyProvider2<SettingsProvider, ServiceTypeProvider,
          ServiceProvider>(
        create: (_) => serviceProvider,
        update: (
          _,
          settingsProvider,
          serviceTypeProvider,
          serviceProvider,
        ) =>
            serviceProvider!
              ..syncConfiguration(
                resolveServices: settingsProvider.resolveServices,
                serviceTypes: serviceTypeProvider.serviceTypes,
              ),
      ),
    ],
    child: const _MyApp(),
  );
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late final Future<Widget> _appFuture;

  @override
  void initState() {
    super.initState();
    _appFuture = _buildApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _appFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          _logger.e(
            'Failed to bootstrap Aurevoir',
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
          );
          return _StartupErrorApp(error: snapshot.error ?? 'Unknown error');
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingApp();
        }

        return snapshot.requireData;
      },
    );
  }
}

class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const _LoadingPage(),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_tethering,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Aurevoir',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _loadPersistedBroadcasts(
  SettingsProvider settingsProvider,
  BroadcastedServicesProvider broadcastedServicesProvider,
) async {
  if (!settingsProvider.persistBroadcasts) {
    return;
  }

  for (final jsonString in settingsProvider.persistedBroadcasts) {
    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        _logger.w(
          'Skipping persisted broadcast with invalid payload: $jsonString',
        );
        continue;
      }

      await broadcastedServicesProvider.broadcastService(
        BonsoirService.fromJson(decoded),
      );
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Skipping persisted broadcast because it could not be restored',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Aurevoir',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      },
    );
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Aurevoir failed to start.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
