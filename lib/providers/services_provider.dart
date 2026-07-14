import 'dart:async';

import 'package:aurevoir/app_logger.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger _logger = getLogger('ServiceProvider');

/// This provider is used to discover the available service types.
/// It also listens to the settings provider
/// to get the user-defined service types to always search for.
class ServiceTypeProvider extends ChangeNotifier {
  /// Internal, the user-defined service types.
  Set<String> _userDefinedServiceTypes = {};

  /// Internal, the active BonsoirDiscovery instance.
  BonsoirDiscovery? _serviceTypeDiscovery;

  /// Internal, the available service types.
  final Set<String> _serviceTypes = {};

  /// The available service types.
  UnmodifiableSetView<String> get serviceTypes =>
      UnmodifiableSetView({..._serviceTypes, ..._userDefinedServiceTypes});

  /// This is called when the user settings change.
  void updateUserDefinedServiceTypes(List<String> serviceTypes) {
    // This is to prevent notifying the listeners
    // if the service types are the same.
    if (const SetEquality<String>()
        .equals(_userDefinedServiceTypes, serviceTypes.toSet())) {
      return;
    }

    _userDefinedServiceTypes = serviceTypes.toSet();
    notifyListeners();
  }

  static const _protocolTypes = ['_tcp', '_udp'];

  // This is needed because the wildcard service discovery
  // returns the service in a different format.
  Set<String> _convertServiceType(BonsoirService service) {
    final type = service.name;

    // If the service type does not end with a protocol, we add both protocols.
    return _protocolTypes.map((protocol) => '$type.$protocol').toSet();
  }

  /// Start the service type discovery.
  Future<void> startServiceTypeDiscovery() async {
    if (_serviceTypeDiscovery != null) {
      return;
    }

    _logger.d('🔦 Initializing service discovery');

    _serviceTypeDiscovery = BonsoirDiscovery(type: '_services._dns-sd._udp');
    await _serviceTypeDiscovery!.initialize();
    _logger.i('🔦 Service discovery initialized !');

    _serviceTypeDiscovery!.eventStream!.listen((event) {
      _logger.d('🔦 Service type discovery event: $event');

      if (event is BonsoirDiscoveryStartedEvent) {
        _logger.i('🔦 Service type discovery started');
      } else if (event is BonsoirDiscoveryStoppedEvent) {
        _logger.i('🔦 Service type discovery stopped');
      } else if (event is BonsoirDiscoveryServiceFoundEvent) {
        _logger.i('🔦 Service type found: ${event.service}');
        final serviceTypes = _convertServiceType(event.service);
        _serviceTypes.addAll(serviceTypes);
      } else if (event is BonsoirDiscoveryServiceLostEvent) {
        _logger.i('🔦 Service type lost: ${event.service}');
        final serviceTypes = _convertServiceType(event.service);
        _serviceTypes.removeAll(serviceTypes);
      } else if (event is BonsoirDiscoveryServiceUpdatedEvent) {
        _logger.i('🔦 Service type updated: ${event.service}');
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        _logger.i('🔦 Service type resolved: ${event.service}');
      } else if (event is BonsoirDiscoveryServiceResolveFailedEvent) {
        _logger.w('🔦 Service type resolve failed: ${event.service}');
      } else if (event is BonsoirDiscoveryUnknownEvent) {
        _logger.e('🔦 Service type discovery unknown event: $event');
      } else {
        _logger.f('🔦 Service type discovery unhandled event: $event');
      }
      notifyListeners();
    });

    await _serviceTypeDiscovery!.start();
  }

  /// Stop the service type discovery.
  Future<void> stopServiceTypeDiscovery() async {
    await _serviceTypeDiscovery?.stop();
    _serviceTypeDiscovery = null;
  }

  @override
  void dispose() {
    unawaited(stopServiceTypeDiscovery());
    super.dispose();
  }
}

/// This provider is used to discover the available services of the given types.
class ServiceProvider extends ChangeNotifier {
  bool _shouldResolveServices = false;

  /// Internal, the active BonsoirDiscovery instances.
  final Map<String, BonsoirDiscovery> _discoveries = {};

  /// Internal, the available services.
  final List<BonsoirService> _services = [];

  /// Internal, the resolved services.
  final List<BonsoirService> _resolvedServices = [];

  /// The available services.
  UnmodifiableListView<BonsoirService> get services =>
      UnmodifiableListView(_services);

  /// The resolved services.
  UnmodifiableListView<BonsoirService> get resolvedServices =>
      UnmodifiableListView(_resolvedServices);

  /// Sets a list of service types to discover.
  /// This is to add user-defined service types to the discovery process.
  Future<void> updateServiceTypes(Set<String> serviceTypes) async {
    _logger.d(
      '🔦 Updating service types: $serviceTypes',
    );
    final existingServiceTypes = _discoveries.keys.toList(growable: false);

    for (final type in serviceTypes) {
      try {
        await startServiceDiscovery(type);
      } on Exception catch (e) {
        _logger.e('Error starting service discovery for $type: $e');
      }
    }

    for (final type in existingServiceTypes) {
      if (!serviceTypes.contains(type)) {
        try {
          await stopServiceDiscovery(type);
        } on Object catch (e) {
          _logger.e(
            'Error stopping service discovery for $type: $e',
          );
        }
      }
    }
  }

