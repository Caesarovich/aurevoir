import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This provider is used to manage the user settings.
class SettingsProvider extends ChangeNotifier {
  /// Constructor that takes a SharedPreferences instance.
  SettingsProvider({required this.prefs}) {
    loadSettings();
  }

  /// The SharedPreferences instance used to persist settings.
  final SharedPreferences prefs;

  // Dark mode settings
  /// The key used to store the dark mode setting in SharedPreferences.
  static const String darkModeKey = 'darkMode';
  bool _darkMode = false;

  /// Whether dark mode is enabled or not
  bool get darkMode => _darkMode;

  /// Toggle the dark mode setting
  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    await saveSettings();
    notifyListeners();
  }

  // Persist broadcasts settings
  /// The key used to store the persist broadcasts setting in SharedPreferences.
  static const String persistBroadcastsKey = 'persistBroadcasts';
  bool _persistBroadcasts = false;

  /// Whether to persist broadcasts or not
  bool get persistBroadcasts => _persistBroadcasts;

  /// Toggle the persist broadcasts setting
  Future<void> togglePersistBroadcasts() async {
    _persistBroadcasts = !_persistBroadcasts;
    await saveSettings();
    notifyListeners();
  }

  // Persisted broadcasts list
  /// The key used to store the persisted broadcasts in SharedPreferences.
  static const String persistedBroadcastsKey = 'persistedBroadcasts';
  List<String> _persistedBroadcasts = [];

  /// The persisted broadcasts list
  List<String> get persistedBroadcasts => _persistedBroadcasts;

  /// Set the persisted broadcasts list
  Future<void> setPersistedBroadcasts(List<String> broadcasts) async {
    _persistedBroadcasts = broadcasts;
    await saveSettings();
    notifyListeners();
  }

  // mDNS services settings
  /// The key used to store the mDNS services in SharedPreferences.
  static const String mdnsServicesKey = 'mdnsServices';
  List<String> _mdnsServices = [];

  /// The mDNS services to be always discovered
  List<String> get mdnsServices => _mdnsServices;

  /// Set the mDNS services to be always discovered
  Future<void> setMdnsServices(List<String> services) async {
    _mdnsServices = services;
    await saveSettings();
    notifyListeners();
  }

  // Resolve services settings
  /// The key used to store the resolve services setting in SharedPreferences.
  static const String resolveServicesKey = 'resolveServices';
  var _resolveServices = true;

  /// Whether to resolve services or not
  bool get resolveServices => _resolveServices;

  /// Toggle the resolve services setting
  Future<void> toggleServiceResolution() async {
    _resolveServices = !_resolveServices;
    await saveSettings();
    notifyListeners();
  }

  /// Load settings from SharedPreferences
  void loadSettings() {
    _darkMode = prefs.getBool(darkModeKey) ?? false;
    _resolveServices = prefs.getBool(resolveServicesKey) ?? true;
    _mdnsServices = prefs.getStringList(mdnsServicesKey) ?? [];
    _persistedBroadcasts = prefs.getStringList(persistedBroadcastsKey) ?? [];
    _persistBroadcasts = prefs.getBool(persistBroadcastsKey) ?? false;
    notifyListeners();
  }

  /// Save settings to SharedPreferences
  Future<void> saveSettings() async {
    await prefs.setBool(darkModeKey, _darkMode);
    await prefs.setBool(resolveServicesKey, _resolveServices);
    await prefs.setStringList(mdnsServicesKey, _mdnsServices);
    await prefs.setStringList(persistedBroadcastsKey, _persistedBroadcasts);
    await prefs.setBool(persistBroadcastsKey, _persistBroadcasts);
  }
}
