import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  SettingsProvider({required this.prefs}) {
    loadSettings();
  }

  // Dark mode settings
  static const String darkModeKey = 'darkMode';
  bool _darkMode = false;

  bool get darkMode => _darkMode;

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    _saveSettings();
    notifyListeners();
  }

  // Persist broadcasts settings
  static const String persistBroadcastsKey = 'persistBroadcasts';
  bool _persistBroadcasts = false;

  bool get persistBroadcasts => _persistBroadcasts;

  void togglePersistBroadcasts() {
    _persistBroadcasts = !_persistBroadcasts;
    _saveSettings();
    notifyListeners();
  }

  // Persisted broadcasts list
  static const String persistedBroadcastsKey = 'persistedBroadcasts';
  List<String> _persistedBroadcasts = [];

  List<String> get persistedBroadcasts => _persistedBroadcasts;

  void setPersistedBroadcasts(List<String> broadcasts) {
    _persistedBroadcasts = broadcasts;
    _saveSettings();
    notifyListeners();
  }

  // mDNS services settings
  static const String mdnsServicesKey = 'mdnsServices';
  List<String> _mdnsServices = [];

  List<String> get mdnsServices => _mdnsServices;

  void setMdnsServices(List<String> services) {
    _mdnsServices = services;
    _saveSettings();
    notifyListeners();
  }

  // Resolve services settings

  static const String resolveServicesKey = 'resolveServices';
  bool _resolveServices = true;

  bool get resolveServices => _resolveServices;

  void toggleServiceResolution() {
    _resolveServices = !_resolveServices;
    _saveSettings();
    notifyListeners();
  }

  // Load and save settings
  void loadSettings() {
    _darkMode = prefs.getBool(darkModeKey) ?? false;
    _resolveServices = prefs.getBool(resolveServicesKey) ?? true;
    _mdnsServices = prefs.getStringList(mdnsServicesKey) ?? [];
    _persistedBroadcasts = prefs.getStringList(persistedBroadcastsKey) ?? [];
    _persistBroadcasts = prefs.getBool(persistBroadcastsKey) ?? false;
    notifyListeners();
  }

  void _saveSettings() {
    prefs.setBool(darkModeKey, _darkMode);
    prefs.setBool(resolveServicesKey, _resolveServices);
    prefs.setStringList(mdnsServicesKey, _mdnsServices);
    prefs.setStringList(persistedBroadcastsKey, _persistedBroadcasts);
    prefs.setBool(persistBroadcastsKey, _persistBroadcasts);
  }
}
