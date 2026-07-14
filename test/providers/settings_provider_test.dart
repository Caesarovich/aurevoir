import 'package:aurevoir/providers/settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockListener extends Mock {
  void call();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider', () {
    late SharedPreferences prefs;
    late SettingsProvider settingsProvider;
    late MockListener mockListener;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      settingsProvider = SettingsProvider(prefs: prefs);
      mockListener = MockListener();
      settingsProvider.addListener(mockListener.call);
    });

    test('Initial values are loaded correctly', () {
      expect(settingsProvider.darkMode, false);
      expect(settingsProvider.resolveServices, true);
      expect(settingsProvider.mdnsServices, <String>[]);
      expect(settingsProvider.persistedBroadcasts, <String>[]);
      expect(settingsProvider.persistBroadcasts, false);
    });

    test('Toggle dark mode', () async {
      await settingsProvider.toggleDarkMode();
      expect(settingsProvider.darkMode, true);
      verify(mockListener()).called(1);

      await settingsProvider.toggleDarkMode();
      expect(settingsProvider.darkMode, false);
      verify(mockListener()).called(1);
    });

    test('Toggle persist broadcasts', () async {
      await settingsProvider.togglePersistBroadcasts();
      expect(settingsProvider.persistBroadcasts, true);
      verify(mockListener()).called(1);

      await settingsProvider.togglePersistBroadcasts();
      expect(settingsProvider.persistBroadcasts, false);
      verify(mockListener()).called(1);
    });

    test('Set persisted broadcasts', () async {
      final broadcasts = <String>['broadcast1', 'broadcast2'];
      await settingsProvider.setPersistedBroadcasts(broadcasts);
      expect(settingsProvider.persistedBroadcasts, broadcasts);
      verify(mockListener()).called(1);
    });

    test('Set mDNS services', () async {
      final services = <String>['service1', 'service2'];
      await settingsProvider.setMdnsServices(services);
      expect(settingsProvider.mdnsServices, services);
      verify(mockListener()).called(1);
    });

    test('Toggle service resolution', () async {
      await settingsProvider.toggleServiceResolution();
      expect(settingsProvider.resolveServices, false);
      verify(mockListener()).called(1);

      await settingsProvider.toggleServiceResolution();
      expect(settingsProvider.resolveServices, true);
      verify(mockListener()).called(1);
    });
  });
}
