import 'dart:convert';
import 'package:aurevoir/pages/home_page.dart';
import 'package:aurevoir/providers/broadcasts_provider.dart';
import 'package:aurevoir/providers/services_provider.dart';
import 'package:aurevoir/providers/settings_provider.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void loadPersistedBroadcasts(SettingsProvider settingsProvider, BroadcastedServicesProvider broadcastedServicesProvider) {
  if (!settingsProvider.persistBroadcasts) {
    return;
  }

  final persistedBroadcasts = settingsProvider.persistedBroadcasts.map((jsonString) => BonsoirService.fromJson(jsonDecode(jsonString))).toList();

  for (var broadcast in persistedBroadcasts) {
    broadcastedServicesProvider.broadcastService(broadcast);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider(prefs: await SharedPreferences.getInstance());

  final broadcastedServicesProvider = BroadcastedServicesProvider();

  loadPersistedBroadcasts(settingsProvider, broadcastedServicesProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => broadcastedServicesProvider),
        ChangeNotifierProxyProvider<SettingsProvider, ServiceTypeProvider>(
          create: (_) => ServiceTypeProvider(),
          update: (_, settingsProvider, serviceTypeProvider) => serviceTypeProvider!..updateUserDefinedServiceTypes(settingsProvider.mdnsServices),
        ),
        ChangeNotifierProxyProvider2<SettingsProvider, ServiceTypeProvider, ServiceProvider>(
            create: (_) => ServiceProvider(),
            update: (_, settingsProvider, serviceTypeProvider, serviceProvider) => serviceProvider!
              ..setResolveServices(settingsProvider.resolveServices)
              ..updateServiceTypes(serviceTypeProvider.serviceTypes)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Aurevoir',
          debugShowCheckedModeBanner: false,
          theme: settings.darkMode ? ThemeData.dark() : ThemeData.light(),
          home: const HomePage(),
        );
      },
    );
  }
}