  /// Synchronizes the current service discovery settings.
  ///
  /// Keeps resolve mode and discovered types aligned with the latest settings.
  void syncConfiguration({
    required bool resolveServices,
    required Set<String> serviceTypes,
  }) {
    unawaited(
      _syncConfiguration(
        resolveServices: resolveServices,
        serviceTypes: serviceTypes,
      ),
    );
  }

  Future<void> _syncConfiguration({
    required bool resolveServices,
    required Set<String> serviceTypes,
  }) async {
    try {
      await setShouldResolveServices(resolveServices);
      await updateServiceTypes(serviceTypes);
    } on Object catch (error, stackTrace) {
      _logger.e(
        'Error synchronizing service discovery configuration',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sets whether to resolve the services or not.
  /// When set to true, the provider will try to resolve the services.
  // ignore: avoid_positional_boolean_parameters
  Future<void> setShouldResolveServices(bool resolveServices) async {
    if (_shouldResolveServices == resolveServices) return;

    _shouldResolveServices = resolveServices;

    _logger.d('🔍 Resolve services: $resolveServices');

    if (_shouldResolveServices) {
      for (final service in _services) {
        await service.resolve(_discoveries[service.type]!.serviceResolver);
      }
    } else {
      _resolvedServices.clear();
    }

    notifyListeners();
  }

  /// Start the service discovery for the given type.
  Future<void> startServiceDiscovery(String type) async {
    if (_discoveries.containsKey(type)) {
      return;
    }

    _logger.d('🔍 Initializing service discovery for type: $type');

    final discovery = BonsoirDiscovery(type: type);
    await discovery.initialize();

    _logger.i('🔍 Service discovery for type $type initialized !');

    discovery.eventStream!.listen((event) async {
      if (event is BonsoirDiscoveryStartedEvent) {
        _logger.i('🔍 Service discovery for type $type started');
      } else if (event is BonsoirDiscoveryStoppedEvent) {
        _logger.i('🔍 Service discovery for type $type stopped');
      } else if (event is BonsoirDiscoveryServiceFoundEvent) {
        await _onServiceFound(event.service);
      } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
        _onServiceResolved(event.service);
      } else if (event is BonsoirDiscoveryServiceUpdatedEvent) {
        _onServiceUpdated(event.service);
      } else if (event is BonsoirDiscoveryServiceLostEvent) {
        _onServiceLost(event.service);
      } else if (event is BonsoirDiscoveryServiceResolveFailedEvent) {
        _onServiceResolvedError(event.service);
      } else if (event is BonsoirDiscoveryUnknownEvent) {
        _logger.e('🔍 Service discovery for type $type unknown event: $event');
      } else {
        _logger
            .f('🔍 Service discovery for type $type unhandled event: $event');
      }
    });

    _discoveries[type] = discovery;
    await discovery.start();
    _logger.i('🔍 Service discovery for type $type started !');
  }

  Future<void> _onServiceFound(BonsoirService service) async {
    _logger.i('🔍 Service Found $service');
    _services.add(service);
    notifyListeners();

    if (_shouldResolveServices) {
      await service.resolve(_discoveries[service.type]!.serviceResolver);
    }
  }

  void _onServiceResolved(BonsoirService service) {
    _logger.i('🔍 Service resolved : ${service.toJson()}');
    _resolvedServices.add(service);
    // _services.remove(service); TODO
    notifyListeners();
  }

  void _onServiceLost(BonsoirService service) {
    _logger.i('🔍 Service lost : ${service.toJson()}');
    _services.remove(service);
    _resolvedServices
        .removeWhere((resolvedService) => resolvedService.name == service.name);
    notifyListeners();
  }

  void _onServiceUpdated(BonsoirService service) {
    _logger.i('🔍 Service updated : ${service.toJson()}');
    final index = _services.indexWhere((s) => s.name == service.name);
    if (index != -1) {
      _services[index] = service;
      notifyListeners();
    }
  }

  void _onServiceResolvedError(BonsoirService? service) {
    _logger.e('🔍 Service resolved error : ${service?.toJson()}');
  }

  /// Stop the service discovery for the given type.
  Future<void> stopServiceDiscovery(String type) async {
    if (!_discoveries.containsKey(type)) {
      return;
    }

    await _discoveries[type]!.stop();
    _discoveries.remove(type);
    _services.removeWhere((service) => service.type == type);
    notifyListeners();
  }

  /// Stop all the service discoveries.
  Future<void> stopAllServiceDiscoveries() async {
    for (final discovery in _discoveries.values) {
      await discovery.stop();
    }

    _discoveries.clear();
    _services.clear();
    notifyListeners();
  }

  /// Dispose the model.
  @override
  void dispose() {
    unawaited(stopAllServiceDiscoveries());
    super.dispose();
  }
}
