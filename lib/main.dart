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
              ..setShouldResolveServices(settingsProvider.resolveServices)
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
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        );
      },
    );
  }
}

const Color _lightPrimary = Color(0xFF4BA3F2);
const Color _lightSecondary = Color(0xFF7CC8FF);
const Color _lightSurface = Color(0xFFF6FBFF);

final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _lightPrimary,
    brightness: Brightness.light,
  ).copyWith(
    primary: _lightPrimary,
    secondary: _lightSecondary,
    surface: _lightSurface,
    surfaceTint: _lightPrimary,
  ),
  scaffoldBackgroundColor: _lightSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: _lightSurface,
    foregroundColor: Colors.black87,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? _lightPrimary : Colors.grey),
    trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? _lightSecondary.withValues(alpha: 0.5) : Colors.grey.shade300),
  ),
);

final ThemeData _darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _lightPrimary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: _lightSecondary,
    secondary: _lightPrimary,
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightSecondary,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
